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
  services.nginx.virtualHosts = {
    "${config.services.endpoints.uptime-kuma.hostnames.lan}".locations."/".proxyPass = "http://127.0.0.1:${port}";
    "${config.services.endpoints.uptime-kuma.hostnames.root}".locations."/".proxyPass = "http://127.0.0.1:${port}";
  };
}
