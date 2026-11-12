{ config, ... }:
let
  dir="${config.services.globalVars.containerDir}/audiobookshelf";
  port = toString config.services.endpoints.audiobookshelf.tcp.http;
in {
  virtualisation.oci-containers.containers = {
     audiobookshelf = {
      image = "ghcr.io/advplyr/audiobookshelf";
      volumes = [
        "${dir}/config:/config"
        "${dir}/metadata:/metadata"
        "${config.services.globalVars.mediaDir}/Audiobooks:/audiobooks"
        "${config.services.globalVars.mediaDir}/Podcasts:/podcasts"
      ];
      ports = [ "${port}:80" ];
    };
  };

  services.nginx.virtualHosts."${config.services.endpoints.audiobookshelf.hostnames.lan}".locations."/" = {
    proxyPass = "http://127.0.0.1:${port}";
    proxyWebsockets = true;
  };
}
