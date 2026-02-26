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
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    _1password-shell-plugins = {
      url = "github:1Password/shell-plugins";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    opnix = {
      url = "github:brizzbuzz/opnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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

      overlays = with inputs; [
        nur.overlays.default
      ];

      systems.modules.nixos =
        let
          nur = inputs.nur.modules.nixos.default;
        in
        [
          nur
        ];

      homes.modules =
        let
          stylix = inputs.stylix.homeModules.stylix;
          niri = inputs.niri.homeModules.niri;
          _1password-shell-plugins = inputs._1password-shell-plugins.hmModules.default;
          zen-browser = inputs.zen-browser.homeModules.twilight;
          opnix = inputs.opnix.homeManagerModules.default;
          dms = inputs.dms.homeModules.dank-material-shell;
        in
        [
          stylix
          niri
          _1password-shell-plugins
          zen-browser
          opnix
          dms
        ];
    };
}
