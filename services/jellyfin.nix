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

  services.endpoints.jellyfin.nginx.enable = true;
}
