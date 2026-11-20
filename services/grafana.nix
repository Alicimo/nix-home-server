{ config, ... }:
let
  endpoint = config.services.endpoints.grafana;
in
{
  services.endpoints.grafana.nginx = {
    proxy = true;
    proxyWebsockets = true;
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        domain = endpoint.hostnames.public;
        http_port = endpoint.tcp.http;
      };
      # Restore the original key if reusing an existing Grafana database.
      security.secret_key = "$__file{/etc/nixos/secrets/grafana-secret-key}";
    };
  };
}
