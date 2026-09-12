{ pkgs, inputs, ... }:

{
  imports = [
    inputs.noctalia.homeModules.default
    ./packages.nix
    ./niri.nix
  ];

  home.username = "drew";
  home.homeDirectory = "/home/drew";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
  fonts.fontconfig.enable = true;

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };

  programs.git = {
    enable = true;
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };

  programs.fish = {
    enable = true;
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#acer-a715-42g";
      update = "sudo nix flake update --flake /etc/nixos";
    };
  };

  # This is Noctalia v5, the actively developed successor to the legacy
  # Quickshell-based project called "Noctalia Shell".
  programs.noctalia = {
    enable = true;
    settings = {
      theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Catppuccin";
      };
    };
  };
}
