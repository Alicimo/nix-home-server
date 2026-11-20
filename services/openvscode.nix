{ config, ... }:
{
  services.openvscode-server = {
    enable = true;
    port = config.services.endpoints.openvscode.tcp.http;
    withoutConnectionToken = true;
    user = "alistair";
    host = "127.0.0.1";
  };
  services.endpoints.openvscode.nginx = {
    proxy = true;
    proxyWebsockets = true;
  };
}
