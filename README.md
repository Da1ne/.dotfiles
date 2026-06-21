# .dotfiles

Personal config, managed with [GNU Stow](https://www.gnu.org/software/stow/).
Each top-level directory is a Stow *package* that mirrors `$HOME`, so symlinks
land in the right place automatically. Edits to the symlinked files show up here
in the repo — commit and push to sync.

## Installation

```sh
git clone https://github.com/Da1ne/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh         # core only (headless servers): nvim, tmux, bash, htop
./bootstrap.sh --gui   # core + Wayland/Hyprland desktop (Arch): hypr, waybar, kitty, mako, wofi
```

`bootstrap.sh` installs `stow` if missing, backs up any pre-existing real file
(e.g. a distro default `~/.bashrc`) to `<file>.bak`, then symlinks each package.
Re-running it is safe (idempotent restow).

To manage a single package by hand:

```sh
stow --target="$HOME" <package>     # link
stow --target="$HOME" -D <package>  # unlink
```

## Inspiration
- https://www.youtube.com/watch?v=y6XCebnB9gs
- https://github.com/ThePrimeagen/.dotfiles
