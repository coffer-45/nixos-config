{ pkgs, ... }:

let
  wallpaper = ./assets/wallpapers/rainy-pixel-street.png;
  wallpaperDirectory = ./assets/wallpapers;
  settings = pkgs.writeText "noctalia-pixel-street.toml" (
    builtins.replaceStrings [ "@WALLPAPER@" "@WALLPAPER_DIRECTORY@" ] [ "${wallpaper}" "${wallpaperDirectory}" ]
      (builtins.readFile ./noctalia/config.toml)
  );
in
{
  programs.noctalia = {
    enable = true;
    inherit settings;
  };
}
