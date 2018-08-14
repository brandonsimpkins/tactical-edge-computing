#!/bin/bash

HOOK_NAMES="pre-commit"
HOOK_DIR=$(git rev-parse --show-toplevel)/.git/hooks

for hook in $HOOK_NAMES; do

  # If the hook already exists, is executable, and is not a symlink
  if [ -f $HOOK_DIR/$hook ] && ! [ -h $HOOK_DIR/$hook ]; then
    local_file="$HOOK_DIR/$hook.local.$(date +%Y-%m-%d_%H%M)"
    echo "Detected local hook that was already installed: $HOOK_DIR/$hook"
    echo "  - Renaming hook to: $local_file"
    mv $HOOK_DIR/$hook $local_file
  fi

  # create the symlink, overwriting the file if it exists
  echo "Installing the '$hook' hook."
  ln -sf ../../git-hooks/$hook $HOOK_DIR

done
