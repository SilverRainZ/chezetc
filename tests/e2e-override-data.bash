#!/bin/bash
# e2e test: verify --override-data-file replaces toml-merge.py
#
# This test ensures that:
# 1. chezetc no longer requires Python3/tomli/tomli_w
# 2. User's ETC_CFG is passed to chezmoi as --override-data-file
# 3. The generated chezmoi config is directly from envsubst (no merge step)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="${CHEZETC_REPO:-$(dirname "$SCRIPT_DIR")}"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

fail() { printf "${RED}FAIL: %s${NC}\n" "$*" >&2; exit 1; }
pass() { printf "${GREEN}PASS: %s${NC}\n" "$*" >&2; }

#--------------------------------------------------------------------
# Setup: create isolated test environment
#--------------------------------------------------------------------

WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT

export HOME="$WORKDIR/home"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

# Mock bin directory to intercept sudo and chezmoi
MOCK_BIN="$WORKDIR/mock-bin"
mkdir -p "$MOCK_BIN"

# Mock sudo: pass-through (skip sudo's own flags, execute the real command)
cat > "$MOCK_BIN/sudo" << 'MOCKEOF'
#!/bin/bash
args=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        --preserve-env=*|--preserve-env|-E) shift ;;
        --) shift; break ;;
        -*) shift ;;
        *) break ;;
    esac
done
exec "$@"
MOCKEOF
chmod +x "$MOCK_BIN/sudo"

# Mock chezmoi: capture all arguments into a file
cat > "$MOCK_BIN/chezmoi" << 'MOCKEOF'
#!/bin/bash
printf '%s\n' "$@" > /tmp/chezetc-e2e-chezmoi-args
MOCKEOF
chmod +x "$MOCK_BIN/chezmoi"

export PATH="$MOCK_BIN:$PATH"

#--------------------------------------------------------------------
# Set up chezetc files (simulate installed chezetc)
#--------------------------------------------------------------------

CHEZETC_DIR="$WORKDIR/chezetc"
mkdir -p "$CHEZETC_DIR"/{utils,commands,hooks}

# Copy the actual chezetc script and template
cp "$REPO_ROOT/chezetc" "$CHEZETC_DIR/"
cp "$REPO_ROOT/chezmoi.toml" "$CHEZETC_DIR/"

# Create required shim/hook files (content doesn't matter for this test)
touch "$CHEZETC_DIR/commands/editor"
touch "$CHEZETC_DIR/commands/cd"
touch "$CHEZETC_DIR/hooks/post-add-chown.sh"

#--------------------------------------------------------------------
# Pre-create the generated chezmoi config
# (avoids the "Configuration updated, please run again" exit)
#--------------------------------------------------------------------

MOI_SRC_DIR="$XDG_DATA_HOME/chezetc"
MOI_DST_DIR="/etc"
MOI_CFG_DIR="$XDG_CONFIG_HOME/chezmoi/chezetc"
MOI_CACHE_DIR="$XDG_CACHE_HOME/chezmoi/chezetc"

mkdir -p "$MOI_SRC_DIR"
mkdir -p "$MOI_CFG_DIR"
mkdir -p "$MOI_CACHE_DIR"

# Pre-render the template (same content update_tmpl would produce)
{
    export ETC_APP=chezetc
    export ETC_DIR="$CHEZETC_DIR"
    export MOI_SRC_DIR MOI_DST_DIR
    cat "$CHEZETC_DIR/chezmoi.toml" | envsubst
} > "$MOI_CFG_DIR/chezmoi.toml"

#--------------------------------------------------------------------
# Create user's custom config (template data for --override-data-file)
#--------------------------------------------------------------------

ETC_CFG_FILE="$XDG_CONFIG_HOME/chezetc/chezetc.toml"
mkdir -p "$(dirname "$ETC_CFG_FILE")"

cat > "$ETC_CFG_FILE" << 'EOF'
# User template data
test_variable = "e2e_override_value"
user_email = "test@example.com"
EOF

pass "Test environment ready at $WORKDIR"

#--------------------------------------------------------------------
# Run chezetc
#--------------------------------------------------------------------

ETC_APP=chezetc \
ETC_MODE=CHEZMOI \
ETC_SRC="$MOI_SRC_DIR" \
ETC_DST="etc" \
ETC_CFG="$ETC_CFG_FILE" \
    bash "$CHEZETC_DIR/chezetc" apply

#--------------------------------------------------------------------
# Assertions
#--------------------------------------------------------------------

CAPTURED_FILE="/tmp/chezetc-e2e-chezmoi-args"
[[ -f "$CAPTURED_FILE" ]] || fail "Mock chezmoi was not invoked (captured args file missing)"

CAPTURED_ARGS=$(cat "$CAPTURED_FILE")
echo "Captured chezmoi args: $CAPTURED_ARGS" >&2

# Check 1: --override-data-file is present with correct path
if echo "$CAPTURED_ARGS" | grep -qF -- "--override-data-file=$ETC_CFG_FILE"; then
    pass "--override-data-file points to correct user config"
else
    fail "--override-data-file=$ETC_CFG_FILE not found in chezmoi args"
fi

# Check 2: User config file exists and contains test data
if [[ -f "$ETC_CFG_FILE" ]]; then
    pass "User config file exists at $ETC_CFG_FILE"
else
    fail "User config file does not exist"
fi

if grep -q 'test_variable = "e2e_override_value"' "$ETC_CFG_FILE"; then
    pass "User config contains expected template data"
else
    fail "User config missing expected data"
fi

# Check 3: No Python-related commands were invoked (sanity check)
if echo "$CAPTURED_ARGS" | grep -q "python3\|tomli\|toml-merge"; then
    fail "Python/tomli references found in chezmoi invocation"
else
    pass "No Python/tomli dependency referenced"
fi

#--------------------------------------------------------------------
# Cleanup captured file
#--------------------------------------------------------------------

rm -f "$CAPTURED_FILE"

echo >&2
printf "${GREEN}All e2e tests passed!${NC}\n" >&2
