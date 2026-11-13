{ config, ... }:
let
    port = config.services.endpoints.duplicati.tcp.http;
in {
    services.duplicati = {
        enable = true;
        port = port;
        interface = "any";
    };
  services.nginx.virtualHosts."${config.services.endpoints.duplicati.hostnames.public}" = {
    forceSSL = true;
    enableACME = true;
    acmeRoot = null;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      proxyWebsockets = true;
    };
  };
}
