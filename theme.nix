let
  colors = {
    background = "#181922";
    surface_variant = "#242531";
    foreground = "#fafafa";
    muted = "#b4b5b7";
    primary = "#b9b1cc";
    secondary = "#e36b78";
    tertiary = "#72b7b0";
    error = "#f58b98";
    outline = "#978ab3";
    shadow = "#0b0c12";
    inactive_border = "#302b35";
    green = "#8eaf73";
    yellow = "#d8b56b";
    bright_green = "#aacf93";
    bright_yellow = "#efd18b";
    bright_cyan = "#92d7d0";
  };

  # Fastfetch expects ANSI RGB components, while the other apps use hex.
  ansi = hex:
    let
      byte = offset: (builtins.fromTOML "value = 0x${builtins.substring offset 2 hex}").value;
    in
    "38;2;${toString (byte 1)};${toString (byte 3)};${toString (byte 5)}";
in
{
  inherit colors ansi;

  greeter = {
    primary = colors.primary;
    on_primary = colors.background;
    secondary = colors.secondary;
    on_secondary = colors.background;
    tertiary = colors.tertiary;
    on_tertiary = colors.background;
    error = colors.error;
    on_error = colors.background;
    surface = colors.background;
    on_surface = colors.foreground;
    surface_variant = colors.surface_variant;
    on_surface_variant = colors.muted;
    outline = colors.outline;
    shadow = colors.shadow;
    hover = colors.outline;
    on_hover = colors.background;
  };

  kitty = {
    background = colors.background;
    foreground = colors.foreground;
    cursor = colors.primary;
    selection_background = colors.outline;
    selection_foreground = colors.background;
    color0 = colors.background;
    color1 = colors.secondary;
    color2 = colors.green;
    color3 = colors.yellow;
    color4 = colors.primary;
    color5 = colors.outline;
    color6 = colors.tertiary;
    color7 = colors.foreground;
    color8 = colors.muted;
    color9 = colors.error;
    color10 = colors.bright_green;
    color11 = colors.bright_yellow;
    color12 = colors.primary;
    color13 = colors.outline;
    color14 = colors.bright_cyan;
    color15 = colors.foreground;
    transparent_background_colors = "${colors.background}@0.8 ${colors.surface_variant}@0.8";
  };
}
