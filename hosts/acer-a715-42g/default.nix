{ inputs, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.default
    inputs.noctalia.nixosModules.default
  ];

  networking.hostName = "acer-a715-42g";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Kyiv";
  i18n.defaultLocale = "uk_UA.UTF-8";

  services.xserver.xkb = {
    layout = "us,ua";
    options = "grp:alt_shift_toggle";
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Needed for VS Code, Discord, Steam and Obsidian in home/packages.nix.
  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Keep GDM as the login screen: it is familiar from the current GNOME setup
  # and exposes the Niri session without installing the GNOME desktop.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = false;

  programs.niri.enable = true;
  security.polkit.enable = true;

  # Provides the Secret Service for applications such as browsers and VS Code.
  # The NixOS module owns its D-Bus/PAM integration; do not start a second
  # Home Manager gnome-keyring service.
  services.gnome.gnome-keyring.enable = true;

  # Noctalia owns the bar, launcher, lock screen, notifications and wallpaper.
  # It also enables NetworkManager, Bluetooth, UPower and power profiles.
  programs.noctalia = {
    enable = true;
    recommendedServices.enable = true;
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "amdgpu" "nvidia" ];

  # Laptop GPU layout detected on the current CachyOS installation:
  # AMD Lucienne iGPU at 05:00.0 and RTX 3050 Ti Mobile at 01:00.0.
  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
    powerManagement = {
      enable = true;
      finegrained = true;
    };
    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      amdgpuBusId = "PCI:5:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  programs.steam.enable = true;
  virtualisation.docker.enable = true;
  zramSwap.enable = true;

  users.users.drew = {
    isNormalUser = true;
    description = "drew";
    shell = pkgs.fish;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "docker" ];
  };
  programs.fish.enable = true;

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users.drew = import ../../home/drew.nix;
  };

  # Set this to the release used for the first actual installation and do not
  # change it later. 26.05 is the current stable baseline at preparation time.
  system.stateVersion = "26.05";
}
