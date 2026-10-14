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
    package = pkgs.quintom-cursor-theme;
    name = "Quintom_Ink";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
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
      serif = [ "Inter" ];
      sansSerif = [ "Inter" ];
      monospace = [ "JetBrainsMono Nerd Font" ];
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Tela-black-dark";
      package = pkgs.tela-icon-theme;
    };
    font.name = "Inter";
    font.size = 12;
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
  };

  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 13;
    };
    settings = theme.kitty // {
      background_opacity = "0.52";
      cursor_shape = "beam";
      cursor_trail = 1;
      window_margin_width = 14;
      hide_window_decorations = "yes";
      confirm_os_window_close = 0;
    };
    extraConfig = ''
      include themes/noctalia.conf
    '';
  };

  programs.btop = {
    enable = true;
    settings.theme_background = false;
  };

  xdg.configFile."fastfetch/config.jsonc".source = fastfetchConfig;
}
