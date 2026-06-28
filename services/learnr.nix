{ config, ... }:
let
  fqdn = "learnr.${config.services.globalVars.domain}";
  port = 8016;
in
{
  services.learnr = {
    enable = true;
    host = "127.0.0.1";
    port = port;
  };

  services.nginx.virtualHosts."${fqdn}" = {
    locations."/".proxyPass = "http://127.0.0.1:${toString port}";
    forceSSL = true;
    enableACME = true;
    acmeRoot = null;
  };
}
