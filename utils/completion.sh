# NOTE: This script is not executeable. It MUST be sourced from ../chezetc.

# Shell completion vars.
BASH_COMP_TMPL="$ETC_DIR/completions/chezetc.bash"
ZSH_COMP_TMPL="$ETC_DIR/completions/chezetc.zsh"
CACHED_COMP_FILE="$MOI_CACHE_DIR/$ETC_MODE"

export ETC_APP

case $ETC_MODE in
   BASH_COMPLETION)
      update_tmpl $BASH_COMP_TMPL $CACHED_COMP_FILE;;
   ZSH_COMPLETION)
      update_tmpl $ZSH_COMP_TMPL $CACHED_COMP_FILE;;
   *)
     err "Unsupported completion mode: $ETC_MODE";;
esac

cat $CACHED_COMP_FILE && exit 0
