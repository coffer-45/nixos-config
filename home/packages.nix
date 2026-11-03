{ inputs, pkgs, ... }:

let
  # The new nixpkgs derivation requires a Cisco installer that cannot be
  # downloaded automatically. Reuse the already installed package for now.
  ciscoPacketTracer =
    (import inputs.nixpkgsCisco {
      system = pkgs.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    }).cisco-packet-tracer_9;

  # nixpkgs#581099: Discord requests OpenH264 2.5.1, but its asset cache only
  # retains 2.7.0. Remove this override once the fix reaches nixos-unstable.
  discordWithOpenH264Fix = pkgs.discord.override {
    unwrappedDiscord = pkgs.discord.passthru.unwrappedDiscord.overrideAttrs (old: {
      postInstall = (old.postInstall or "") + ''
        core="$out/opt/Discord/modules/discord_desktop_core/core.asar"
        if grep -qF libopenh264-2.5.1-linux64.7.so "$core"; then
          sed -i 's/libopenh264-2\.5\.1-linux64\.7\.so/libopenh264-2.7.0-linux64.8.so/g' "$core"
        fi
      '';
    });
  };
in
{
  home.packages = with pkgs; [
    # Everyday tools
    bat
    btop
    brightnessctl
    eza
    fastfetch
    fd
    file
    fzf
    inxi
    jq
    ncdu
    ripgrep
    tealdeer # `tldr` command
    tree
    tmux
    unzip
    wget
    wl-clipboard
    yt-dlp
    zoxide

    # Development and documents
    codex # OpenAI Codex CLI, managed by Nix (no global npm installation)
    cmake
    clang-tools
    gcc
    gdb
    gnumake
    gh
    graphviz
    lazygit
    lldb
    emacs-pgtk
    gradle
    jdk
    jdt-language-server
    markdownlint-cli
    marksman
    maven
    neovim
    nil
    nixfmt
    nodejs
    inputs.opencodeV2.packages.${pkgs.system}.default
    pandoc
    plantuml
    pyright
    (python3.withPackages (
      ps: with ps; [
        debugpy
        pytest
      ]
    ))
    rustc
    cargo
    rust-analyzer
    shellcheck
    shfmt
    typst
    tinymist
    vscode-langservers-extracted
    yaml-language-server
    dockerfile-language-server
    zathura

    # Multimedia and Wayland utilities
    ffmpeg
    grim
    imagemagick
    mpv
    slurp
    tesseract
    wf-recorder

    # Desktop integration
    # GNOME Disks, GVfs and GNOME Keyring are enabled by the host modules.
    libsecret
    localsend
    nautilus

    # Container tooling (the Docker service is enabled in the host module)
    docker-buildx
    docker-compose
    lazydocker

    # Fonts
    noto-fonts
    noto-fonts-color-emoji
    nerd-fonts.symbols-only
    symbola

    # Applications already used on the current installation
    ciscoPacketTracer
    discordWithOpenH264Fix
    firefox
    obsidian
    obs-studio
    pavucontrol
    telegram-desktop
    vlc
    vscode
  ];
}
