{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Everyday tools
    alacritty
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
    cmake
    gcc
    gh
    lazygit
    neovim
    nodejs
    pandoc
    python3
    rustc
    cargo
    typst
    tinymist
    texlive.combined.scheme-full
    zathura

    # Multimedia and Wayland utilities
    ffmpeg
    grim
    imagemagick
    mpv
    slurp

    # Desktop integration
    gnome-disk-utility
    gnome-keyring
    gvfs
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

    # Applications already used on the current installation
    discord
    firefox
    obsidian
    obs-studio
    pavucontrol
    vlc
    vscode
  ];
}
