{ config, ... }:
{
  services.vaultwarden = {
    enable = true;
    backupDir = "${config.services.globalVars.containerDir}/vaultwarden";
    config.ROCKET_PORT = config.services.endpoints.vaultwarden.tcp.http;
  };

  services.endpoints.vaultwarden.nginx.enable = true;

}
