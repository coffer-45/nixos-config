# Doom Emacs setup

The NixOS Home Manager configuration links this directory to `~/.config/doom`.
Doom core lives in `~/.config/emacs`; it is updated separately with `doom upgrade`.
After changing `init.el` or `packages.el`, run `~/.config/emacs/bin/doom sync`.

On a fresh machine, activate Home Manager, then install Doom core and its
packages:

```sh
git clone --recurse-submodules https://github.com/doomemacs/core ~/.config/emacs
~/.config/emacs/bin/doom install --no-env
```

Included from the VS Code setup:

- C/C++: `clangd`, CMake, Make, GDB, and LLDB DAP.
- Python: Eglot with Pyright and Debugpy; project virtual environments remain project owned.
- Java: Eclipse JDT LS with the Java Debug Server bundle, Maven, and Gradle.
- Rust: rust-analyzer, Cargo, and LLDB DAP.
- Nix, Markdown, YAML, Dockerfiles: modes, language servers and lint tools.
- Typst: `typst-ts-mode` and Tinymist; Tinymist exports PDF on save. Use
  `SPC m v` in a Typst buffer to open the generated PDF in Zathura.
- Opening a local PDF from Emacs, Treemacs, or Dired launches Zathura.
- Git: Magit; projects and file tree: Doom's project tools and Treemacs.
- Terminal: vterm with a Nix-built native module, for tools such as the already
  installed Codex CLI.

The VS Code extension packs, theme pack, language pack, Dependi panel, Codex
audio integration, and Dev Containers UI have no direct Emacs equivalent here.
Docker handles container commands and TRAMP opens remote files. Dape uses the
installed debug adapters; launch arguments are chosen per project.
