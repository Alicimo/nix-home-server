{ config, ... }:
let
  cfg = config.services.audiobookshelf;
  mediaDirs = [
    "${config.services.globalVars.mediaDir}/Audiobooks"
    "${config.services.globalVars.mediaDir}/Podcasts"
  ];
in
{
  services.endpoints.audiobookshelf.nginx = {
    proxy = true;
    proxyWebsockets = true;
  };

  services.audiobookshelf = {
    enable = true;
    host = "0.0.0.0";
    port = config.services.endpoints.audiobookshelf.tcp.http;
  };

  # Preserve existing ownership and grant access to future files from Libation.
  systemd.tmpfiles.rules = map (
    dir: "A+ ${dir} - - - - u:${cfg.user}:rwX,d:u:${cfg.user}:rwX"
  ) mediaDirs;

  systemd.services.audiobookshelf = {
    requires = [ "systemd-tmpfiles-setup.service" ];
    after = [ "systemd-tmpfiles-setup.service" ];
    unitConfig.RequiresMountsFor = mediaDirs;
    serviceConfig = {
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      ReadWritePaths = mediaDirs;
    };
  };
}
