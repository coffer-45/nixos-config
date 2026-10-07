{ pkgs, ... }:

{
  home.pointerCursor = {
    enable = true;
    package = pkgs.catppuccin-cursors.mochaLavender;
    name = "catppuccin-mocha-lavender-cursors";
    size = 32;
    gtk.enable = true;
  };

  xdg.dataFile = {
    "fonts/CozetteVector.ttf".source = ./assets/fonts/CozetteVector.ttf;
    "fonts/PixeloidSans.ttf".source = ./assets/fonts/PixeloidSans.ttf;
    "fonts/PixeloidMono.ttf".source = ./assets/fonts/PixeloidMono.ttf;
    "icons/pixora".source = ./assets/icons/pixora;
    "icons/pixora-dark".source = ./assets/icons/pixora-dark;
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [ "Pixeloid Sans" ];
      monospace = [ "CozetteVector" ];
    };
  };

  gtk = {
    enable = true;
    iconTheme.name = "pixora";
    font.name = "Pixeloid Sans";
    font.size = 10;
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
  };

  programs.kitty = {
    enable = true;
    font = {
      name = "CozetteVector";
      size = 13;
    };
    settings = {
      background = "#181922";
      foreground = "#fafafa";
      cursor = "#b9b1cc";
      selection_background = "#978ab3";
      selection_foreground = "#181922";
      color0 = "#181922";
      color1 = "#e36b78";
      color2 = "#8eaf73";
      color3 = "#d8b56b";
      color4 = "#b9b1cc";
      color5 = "#978ab3";
      color6 = "#72b7b0";
      color7 = "#fafafa";
      color8 = "#b4b5b7";
      color9 = "#f58b98";
      color10 = "#aacf93";
      color11 = "#efd18b";
      color12 = "#b9b1cc";
      color13 = "#978ab3";
      color14 = "#92d7d0";
      color15 = "#fafafa";
      background_opacity = "0.8";
      transparent_background_colors = "#181922@0.8 #242531@0.8";
      window_padding_width = 12;
      hide_window_decorations = "yes";
      confirm_os_window_close = 0;
    };
  };

  programs.btop = {
    enable = true;
    settings.theme_background = false;
  };

  xdg.configFile."fastfetch/config.jsonc".source = ./fastfetch/config.jsonc;
}
