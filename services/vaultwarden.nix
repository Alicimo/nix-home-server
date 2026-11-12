{ config, ... }:
{
  services.vaultwarden = {
    enable = true;
    backupDir = "${config.services.globalVars.containerDir}/vaultwarden";
    config.ROCKET_PORT = config.services.endpoints.vaultwarden.tcp.http;
  };

  services.nginx.virtualHosts."${config.services.endpoints.vaultwarden.hostnames.public}" = {
    locations."/".proxyPass = "http://127.0.0.1:${toString config.services.endpoints.vaultwarden.tcp.http}";
    forceSSL = true;
    enableACME = true;
    acmeRoot = null;
  };

}
