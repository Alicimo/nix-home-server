{ config, ... }:
let
  fqdn = "music.${config.services.globalVars.domain}";
in {
  services.navidrome = {
    enable = true;
    settings = {
      Address = "0.0.0.0";
      Port = 4533;
      MusicFolder = "${config.services.globalVars.mediaDir}/Music";
      DataFolder = "${config.services.globalVars.containerDir}/navidrome";
      EnableInsightsCollector = false;
    };
  };

  services.nginx.virtualHosts."${fqdn}" = {
    locations."/".proxyPass = "http://127.0.0.1:4533";
    forceSSL = true;
    enableACME = true;
    acmeRoot = null;
  };
}
