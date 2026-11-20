{ config, ... }:
let
    port = config.services.endpoints.duplicati.tcp.http;
in {
  services.endpoints.duplicati.nginx = {
    proxy = true;
    proxyWebsockets = true;
  };

    services.duplicati = {
        enable = true;
        port = port;
        interface = "any";
    };
}
