{
  config,
  lib,
  ...
}:
let
  endpoint = config.services.endpoints.gatus;
  webEndpoints = lib.filterAttrs (
    name: entry:
    !(builtins.elem name [
      "gatus"
      "uptime-kuma"
    ])
    && entry.enable
    && entry.hostnames ? public
    && builtins.hasAttr entry.hostnames.public config.services.nginx.virtualHosts
  ) config.services.endpoints;
in
{
  services.gatus = {
    enable = true;
    environmentFile = "/etc/nixos/secrets/gatus.env";
    settings = {
      alerting.telegram = {
        token = "\${GATUS_TELEGRAM_TOKEN}";
        id = "\${GATUS_TELEGRAM_CHAT_ID}";
        topic-id = "\${GATUS_TELEGRAM_TOPIC_ID}";
        api-url = "\${GATUS_TELEGRAM_API_URL}";
      };
      web = {
        address = "127.0.0.1";
        port = endpoint.tcp.http;
      };
      storage = {
        type = "sqlite";
        path = "/var/lib/gatus/gatus.db";
      };
      endpoints = lib.mapAttrsToList (name: entry: {
        inherit name;
        url = "https://${entry.hostnames.public}/";
        interval = "60s";
        client = {
          timeout = "10s";
          ignore-redirect = false;
        };
        conditions = [
          "[STATUS] >= 200"
          "[STATUS] < 300"
        ];
        alerts = [
          {
            type = "telegram";
            failure-threshold = 3;
            success-threshold = 2;
            send-on-resolved = true;
          }
        ];
      }) webEndpoints;
    };
  };

  services.endpoints.gatus.nginx.enable = true;

}
