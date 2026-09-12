{
  description = "drew's NixOS configuration: niri + Noctalia";

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

  outputs = inputs@{ self, nixpkgs, ... }: {
    packages.x86_64-linux.disko = inputs.disko.packages.x86_64-linux.disko;

    nixosConfigurations.acer-a715-42g = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [ ./hosts/acer-a715-42g/default.nix ];
    };
  };
}
