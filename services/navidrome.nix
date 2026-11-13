{ config, ... }:
{
  services.navidrome = {
    enable = true;
    settings = {
      Address = "0.0.0.0";
      Port = config.services.endpoints.navidrome.tcp.http;
      MusicFolder = "${config.services.globalVars.mediaDir}/Music";
      DataFolder = "${config.services.globalVars.containerDir}/navidrome";
      EnableInsightsCollector = false;
    };
  };

  services.endpoints.navidrome.nginx.enable = true;
}
