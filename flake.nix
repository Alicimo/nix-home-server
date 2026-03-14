{
  description = "NixOS configuration for tiefenbacher";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations.tiefenbacher = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
        ];
      };
    };
}
