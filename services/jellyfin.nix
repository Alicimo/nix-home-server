{ pkgs, config, ... }:
{
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      jellyfin-ffmpeg
    ];
  };

  services.jellyfin.enable = true;

  services.nginx.virtualHosts."${config.services.endpoints.jellyfin.hostnames.public}" = {
    locations."/".proxyPass = "http://127.0.0.1:${toString config.services.endpoints.jellyfin.tcp.http}";
    forceSSL = true;
    enableACME = true;
    acmeRoot = null;
  };
}
