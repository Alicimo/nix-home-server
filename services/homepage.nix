{ config, lib, ... }:
let
  endpoint = config.services.endpoints.homepage;
  webEndpoints = lib.filter (entry: entry.name != "homepage") config.services.webEndpoints;
in
{
  services.homepage-dashboard = {
    enable = true;
    listenPort = endpoint.tcp.http;
    allowedHosts = endpoint.hostnames.public;
    openFirewall = false;
    settings = {
      title = config.networking.hostName;
      layout.Services = {
        style = "row";
        columns = 4;
      };
    };
    services = [
      {
        Services = map (entry: {
          ${entry.name}.href = entry.url;
        }) webEndpoints;
      }
    ];
    widgets = [
      {
        resources = {
          label = config.networking.hostName;
          cpu = true;
          memory = true;
          uptime = true;
        };
      }
      {
        resources = {
          label = "Storage";
          disk = [
            "/"
            config.services.globalVars.dataDir
          ];
          expanded = true;
        };
      }
    ];
  };

  systemd.services.homepage-dashboard.environment.HOSTNAME = "127.0.0.1";

  services.endpoints.homepage.nginx.enable = true;
  services.nginx.virtualHosts.${endpoint.hostnames.public}.locations."/".extraConfig = ''
    allow 100.64.0.0/10;
    allow fd7a:115c:a1e0::/48;
    deny all;
  '';
}
