{ config, pkgs, ... }:
let
  port = config.services.endpoints.opencode.tcp.http;
in
{
  services.endpoints.opencode.nginx = {
    proxy = true;
    proxyWebsockets = true;
  };

  systemd.services.opencode-web = {
    description = "OpenCode web UI";
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      User = "alistair";
      WorkingDirectory = "/home/alistair";
      ExecStart = "${pkgs.unstable.pkgs.opencode}/bin/opencode web --hostname 127.0.0.1 --port ${toString port}";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
}
