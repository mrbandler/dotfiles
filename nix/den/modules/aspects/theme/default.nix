{ den, inputs, ... }: {
  den.aspects.theme = {
    homeManager = { pkgs, lib, config, ... }: {
      imports = [ inputs.stylix.homeModules.stylix ];

      stylix = {
        enable = true;

        image = lib.mkDefault ./wallpaper.png;
        base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
        polarity = lib.mkDefault "dark";

        fonts = {
          monospace = {
            package = pkgs.nerd-fonts.jetbrains-mono;
            name = "JetBrainsMono Nerd Font";
          };

          sizes = {
            applications = 12;
            terminal = 12;
            desktop = 10;
            popups = 10;
          };
        };

        cursor = {
          package = pkgs.bibata-cursors;
          name = "Bibata-Modern-Classic";
          size = 24;
        };

        opacity = {
          applications = 1.0;
          terminal = 0.95;
          desktop = 1.0;
          popups = 1.0;
        };
      };
    };
  };
}
