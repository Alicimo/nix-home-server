{ config, ... }:
let
  mediaDir = "${config.services.globalVars.mediaDir}/YouTube";
  port = config.services.endpoints.pinchflat.tcp.http;
in
{
  services.pinchflat = {
    enable = true;
    port = port;
    mediaDir = mediaDir;
    openFirewall = false;
    selfhosted = true;
  };
}
