{ den, inputs, ... }: {
  den.aspects.desktop-input = {
    homeManager = { config, ... }: {
      imports = [ inputs.xremap.homeManagerModules.default ];

      services.xremap = {
        enable = true;
        withWlroots = true;
        config = {
          modmap = [
            {
              name = "Super tap to launcher";
              remap = {
                Super_L = {
                  held = "Super_L";
                  alone = "Prog1";
                  alone_timeout_millis = 200;
                };
              };
            }
          ];
          keymap = [];
        } // config.internal.desktop.core.keybindings.extraXremap;
      };
    };
  };
}
