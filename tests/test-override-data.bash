#!/bin/bash
# Test: --override-data-file is passed to chezmoi when ETC_CFG exists.

source "$(dirname "$0")/common.bash"
setup_chezetc_env

make_user_config << 'EOF'
test_variable = "e2e_override_value"
user_email = "test@example.com"
EOF

run_chezetc apply

# Assert --override-data-file was passed with correct path
captured_chezmoi_args | grep -qF -- "--override-data-file=$ETC_CFG_FILE" \
    && pass "--override-data-file passed to chezmoi" \
    || fail "--override-data-file missing"

echo >&2
printf "${GREEN}All tests passed!${NC}\n" >&2
