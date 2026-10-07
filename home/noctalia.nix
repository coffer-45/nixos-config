{ pkgs, ... }:

let
  wallpaper = ./assets/wallpapers/rainy-pixel-street.png;
  settings = pkgs.writeText "noctalia-pixel-street.toml" (
    builtins.replaceStrings [ "@WALLPAPER@" ] [ "${wallpaper}" ]
      (builtins.readFile ./noctalia/config.toml)
  );
in
{
  programs.noctalia = {
    enable = true;
    inherit settings;
  };
}
