{
  config,
  lib,
  pkgs,
  ...
}:

let
  colors = (import ../theme.nix).colors;
  kitty = lib.getExe pkgs.kitty;
  browser = lib.getExe pkgs.firefox;
  files = lib.getExe pkgs.nautilus;
  niri = lib.getExe pkgs.niri;
  noctalia = lib.getExe config.programs.noctalia.package;
  xwaylandSatellite = lib.getExe pkgs.xwayland-satellite;

  ocrRegion = pkgs.writeShellApplication {
    name = "ocr-region";
    runtimeInputs = with pkgs; [ grim slurp tesseract wl-clipboard ];
    text = ''
      geometry="$(slurp)" || exit 0
      image="$(mktemp --suffix=.png)"
      trap 'rm -f "$image"' EXIT
      grim -g "$geometry" "$image"
      tesseract "$image" stdout -l ukr+eng+rus 2>/dev/null | wl-copy
    '';
  };

  recordRegion = pkgs.writeShellApplication {
    name = "record-region";
    runtimeInputs = with pkgs; [ slurp wf-recorder coreutils xdg-user-dirs ];
    text = ''
      pid_file="''${XDG_RUNTIME_DIR:-/tmp}/niri-record-region.pid"
      if [ -s "$pid_file" ] && kill -0 "$(cat "$pid_file")" 2>/dev/null; then
        kill -INT "$(cat "$pid_file")"
        rm -f "$pid_file"
        exit 0
      fi

      geometry="$(slurp)" || exit 0
      video_dir="$(xdg-user-dir VIDEOS)"
      if [ -z "$video_dir" ]; then video_dir="$HOME/Videos"; fi
      mkdir -p "$video_dir"
      wf-recorder -g "$geometry" -f "$video_dir/recording-$(date +%Y%m%d-%H%M%S).mp4" &
      printf '%s\n' "$!" > "$pid_file"
    '';
  };

  niriConfig = pkgs.writeTextFile {
    name = "niri-config.kdl";
    checkPhase = ''
      ${niri} validate --config "$out"
    '';
    text = ''
      // Generated declaratively by Home Manager. Niri live-reloads this file.
      input {
          keyboard {
              xkb {
                  layout "us,ua,ru"
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
          gaps 14
          center-focused-column "never"
          default-column-width { proportion 0.5; }
          preset-column-widths {
              proportion 0.33333
              proportion 0.5
              proportion 0.66667
              proportion 1.0
          }
          focus-ring { off; }
          border {
              on
              width 2
              active-color "${colors.primary}"
              inactive-color "${colors.inactive_border}"
          }
      }

      overview {
          backdrop-color "${colors.background}"
      }

      cursor {
          xcursor-theme "Quintom_Ink"
          xcursor-size 24
      }

      xwayland-satellite {
          path "${xwaylandSatellite}"
      }

      spawn-at-startup "${noctalia}"
      window-rule {
          geometry-corner-radius 12
          clip-to-geometry true
      }

      // Keep wallpaper details visible through Kitty and Emacs.
      window-rule {
          exclude app-id="^kitty$"
          exclude app-id="^emacs$"
          background-effect {
              blur true
              xray true
              noise 0.05
              saturation 2.4
          }
      }

      window-rule {
          match app-id="^kitty$"
          draw-border-with-background false
      }

      window-rule {
          match app-id="^emacs$"
          draw-border-with-background false
      }

      layer-rule {
          match namespace="^noctalia-(bar-[^\"]+|notification|dock|panel)$"
          background-effect {
              blur true
              xray false
              noise 0.05
              saturation 2.6
          }
      }

      blur {
          passes 3
          offset 5.0
          noise 0.04
          saturation 1.8
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
          Mod+Return { spawn "${kitty}"; }
          Mod+T { spawn "${kitty}"; }
          Mod+B { spawn "${browser}"; }
          Mod+E { spawn "${files}"; }
          Mod+Q { close-window; }
          Mod+Shift+Q hotkey-overlay-title="Power menu" { spawn "${noctalia}" "msg" "panel-toggle" "session"; }
          Ctrl+Alt+Delete { quit; }
          Mod+Shift+Escape { show-hotkey-overlay; }

          // Noctalia panels.
          Mod+Space { spawn "${noctalia}" "msg" "panel-toggle" "launcher"; }
          Mod+S { spawn "${noctalia}" "msg" "panel-toggle" "control-center"; }
          Mod+Comma { spawn "${noctalia}" "msg" "settings-toggle"; }
          Mod+V { spawn "${noctalia}" "msg" "panel-toggle" "clipboard"; }
          Mod+Alt+L { spawn "${noctalia}" "msg" "session" "lock"; }
          Mod+Shift+Return { spawn "${noctalia}" "msg" "settings-open" "wallpaper"; }
          Alt+Tab { spawn "${noctalia}" "msg" "window-switcher"; }
          Mod+Alt+T { spawn "${noctalia}" "msg" "theme-mode-toggle"; }

          Mod+Shift+S { spawn "${noctalia}" "msg" "screenshot-region"; }
          Mod+Shift+T { spawn "${lib.getExe ocrRegion}"; }
          Mod+Shift+R { spawn "${lib.getExe recordRegion}"; }
          Mod+Tab { toggle-overview; }

          XF86AudioRaiseVolume { spawn "${noctalia}" "msg" "volume-up"; }
          XF86AudioLowerVolume { spawn "${noctalia}" "msg" "volume-down"; }
          XF86AudioMute { spawn "${noctalia}" "msg" "volume-mute"; }
          XF86AudioMicMute { spawn "${noctalia}" "msg" "mic-mute"; }
          XF86AudioNext { spawn "${noctalia}" "msg" "media" "next"; }
          XF86AudioPrev { spawn "${noctalia}" "msg" "media" "previous"; }
          XF86AudioPlay { spawn "${noctalia}" "msg" "media" "toggle"; }
          XF86AudioPause { spawn "${noctalia}" "msg" "media" "pause"; }
          XF86AudioStop { spawn "${noctalia}" "msg" "media" "stop"; }
          XF86MonBrightnessUp { spawn "${noctalia}" "msg" "brightness-up"; }
          XF86MonBrightnessDown { spawn "${noctalia}" "msg" "brightness-down"; }

          Mod+H { focus-column-left; }
          Mod+Left { focus-column-left; }
          Mod+J { focus-window-down; }
          Mod+Down { focus-window-down; }
          Mod+K { focus-window-up; }
          Mod+Up { focus-window-up; }
          Mod+L { focus-column-right; }
          Mod+Right { focus-column-right; }
          Mod+Shift+H { move-column-left; }
          Mod+Shift+L { move-column-right; }
          Mod+Ctrl+H { move-column-left; }
          Mod+Ctrl+Left { move-column-left; }
          Mod+Ctrl+L { move-column-right; }
          Mod+Ctrl+Right { move-column-right; }
          Mod+Ctrl+K { move-window-up; }
          Mod+Ctrl+Up { move-window-up; }
          Mod+Ctrl+J { move-window-down; }
          Mod+Ctrl+Down { move-window-down; }
          Mod+Home { focus-column-first; }
          Mod+End { focus-column-last; }
          Mod+Ctrl+Home { move-column-to-first; }
          Mod+Ctrl+End { move-column-to-last; }
          Mod+R { switch-preset-column-width; }
          Mod+Alt+R { switch-preset-column-width-back; }
          Mod+C { center-column; }
          Mod+Ctrl+C { center-visible-columns; }
          Mod+Ctrl+F { expand-column-to-available-width; }
          Mod+W { toggle-column-tabbed-display; }
          Mod+F { fullscreen-window; }
          Mod+Shift+F { maximize-column; }
          Mod+M { maximize-window-to-edges; }
          Mod+Shift+Space { toggle-window-floating; }
          Mod+Alt+V { switch-focus-between-floating-and-tiling; }
          Mod+BracketLeft { consume-or-expel-window-left; }
          Mod+BracketRight { consume-or-expel-window-right; }
          Mod+Alt+Comma { consume-window-into-column; }
          Mod+Period { expel-window-from-column; }
          Mod+Minus { set-column-width "-10%"; }
          Mod+Equal { set-column-width "+10%"; }
          Mod+Shift+Minus { set-window-height "-10%"; }
          Mod+Shift+Equal { set-window-height "+10%"; }
          Mod+Ctrl+R { reset-window-height; }
          Mod+Shift+Left { focus-monitor-left; }
          Mod+Shift+Right { focus-monitor-right; }
          Mod+Shift+Up { focus-monitor-up; }
          Mod+Shift+Down { focus-monitor-down; }
          Mod+Ctrl+Shift+Left { move-column-to-monitor-left; }
          Mod+Ctrl+Shift+Right { move-column-to-monitor-right; }
          Mod+Ctrl+Shift+Up { move-column-to-monitor-up; }
          Mod+Ctrl+Shift+Down { move-column-to-monitor-down; }
          Mod+WheelScrollDown cooldown-ms=150 { focus-workspace-down; }
          Mod+WheelScrollUp cooldown-ms=150 { focus-workspace-up; }
          Mod+Ctrl+WheelScrollDown cooldown-ms=150 { move-column-to-workspace-down; }
          Mod+Ctrl+WheelScrollUp cooldown-ms=150 { move-column-to-workspace-up; }
          Mod+O { focus-workspace-previous; }
          Mod+Shift+P { power-off-monitors; }
          Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }

          Ctrl+Shift+2 { screenshot-screen; }
          Ctrl+Shift+3 { screenshot-window; }

          Mod+1 { focus-workspace 1; }
          Mod+2 { focus-workspace 2; }
          Mod+3 { focus-workspace 3; }
          Mod+4 { focus-workspace 4; }
          Mod+5 { focus-workspace 5; }
          Mod+6 { focus-workspace 6; }
          Mod+7 { focus-workspace 7; }
          Mod+8 { focus-workspace 8; }
          Mod+9 { focus-workspace 9; }
          Mod+Shift+1 { move-column-to-workspace 1; }
          Mod+Shift+2 { move-column-to-workspace 2; }
          Mod+Shift+3 { move-column-to-workspace 3; }
          Mod+Shift+4 { move-column-to-workspace 4; }
          Mod+Shift+5 { move-column-to-workspace 5; }
          Mod+Shift+6 { move-column-to-workspace 6; }
          Mod+Shift+7 { move-column-to-workspace 7; }
          Mod+Shift+8 { move-column-to-workspace 8; }
          Mod+Shift+9 { move-column-to-workspace 9; }
          Mod+Ctrl+1 { move-column-to-workspace 1; }
          Mod+Ctrl+2 { move-column-to-workspace 2; }
          Mod+Ctrl+3 { move-column-to-workspace 3; }
          Mod+Ctrl+4 { move-column-to-workspace 4; }
          Mod+Ctrl+5 { move-column-to-workspace 5; }
          Mod+Ctrl+6 { move-column-to-workspace 6; }
          Mod+Ctrl+7 { move-column-to-workspace 7; }
          Mod+Ctrl+8 { move-column-to-workspace 8; }
          Mod+Ctrl+9 { move-column-to-workspace 9; }
      }
    '';
  };
in
{
  home.packages = [ ocrRegion recordRegion ];
  xdg.configFile."niri/config.kdl".source = niriConfig;

  # The source is validated at build time, before system/HM activation.
}
