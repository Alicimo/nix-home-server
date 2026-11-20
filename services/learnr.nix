{ config, ... }:
let
  port = config.services.endpoints.learnr.tcp.http;
in
{
  services.endpoints.learnr.nginx = {
    proxy = true;
  };

  services.learnr = {
    enable = true;
    host = "127.0.0.1";
    port = port;
  };
}
