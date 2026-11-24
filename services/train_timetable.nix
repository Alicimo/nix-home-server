{ config, inputs, ... }:
let
  endpoint = config.services.endpoints.train-timetable;
in
{
  imports = [
    inputs.train-timetable.nixosModules.default
  ];

  services.endpoints.train-timetable.nginx.proxy = true;

  services.train-updates = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = endpoint.tcp.http;
    hafasUserAgent = "train-updates (https://${endpoint.hostnames.public})";
  };

  # The dashboard can change Telegram credentials without authentication.
  services.nginx.virtualHosts.${endpoint.hostnames.public}.locations."/".extraConfig = ''
    allow 100.64.0.0/10;
    allow fd7a:115c:a1e0::/48;
    deny all;
  '';
}
