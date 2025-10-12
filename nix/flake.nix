{
    description = "MRBOS";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
        
        snowfall-lib = {
          url = "github:snowfallorg/lib";
          inputs.nixpkgs.follows = "nixpkgs";
        };

        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        
        hyprland.url = "github:hyprwm/Hyprland";
        hyprpanel.url = "github:Jas-SinghFSU/HyprPanel";
        catppuccin.url = "github:catppuccin/nix";
    };

    outputs = inputs:
        inputs.snowfall-lib.mkFlake {
            inherit inputs;
            src = ./.;
            snowfall.namespace = "custom";
            channels-config.allowUnfree = true;
        };
}
