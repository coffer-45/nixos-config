{ inputs, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.default
    inputs.noctalia.nixosModules.default
  ];

  networking.hostName = "acer-a715-42g";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Kyiv";
  i18n.defaultLocale = "uk_UA.UTF-8";

  services.xserver.xkb = {
    layout = "us,ua,ru";
    options = "grp:alt_shift_toggle";
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
    extra-substituters = [ "https://noctalia.cachix.org" ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    # System generations are trimmed by the `rebuild` fish function.
    # Garbage collection only removes paths no longer referenced by a profile.
    options = "";
  };

  # Needed for VS Code, Discord, Steam and Obsidian in home/packages.nix.
  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 2;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use the same pixel-street look at login as in the Niri session.
  services.displayManager.noctalia-greeter = {
    enable = true;
    cursorTheme = {
      package = pkgs.catppuccin-cursors.mochaLavender;
      name = "catppuccin-mocha-lavender-cursors";
    };
    settings = {
      cursor.size = 32;
      session.default = "Niri";
      user.default = "andrey";
      keyboard = {
        layout = "us,ua,ru";
        options = "grp:alt_shift_toggle";
      };
      appearance = {
        scheme = "Synced";
        theme_mode = "dark";
        font_family = "Pixeloid Sans";
        corner_radius_scale = 1.15;
        hide_logo = true;
        scheme_selector_position = "hidden";
        wallpaper = {
          path = "${../../home/assets/wallpapers/rainy-pixel-street.png}";
          fill_mode = "crop";
        };
        palette = {
          primary = "#b9b1cc";
          on_primary = "#181922";
          secondary = "#e36b78";
          on_secondary = "#181922";
          tertiary = "#72b7b0";
          on_tertiary = "#181922";
          error = "#f58b98";
          on_error = "#181922";
          surface = "#181922";
          on_surface = "#fafafa";
          surface_variant = "#242531";
          on_surface_variant = "#b4b5b7";
          outline = "#978ab3";
          shadow = "#0b0c12";
          hover = "#978ab3";
          on_hover = "#181922";
        };
      };
      clock = {
        enabled = true;
        position = "above-panel";
        time_format = "{:%H:%M}";
        date_format = "%a %d %b";
      };
    };
  };
  services.desktopManager.gnome.enable = false;

  fonts.packages = [
    (pkgs.runCommand "pixel-street-fonts" { } ''
      mkdir -p "$out/share/fonts/truetype"
      cp ${../../home/assets/fonts/CozetteVector.ttf} "$out/share/fonts/truetype/"
      cp ${../../home/assets/fonts/PixeloidSans.ttf} "$out/share/fonts/truetype/"
      cp ${../../home/assets/fonts/PixeloidMono.ttf} "$out/share/fonts/truetype/"
    '')
  ];

  programs.niri.enable = true;
  security.polkit.enable = true;
  security.rtkit.enable = true;

  services.gvfs.enable = true;
  services.udisks2.enable = true;
  programs.gnome-disks.enable = true;

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

  # Leave the adapter off after boot; enable it manually from Noctalia.
  hardware.bluetooth.powerOnBoot = false;

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

  services.xserver.videoDrivers = [
    "amdgpu"
    "nvidia"
  ];

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

  users.users.andrey = {
    isNormalUser = true;
    description = "andrey";
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "video"
      "docker"
    ];
  };
  programs.fish.enable = true;

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    xwayland-satellite
    pciutils
    mesa-demos # glxinfo: compare the default renderer and PRIME offload
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    # Save existing mutable Kitty/GTK files when first activating this rice.
    backupFileExtension = "hm-backup";
    extraSpecialArgs = { inherit inputs; };
    users.andrey = import ../../home/andrey.nix;
  };

  # Set this to the release used for the first actual installation and do not
  # change it later. 26.05 is the current stable baseline at preparation time.
  system.stateVersion = "26.05";
}
