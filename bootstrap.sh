#!/usr/bin/env bash
#
# bootstrap.sh — set these dotfiles up on a fresh machine. Run from inside the repo.
#   ./bootstrap.sh         core only (headless servers)
#   ./bootstrap.sh --gui   core + Wayland/Hyprland desktop (Arch)
# Backs up any pre-existing real file (e.g. distro default ~/.bashrc) to <file>.bak.
#
set -uo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORE=(nvim tmux bash htop)
GUI=(hypr waybar kitty mako wofi)

case "${1:-}" in
  "")    PKGS=("${CORE[@]}") ;;
  --gui) PKGS=("${CORE[@]}" "${GUI[@]}") ;;
  *) echo "usage: $(basename "$0") [--gui]" >&2; exit 2 ;;
esac

pkg_install() {
  if   command -v pacman >/dev/null; then sudo pacman -S --needed --noconfirm "$@"
  elif command -v apt    >/dev/null; then sudo apt-get update && sudo apt-get install -y "$@"
  else echo "install these manually, then re-run: $*" >&2; return 1; fi
}

command -v stow >/dev/null || pkg_install stow || exit 1

# Wayland clipboard helper — required for nvim copy/paste to reach the system
# clipboard on the local desktop (over SSH nvim falls back to OSC 52 instead).
if [ "${1:-}" = "--gui" ] && ! command -v wl-copy >/dev/null; then
  pkg_install wl-clipboard || echo "  note: install wl-clipboard for local clipboard support" >&2
fi

backup_conflicts() {
  local rel tgt
  ( cd "$DOTFILES/$1" && find . -mindepth 1 \( -type f -o -type l \) -printf '%P\n' ) |
  while IFS= read -r rel; do
    tgt="$HOME/$rel"
    if [ -e "$tgt" ] && [ ! -L "$tgt" ]; then
      mkdir -p "$(dirname "$tgt")"; mv "$tgt" "$tgt.bak"; echo "  backed up ~/$rel → ~/$rel.bak"
    fi
  done
}

cd "$DOTFILES"
for pkg in "${PKGS[@]}"; do
  [ -d "$pkg" ] || { echo "skip $pkg (not in repo)"; continue; }
  backup_conflicts "$pkg"
  if stow --target="$HOME" --restow "$pkg"; then echo "stowed $pkg"
  else echo "FAILED $pkg — resolve conflicts above and re-run" >&2; fi
done
echo "done."
