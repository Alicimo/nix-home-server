{ config, pkgs, ... }:
let
  fqdn = config.services.endpoints.opencode.hostnames.public;
  port = config.services.endpoints.opencode.tcp.http;
in
{
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

  services.nginx.virtualHosts."${fqdn}" = {
    forceSSL = true;
    enableACME = true;
    acmeRoot = null;

    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      proxyWebsockets = true;
      extraConfig = ''
        allow 100.64.0.0/10;
        deny all;
      '';
    };
  };
}
