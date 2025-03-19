{
  description = "A flake example";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    cunicu = {
      url = "github:cunicu/cunicu";
      #url = "github:ARizzo35/cunicu?ref=fix/nix-overlay";
      #inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, ... }@inputs:

  let
    inherit (inputs.nixpkgs) lib;
    #system = "aarch64-linux";
    system = "x86_64-linux";
    pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [ inputs.cunicu.overlays.default ];
    };
  in
  {
    nixosConfigurations.sample = lib.nixosSystem {
      inherit system;
      modules = [
        { nixpkgs = { inherit system pkgs; }; }
        inputs.cunicu.nixosModules.default
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
