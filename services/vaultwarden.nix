{ config, ... }:
{
  services.endpoints.vaultwarden.nginx = {
    proxy = true;
  };

  services.vaultwarden = {
    enable = true;
    backupDir = "${config.services.globalVars.containerDir}/vaultwarden";
    config.ROCKET_PORT = config.services.endpoints.vaultwarden.tcp.http;
  };
}
