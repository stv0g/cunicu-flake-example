{
  description = "A flake example";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    cunicu.url = "github:cunicu/cunicu";
  };

  outputs = { cunicu, nixpkgs, ... }:
  let
    inherit (nixpkgs) lib;
    system = "aarch64-linux";
    pkgs = import nixpkgs {
      inherit system;
      overlays = [
        cunicu.overlays.default
        (final: prev: {
          inherit (cunicu.packages.${system}) cunicu;
        })
      ];
    };
  in
  {
    nixosConfigurations.sample = lib.nixosSystem {
      inherit system;
      modules = [
        cunicu.nixosModules.default
        {
          boot.loader.systemd-boot.enable = true;
          fileSystems."/".device = "/dev/disk/by-label/nixos";

          environment.systemPackages = [ pkgs.cunicu ];

          system.stateVersion = "24.11";
        }
      ];
    };
  };
}
