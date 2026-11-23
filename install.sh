#!/usr/bin/env bash
# install.sh — links .bash_aliases into your home directory and makes ~/.bashrc load it and completion.bash.
# Safe to run again: nothing is added twice.
#
# Usage: ./install.sh [--uninstall]
set -euo pipefail

repo=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
bashrc="$HOME/.bashrc"
aliases="$HOME/.bash_aliases"
begin='# >>> klahio/bash-aliases >>>'
end='# <<< klahio/bash-aliases <<<'

remove_block() {
  [ -f "$bashrc" ] || return 0
  if grep -qxF "$begin" "$bashrc"; then
    # Drop the block and the blank line written before it; write in place so a linked ~/.bashrc stays a link.
    local kept
    kept=$(awk -v b="$begin" -v e="$end" '
      $0 == b { skip = 1; blank = 0; next }
      skip    { if ($0 == e) skip = 0; next }
      { if (blank) { print ""; blank = 0 } if ($0 == "") { blank = 1; next } print }
      END { if (blank) print "" }' "$bashrc")
    if [ -n "$kept" ]; then printf '%s\n' "$kept" > "$bashrc"; else : > "$bashrc"; fi
    echo "Removed the bash-aliases block from $bashrc"
  fi
}

if [ "${1:-}" = "--uninstall" ]; then
  remove_block
  if [ -L "$aliases" ] && [ "$(readlink "$aliases")" = "$repo/.bash_aliases" ]; then
    rm "$aliases"
    echo "Removed the link $aliases"
  fi
  for backup in "$aliases".bak.*; do
    [ -e "$backup" ] && echo "Your earlier aliases are in $backup; move it back to $aliases to use it again"
  done
  exit 0
fi

# Link ~/.bash_aliases to the repo, keeping a backup of a file that is already there.
if [ -L "$aliases" ] && [ "$(readlink "$aliases")" = "$repo/.bash_aliases" ]; then
  echo "$aliases already links to $repo/.bash_aliases"
else
  if [ -e "$aliases" ] || [ -L "$aliases" ]; then
    backup="$aliases.bak.$(date +%Y%m%d%H%M%S)"
    mv "$aliases" "$backup"
    echo "Moved the existing $aliases to $backup"
  fi
  ln -s "$repo/.bash_aliases" "$aliases"
  echo "Linked $aliases -> $repo/.bash_aliases"
fi

# Add a block to ~/.bashrc with what it does not load yet. The block is rewritten on every run, so it follows
# the repo if it moves.
touch "$bashrc"
remove_block >/dev/null
lines=()
if ! grep -qE '^[^#]*(\.|source)[[:space:]]+[^#]*\.bash_aliases' "$bashrc"; then
  lines+=('[ -f ~/.bash_aliases ] && . ~/.bash_aliases')
fi
# completion.bash defines _kcomp_alias; a ~/.bashrc that already has it carries the same setup inline.
if ! grep -q '_kcomp_alias' "$bashrc"; then
  lines+=("[ -f \"$repo/completion.bash\" ] && . \"$repo/completion.bash\"")
fi
if [ ${#lines[@]} -eq 0 ]; then
  echo "$bashrc already loads .bash_aliases and completion; left it unchanged"
else
  {
    echo
    echo "$begin"
    printf '%s\n' "${lines[@]}"
    echo "$end"
  } >> "$bashrc"
  echo "Added to $bashrc:"
  printf '  %s\n' "${lines[@]}"
fi

echo "Open a new shell, or run: . ~/.bashrc"
