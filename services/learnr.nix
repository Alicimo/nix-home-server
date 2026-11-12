{ config, ... }:
let
  fqdn = config.services.endpoints.learnr.hostnames.public;
  port = config.services.endpoints.learnr.tcp.http;
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
