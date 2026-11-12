{ config, ... }:
let
  fqdn = config.services.endpoints.pinchflat.hostnames.public;
  mediaDir = "${config.services.globalVars.mediaDir}/YouTube";
  port = config.services.endpoints.pinchflat.tcp.http;
in
{
  services.pinchflat = {
    enable = true;
    port = port;
    mediaDir = mediaDir;
    openFirewall = false;
    selfhosted = true;
  };

  services.nginx.virtualHosts."${fqdn}" = {
    forceSSL = true;
    enableACME = true;
    acmeRoot = null;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      proxyWebsockets = true;
    };
  };
}
