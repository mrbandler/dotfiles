{ lib, den, ... }: {
  den.default.nixos.system.stateVersion = "25.11";
  den.default.homeManager.home.stateVersion = "25.11";

  # Enable home-manager for all users by default
  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  # Enable host<->user provides (mutual config contributions)
  den.ctx.user.includes = [ den._.mutual-provider ];
}
