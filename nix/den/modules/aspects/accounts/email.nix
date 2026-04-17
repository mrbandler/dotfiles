{ den, ... }: {
  den.aspects.accounts-email = {
    homeManager = { lib, config, ... }:
      with lib;
      let
        aercEnabled = config.programs.aerc.enable or false;
        himalayaEnabled = config.programs.himalaya.enable or false;

        mkEmailAccountOpts = { description }: {
          enable = mkOption { type = types.bool; default = false; };
          address = mkOption { type = types.str; default = ""; };
          aliases = mkOption { type = types.listOf types.str; default = []; };
          realName = mkOption { type = types.str; default = ""; };
          passwordCommand = mkOption { type = types.str; default = ""; };
        };

        protonCfg = config.internal.accounts.email.proton;
        googleCfg = config.internal.accounts.email.google;
      in
      {
        options.internal.accounts.email = {
          proton = mkEmailAccountOpts { description = "Proton Mail"; };
          google = mkEmailAccountOpts { description = "Google Mail"; };
        };

        config = mkMerge [
          (mkIf protonCfg.enable {
            accounts.email.accounts.proton = {
              primary = true;
              address = protonCfg.address;
              aliases = protonCfg.aliases;
              realName = protonCfg.realName;
              userName = protonCfg.address;
              passwordCommand = protonCfg.passwordCommand;
              imap = { host = "127.0.0.1"; port = 1143; tls = { enable = true; useStartTls = true; }; };
              smtp = { host = "127.0.0.1"; port = 1025; tls = { enable = true; useStartTls = true; }; };
              folders = { inbox = "INBOX"; sent = "Sent"; drafts = "Drafts"; trash = "Trash"; };
              aerc = { enable = aercEnabled; smtpAuth = "login"; extraAccounts = { source = "imap+insecure://${protonCfg.address}@127.0.0.1:1143"; outgoing = "smtp+insecure+login://${protonCfg.address}@127.0.0.1:1025"; }; };
              himalaya = mkIf himalayaEnabled { enable = true; };
            };
          })
          (mkIf googleCfg.enable {
            accounts.email.accounts.google = {
              address = googleCfg.address;
              aliases = googleCfg.aliases;
              realName = googleCfg.realName;
              userName = googleCfg.address;
              passwordCommand = googleCfg.passwordCommand;
              imap = { host = "imap.gmail.com"; port = 993; };
              smtp = { host = "smtp.gmail.com"; port = 587; tls = { enable = true; useStartTls = true; }; };
              folders = { inbox = "INBOX"; sent = "[Gmail]/Sent Mail"; drafts = "[Gmail]/Drafts"; trash = "[Gmail]/Trash"; };
              aerc = { enable = aercEnabled; smtpAuth = "plain"; };
              himalaya = mkIf himalayaEnabled { enable = true; };
            };
          })
        ];
      };
  };
}
