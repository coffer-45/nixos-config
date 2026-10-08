{ pkgs, ... }:

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
    gcc
    gh
    lazygit
    emacs-pgtk
    neovim
    nodejs
    pandoc
    python3
    rustc
    cargo
    typst
    tinymist
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

    # Applications already used on the current installation
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
