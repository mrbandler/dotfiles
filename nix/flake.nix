{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs?ref=nixos-25.11";
    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    _1password-shell-plugins.url = "github:1Password/shell-plugins";
  };

  outputs =
    inputs:
    let
      lib = inputs.snowfall-lib.mkLib {
        inherit inputs;
        src = ./.;
      };
    in
    lib.mkFlake {
      inherit inputs;

      src = ./.;
      channels-config.allowUnfree = true;
      snowfall.namespace = "internal";

      # systems.modules.nixos =
      #   let
      #     stylix = inputs.stylix.nixosModules.stylix;
      #   in
      #   [
      #     stylix
      #   ];

      homes.modules =
        let
          stylix = inputs.stylix.homeModules.stylix;
          niri = inputs.niri.homeModules.niri;
          _1password-shell-plugins = inputs._1password-shell-plugins.hmModules.default;
        in
        [
          stylix
          niri
          _1password-shell-plugins
        ];
    };
}
