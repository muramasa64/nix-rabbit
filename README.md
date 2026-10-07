English | [日本語](README_ja.md)

# nix-rabbit

A Nix flake devShell for [Rabbit](https://rabbit-shocker.org/), the presentation tool written in Ruby.

## Requirements

- Nix with flakes enabled
- (Optional) direnv
- Platform: aarch64-darwin

## Usage

```sh
nix develop
```

On the first run, the shell hook installs the `rabbit` gem into `./.gem`.
This takes a few minutes because the GNOME bindings are compiled.

With direnv, run `direnv allow` once and the environment is loaded when entering the directory.

```sh
# Show slides in a window
rabbit slide.md

# Export slides to PDF
rabbit --print --output-filename slide.pdf slide.md
```

No X server or Xvfb is needed on macOS; GTK draws windows through Quartz.

## Notes

- The `rabbit` gem version is not pinned. To upgrade, remove `./.gem` and enter the shell again.
- Fontconfig can see Noto CJK and the macOS system fonts (`/System/Library/Fonts`, `/Library/Fonts`).
- The flake contains workarounds required on macOS:
  - The Ruby `pkg-config` gem resolves `Requires.private` entries, so extra libraries (`libepoxy`, `dav1d`, `libthai`, `libdatrie`) are included.
  - glib on macOS refers to `sysprof-capture-4`, which is Linux-only. A stub `.pc` file is provided on Darwin.
  - `poppler_gi` is used instead of `poppler` because only the former ships the GObject typelib. `GI_TYPELIB_PATH` is set explicitly.
