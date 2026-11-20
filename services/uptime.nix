{ config, ... }:
let
  port = toString config.services.endpoints.uptime-kuma.tcp.http;
in {
  services.endpoints.uptime-kuma.nginx = {
    proxy = true;
    proxyWebsockets = true;
  };

  services.uptime-kuma = {
    enable = true;
    settings = {
      PORT=port;
    };
  };
}
