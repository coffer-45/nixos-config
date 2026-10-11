{
  config,
  inputs,
  pkgs,
  ...
}:

let
  doomVtermModule = pkgs.runCommand "doom-vterm-module" { } ''
    mkdir -p "$out"
    ln -s ${pkgs.emacsPackages.vterm}/share/emacs/site-lisp/elpa/vterm-*/vterm-module.so "$out/vterm-module.so"
  '';
  doomJavaDebugJar = pkgs.runCommand "doom-java-debug-jar" { } ''
    mkdir -p "$out"
    ln -s ${pkgs.vscode-extensions.vscjava.vscode-java-debug}/share/vscode/extensions/vscjava.vscode-java-debug/server/com.microsoft.java.debug.plugin-*.jar "$out/plugin.jar"
  '';
in

{
  imports = [
    inputs.noctalia.homeModules.default
    ./noctalia.nix
    ./packages.nix
    ./niri.nix
    ./visuals.nix
  ];

  home.username = "andrey";
  home.homeDirectory = "/home/andrey";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  # Keep the editable Doom configuration in this repository.
  xdg.configFile."doom" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/home/doom";
    # Until the NixOS generation is switched, the old Home Manager service
    # must leave the direct symlink in place. Adopt it on the next switch.
    force = true;
  };
  xdg.dataFile."doom-typst-grammar/libtree-sitter-typst.so" = {
    source = "${pkgs.tree-sitter-grammars.tree-sitter-typst}/parser";
    force = true;
  };
  xdg.dataFile."doom-vterm/vterm-module.so" = {
    source = "${doomVtermModule}/vterm-module.so";
    force = true;
  };
  xdg.dataFile."doom-java-debug/plugin.jar" = {
    source = "${doomJavaDebugJar}/plugin.jar";
    force = true;
  };
  home.sessionPath = [
    "$HOME/.local/state/nix/profiles/home-manager/home-path/bin"
    "$HOME/.config/emacs/bin"
  ];

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };

  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting ""
      if command -q fastfetch
        fastfetch
      end
    '';
    functions.rebuild = ''
      sudo nixos-rebuild switch --flake path:/home/andrey/nixos-config#acer-a715-42g --no-update-lock-file --option accept-flake-config true
      or return $status
      sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations +2
    '';
    shellAliases = {
      update = "nix flake update --flake path:/home/andrey/nixos-config";
    };
  };
}
