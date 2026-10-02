{ ... }:

{
  # Noctalia v5 accepts a TOML path directly. Keeping the application config
  # as TOML makes a merged GUI export easy to review and commit.
  programs.noctalia = {
    enable = true;
    settings = ./noctalia/config.toml;
  };
}
