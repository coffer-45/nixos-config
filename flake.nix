{
  description = "drew's NixOS configuration: niri + Noctalia";

  # Also available during installation, before the host's nix.settings apply.
  nixConfig = {
    extra-substituters = [ "https://noctalia.cachix.org" ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Noctalia v5. The cachix branch tracks a commit with a ready binary cache.
    # Do not make this input follow nixpkgs: that would invalidate its cache.
    noctalia.url = "github:noctalia-dev/noctalia/cachix";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, nixpkgs, ... }:
    {
      packages.x86_64-linux.disko = inputs.disko.packages.x86_64-linux.disko;

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt;

      # Build the actual generated desktop configs, including their validators.
      checks.x86_64-linux =
        let
          home = self.nixosConfigurations.acer-a715-42g.config.home-manager.users.drew;
        in
        {
          niri-config = home.xdg.configFile."niri/config.kdl".source;
          noctalia-config = home.xdg.configFile."noctalia/config.toml".source;
        };

      nixosConfigurations.acer-a715-42g = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [ ./hosts/acer-a715-42g/default.nix ];
      };
    };
}
