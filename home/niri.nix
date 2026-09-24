{ pkgs, ... }:

let
  niriConfig = pkgs.writeTextFile {
    name = "niri-config.kdl";
    checkPhase = ''
      ${pkgs.niri}/bin/niri validate --config "$out"
    '';
    text = ''
      // Generated declaratively by Home Manager. Niri live-reloads this file.
      input {
          keyboard {
              xkb {
                  layout "us,ua"
                  options "grp:alt_shift_toggle"
              }
          }

          touchpad {
              tap
              dwt
              natural-scroll
          }

          focus-follows-mouse max-scroll-amount="0%"
      }

      layout {
          gaps 10
          center-focused-column "never"
          default-column-width { proportion 0.5; }
          preset-column-widths {
              proportion 0.33333
              proportion 0.5
              proportion 0.66667
          }
          focus-ring { off; }
          border {
              on
              width 2
              active-color "#89b4fa"
              inactive-color "#45475a"
          }
      }

      overview {
          backdrop-color "#1e1e2e"
      }

      spawn-at-startup "noctalia"
      window-rule {
          geometry-corner-radius 12
          clip-to-geometry true
      }

      window-rule {
          match app-id="dev.noctalia.Noctalia"
          open-floating true
          default-column-width { fixed 1080; }
          default-window-height { fixed 920; }
      }

      debug {
          // Recommended by Noctalia for notification actions/window activation.
          // https://docs.noctalia.dev/noctalia/compositor-settings/niri/
          honor-xdg-activation-with-invalid-serial
      }

      binds {
          Mod+Return { spawn "alacritty"; }
          Mod+Q { close-window; }
          Mod+Shift+Q { quit; }

          // Noctalia panels.
          Mod+Space { spawn "noctalia" "msg" "panel-toggle" "launcher"; }
          Mod+S { spawn "noctalia" "msg" "panel-toggle" "control-center"; }
          Mod+Comma { spawn "noctalia" "msg" "settings-toggle"; }
          Alt+Tab { spawn "noctalia" "msg" "window-switcher"; }

          XF86AudioRaiseVolume { spawn "noctalia" "msg" "volume-up"; }
          XF86AudioLowerVolume { spawn "noctalia" "msg" "volume-down"; }
          XF86AudioMute { spawn "noctalia" "msg" "volume-mute"; }
          XF86MonBrightnessUp { spawn "noctalia" "msg" "brightness-up"; }
          XF86MonBrightnessDown { spawn "noctalia" "msg" "brightness-down"; }

          Mod+H { focus-column-left; }
          Mod+J { focus-window-down; }
          Mod+K { focus-window-up; }
          Mod+L { focus-column-right; }
          Mod+Shift+H { move-column-left; }
          Mod+Shift+L { move-column-right; }

          Mod+1 { focus-workspace 1; }
          Mod+2 { focus-workspace 2; }
          Mod+3 { focus-workspace 3; }
          Mod+4 { focus-workspace 4; }
          Mod+5 { focus-workspace 5; }
          Mod+Shift+1 { move-column-to-workspace 1; }
          Mod+Shift+2 { move-column-to-workspace 2; }
          Mod+Shift+3 { move-column-to-workspace 3; }
          Mod+Shift+4 { move-column-to-workspace 4; }
          Mod+Shift+5 { move-column-to-workspace 5; }
      }
    '';
  };
in
{
  xdg.configFile."niri/config.kdl".source = niriConfig;

  # The source is validated at build time, before system/HM activation.
}
