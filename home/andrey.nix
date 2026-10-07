{ inputs, ... }:

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
