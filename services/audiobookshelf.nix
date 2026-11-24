{ config, ... }:
let
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
    user = "alistair";
    group = "users";
    host = "0.0.0.0";
    port = config.services.endpoints.audiobookshelf.tcp.http;
  };

  systemd.services.audiobookshelf = {
    unitConfig.RequiresMountsFor = mediaDirs;
    serviceConfig = {
      StateDirectoryMode = "0700";
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      ReadWritePaths = mediaDirs;
    };
  };
}
