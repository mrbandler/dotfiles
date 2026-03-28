{
  lib,
  ...
}:

with lib;
{
  imports = [
    (mkAliasOptionModule [ "internal" "cli" "tools" "aerc" ] [ "programs" "aerc" ])
  ];

  config.programs.aerc = {
    enable = true;
    extraConfig = {
      general.unsafe-accounts-conf = true;
      ui = {
        sidebar-width = 25;
        mouse-enabled = true;
        threading-enabled = true;
        fuzzy-complete = true;
        auto-mark-read = true;
        sort = "-r date";
        index-columns = "date<20,name<20,flags>4,subject<*";
      };
      viewer = {
        pager = "less -R";
        alternatives = "text/plain,text/html";
        header-layout = "From|To,Cc|Bcc,Date,Subject";
        parse-http-links = true;
      };
      compose = {
        header-layout = "To|From,Subject";
        reply-to-self = false;
        empty-subject-warning = true;
        no-attachment-warning = "^[^>]*attach";
      };
      filters = {
        "text/plain" = "colorize";
        "text/html" = "html | colorize";
        "text/calendar" = "calendar";
        "message/delivery-status" = "colorize";
        "message/rfc822" = "colorize";
      };
    };
  };
}
