{ den, ... }: {
  den.aspects.apps-devices = {
    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        uhk-agent ddcutil ddcui system-config-printer
      ];
    };
  };
}
