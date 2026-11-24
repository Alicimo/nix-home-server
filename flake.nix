{
  description = "NixOS configuration for tiefenbacher";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    learnr.url = "github:Alicimo/learnr";
    train-timetable = {
      url = "github:Alicimo/train_timetable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations.tiefenbacher = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          inputs.learnr.nixosModules.default
          ./configuration.nix
        ];
      };
    };
}
