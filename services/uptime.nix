{ config, ... }:
let
  port = toString config.services.endpoints.uptime-kuma.tcp.http;
in {
  services.uptime-kuma = {
    enable = true;
    settings = {
      PORT=port;
    };
  };
}
