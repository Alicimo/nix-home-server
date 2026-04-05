{ config, ... }:
let
  fqdn = "tv.${config.services.globalVars.domain}";
  port = 8409;
in
{
  services.ersatztv = {
    enable = true;
    baseUrl = "/";
    openFirewall = false;
    environment.ETV_UI_PORT = port;
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
