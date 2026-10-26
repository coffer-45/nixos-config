{ inputs, pkgs, ... }:

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
    cisco-packet-tracer_9
    discord
    firefox
    obsidian
    obs-studio
    pavucontrol
    telegram-desktop
    vlc
    vscode
  ];
}
