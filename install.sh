#!/usr/bin/env bash
# install.sh — installs .bash_aliases into your home directory and makes ~/.bashrc load it and completion.bash.
# Safe to run again: nothing is added twice, and downloaded files are refreshed.
#
# From a clone, it uses the files of the clone:
#   ./install.sh [--uninstall]
# On its own, it downloads the files from GitHub into ~/.bash-aliases first:
#   curl -fsSL https://raw.githubusercontent.com/klahio/bash-aliases/main/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/klahio/bash-aliases/main/install.sh | bash -s -- --uninstall
#
# Environment:
#   BASH_ALIASES_DIR  where downloaded files go (default ~/.bash-aliases)
#   BASH_ALIASES_URL  where they are downloaded from (default the main branch on GitHub)
set -euo pipefail

files=(.bash_aliases completion.bash install.sh)
bashrc="$HOME/.bashrc"
aliases="$HOME/.bash_aliases"
begin='# >>> klahio/bash-aliases >>>'
end='# <<< klahio/bash-aliases <<<'

# source_dir prints the directory of this script when it runs from a copy that has the other files next to it,
# as in a clone. Run through a pipe there is no such directory.
source_dir() {
  local src=${BASH_SOURCE[0]:-} dir f
  [ -n "$src" ] && [ -f "$src" ] || return 0
  dir=$(cd "$(dirname "$src")" && pwd)
  for f in "${files[@]}"; do
    [ -f "$dir/$f" ] || return 0
  done
  echo "$dir"
}

fetch() {
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$1" -o "$2"
  elif command -v wget >/dev/null 2>&1; then
    wget -q "$1" -O "$2"
  else
    echo "curl or wget is required to download $1" >&2
    return 1
  fi
}

# download fetches every file into the directory. Each file is checked before it replaces the old one, so a
# failed or partial download leaves the previous install in place.
download() {
  local dir=$1 url=$2 f
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' EXIT
  for f in "${files[@]}"; do
    if ! fetch "$url/$f" "$tmp/$f"; then
      echo "Could not download $url/$f; nothing was changed" >&2
      return 1
    fi
    if [ ! -s "$tmp/$f" ] || ! bash -n "$tmp/$f"; then
      echo "Downloaded $f is empty or not a valid bash script; nothing was changed" >&2
      return 1
    fi
  done
  mkdir -p "$dir"
  for f in "${files[@]}"; do
    mv "$tmp/$f" "$dir/$f"
  done
  chmod +x "$dir/install.sh"
  echo "Downloaded ${files[*]} from $url into $dir"
}

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

uninstall() {
  local dir=$1 downloaded=$2 backup f
  remove_block
  if [ -L "$aliases" ] && [ "$(readlink "$aliases")" = "$dir/.bash_aliases" ]; then
    rm "$aliases"
    echo "Removed the link $aliases"
  fi
  if [ "$downloaded" = yes ] && [ -d "$dir" ]; then
    for f in "${files[@]}"; do rm -f "$dir/$f"; done
    rmdir "$dir" 2>/dev/null && echo "Removed $dir" || echo "Removed the downloaded files from $dir"
  fi
  for backup in "$aliases".bak.*; do
    [ -e "$backup" ] && echo "Your earlier aliases are in $backup; move it back to $aliases to use it again"
  done
  return 0
}

main() {
  local dir target downloaded=no
  target=${BASH_ALIASES_DIR:-$HOME/.bash-aliases}
  dir=$(source_dir)
  # The download directory is managed by this script unless it is a clone, also when this is its own copy there.
  if [ -z "$dir" ] || { [ "$dir" = "$(cd "$target" 2>/dev/null && pwd)" ] && [ ! -d "$dir/.git" ]; }; then
    dir=$target
    if [ -d "$dir/.git" ]; then
      echo "$dir is a git clone; using its files as they are (run git pull there to update)"
    else
      downloaded=yes
    fi
  fi

  if [ "${1:-}" = "--uninstall" ]; then
    uninstall "$dir" "$downloaded"
    return
  fi

  if [ "$downloaded" = yes ]; then
    download "$dir" "${BASH_ALIASES_URL:-https://raw.githubusercontent.com/klahio/bash-aliases/main}"
  fi

  # Link ~/.bash_aliases to the installed copy, keeping a backup of a file that is already there.
  if [ -L "$aliases" ] && [ "$(readlink "$aliases")" = "$dir/.bash_aliases" ]; then
    echo "$aliases already links to $dir/.bash_aliases"
  else
    if [ -e "$aliases" ] || [ -L "$aliases" ]; then
      local backup
      backup="$aliases.bak.$(date +%Y%m%d%H%M%S)"
      mv "$aliases" "$backup"
      echo "Moved the existing $aliases to $backup"
    fi
    ln -s "$dir/.bash_aliases" "$aliases"
    echo "Linked $aliases -> $dir/.bash_aliases"
  fi

  # Add a block to ~/.bashrc with what it does not load yet. The block is rewritten on every run, so it follows
  # the installed copy if it moves.
  touch "$bashrc"
  remove_block >/dev/null
  local lines=()
  if ! grep -qE '^[^#]*(\.|source)[[:space:]]+[^#]*\.bash_aliases' "$bashrc"; then
    lines+=('[ -f ~/.bash_aliases ] && . ~/.bash_aliases')
  fi
  # completion.bash defines _kcomp_alias; a ~/.bashrc that already has it carries the same setup inline.
  if ! grep -q '_kcomp_alias' "$bashrc"; then
    lines+=("[ -f \"$dir/completion.bash\" ] && . \"$dir/completion.bash\"")
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
}

# Everything runs from here, so a download through a pipe that breaks off halfway runs nothing.
main "$@"
