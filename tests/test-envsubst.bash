#!/bin/bash
# Test: envsubst renders chezmoi.toml template with correct variable substitution.

source "$(dirname "$0")/common.bash"

# Simulate the envsubst invocation that update_tmpl performs
export ETC_APP=chezetc ETC_DIR="$CHEZETC_DIR"
export MOI_SRC_DIR="$XDG_DATA_HOME/chezetc"
export MOI_DST_DIR="/etc"

render_template() {
    envsubst < "$REPO_ROOT/chezmoi.toml"
}

output=$(render_template)

# Assert sourceDir is substituted correctly
echo "$output" | grep -qF "sourceDir = \"$MOI_SRC_DIR\"" \
    && pass "sourceDir rendered correctly" \
    || fail "sourceDir substitution mismatch"

# Assert destDir is substituted correctly
echo "$output" | grep -qF "destDir = \"$MOI_DST_DIR\"" \
    && pass "destDir rendered correctly" \
    || fail "destDir substitution mismatch"

# Assert edit.command points to the editor shim
echo "$output" | grep -qF "command = \"$ETC_DIR/commands/editor\"" \
    && pass "edit.command rendered correctly" \
    || fail "edit.command substitution mismatch"

# Assert no leftover $variable remains unsubstituted
echo "$output" | grep -q '\$MOI_SRC_DIR\|\$MOI_DST_DIR\|\$ETC_DIR\|\$ETC_APP' \
    && fail "Unsubstituted variable found in output" \
    || pass "No unsubstituted variables"

echo >&2
printf "${GREEN}All tests passed!${NC}\n" >&2
