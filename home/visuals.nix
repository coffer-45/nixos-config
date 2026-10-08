{ pkgs, ... }:

let
  theme = import ../theme.nix;
  inherit (theme) colors ansi;
  fastfetchConfig = pkgs.writeText "fastfetch.jsonc" (
    builtins.replaceStrings
      [ "@PRIMARY@" "@OUTLINE@" "@SECONDARY@" "@FOREGROUND@" ]
      [ (ansi colors.primary) (ansi colors.outline) (ansi colors.secondary) (ansi colors.foreground) ]
      (builtins.readFile ./fastfetch/config.jsonc)
  );
in
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
    settings = theme.kitty // {
      background_opacity = "0.8";
      window_padding_width = 12;
      hide_window_decorations = "yes";
      confirm_os_window_close = 0;
    };
  };

  programs.btop = {
    enable = true;
    settings.theme_background = false;
  };

  xdg.configFile."fastfetch/config.jsonc".source = fastfetchConfig;
}
