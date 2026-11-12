{ config, ... }:
let
  fqdn = config.services.endpoints.navidrome.hostnames.public;
in {
  services.navidrome = {
    enable = true;
    settings = {
      Address = "0.0.0.0";
      Port = config.services.endpoints.navidrome.tcp.http;
      MusicFolder = "${config.services.globalVars.mediaDir}/Music";
      DataFolder = "${config.services.globalVars.containerDir}/navidrome";
      EnableInsightsCollector = false;
    };
  };

  services.nginx.virtualHosts."${fqdn}" = {
    locations."/".proxyPass = "http://127.0.0.1:${toString config.services.endpoints.navidrome.tcp.http}";
    forceSSL = true;
    enableACME = true;
    acmeRoot = null;
  };
}
