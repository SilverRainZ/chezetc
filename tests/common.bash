# Shared test setup/teardown for chezetc e2e tests.
#
# Source this file at the top of each test script, then call setup_chezetc_env.

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

fail() { printf "${RED}FAIL: %s${NC}\n" "$*" >&2; exit 1; }
pass() { printf "${GREEN}PASS: %s${NC}\n" "$*" >&2; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${CHEZETC_REPO:-$(dirname "$SCRIPT_DIR")}"

WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT

MOCK_BIN="$WORKDIR/mock-bin"
CHEZETC_DIR="$WORKDIR/chezetc"
ETC_CFG_FILE="$HOME/.config/chezetc/chezetc.toml"

export HOME="$WORKDIR/home"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

#--------------------------------------------------------------------
# Common setup functions
#--------------------------------------------------------------------

setup_mocks() {
    mkdir -p "$MOCK_BIN"

    # Mock sudo: skip flags, execute the real command
    cat > "$MOCK_BIN/sudo" << 'EOF'
#!/bin/bash
while [[ $# -gt 0 ]]; do
    case "$1" in
        --preserve-env=*|--preserve-env|-E) shift ;;
        --) shift; break ;;
        -*) shift ;;
        *) break ;;
    esac
done
exec "$@"
EOF
    chmod +x "$MOCK_BIN/sudo"

    # Mock chezmoi: capture all arguments
    cat > "$MOCK_BIN/chezmoi" << EOF
#!/bin/bash
printf '%s\n' "\$@" > "$WORKDIR/chezmoi-args"
EOF
    chmod +x "$MOCK_BIN/chezmoi"

    export PATH="$MOCK_BIN:$PATH"
}

install_chezetc() {
    mkdir -p "$CHEZETC_DIR"/{utils,commands,hooks}
    cp "$REPO_ROOT/chezetc" "$CHEZETC_DIR/"
    cp "$REPO_ROOT/chezmoi.toml" "$CHEZETC_DIR/"
    touch "$CHEZETC_DIR/commands/editor"
    touch "$CHEZETC_DIR/commands/cd"
    touch "$CHEZETC_DIR/hooks/post-add-chown.sh"
}

pre_render_config() {
    local cfg_dir="$XDG_CONFIG_HOME/chezmoi/chezetc"
    mkdir -p "$cfg_dir" "$XDG_CACHE_HOME/chezmoi/chezetc" "$XDG_DATA_HOME/chezetc"

    # Pre-render the template so chezetc sees it as unchanged (avoids EAGAIN exit)
    ETC_APP=chezetc \
    ETC_DIR="$CHEZETC_DIR" \
    MOI_SRC_DIR="$XDG_DATA_HOME/chezetc" \
    MOI_DST_DIR="/etc" \
        envsubst < "$CHEZETC_DIR/chezmoi.toml" > "$cfg_dir/chezmoi.toml"
}

setup_chezetc_env() {
    setup_mocks
    install_chezetc
    pre_render_config
}

run_chezetc() {
    ETC_APP=chezetc \
    ETC_MODE=CHEZMOI \
    ETC_SRC="$XDG_DATA_HOME/chezetc" \
    ETC_DST="etc" \
    ETC_CFG="$ETC_CFG_FILE" \
        bash "$CHEZETC_DIR/chezetc" "$@"
}

captured_chezmoi_args() {
    cat "$WORKDIR/chezmoi-args" 2>/dev/null || echo ""
}

make_user_config() {
    mkdir -p "$(dirname "$ETC_CFG_FILE")"
    cat > "$ETC_CFG_FILE"
}
