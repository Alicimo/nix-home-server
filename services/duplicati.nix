{ config, ... }:
let
    port = config.services.endpoints.duplicati.tcp.http;
in {
    services.duplicati = {
        enable = true;
        port = port;
        interface = "any";
    };
}
