{ config, ... }:
let
  port = toString config.services.endpoints.librespeed.tcp.http;
in {
  virtualisation.oci-containers.containers = {
    librespeed = {
      image = "lscr.io/linuxserver/librespeed";
      ports = ["${port}:80"];
      volumes = [
        "${config.services.globalVars.dataDir}/containers/librespeed/config:/config"
      ];
      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "${config.time.timeZone}";
        PASSWORD = "PASSWORD";
      };
    };
  };

  services.endpoints.librespeed.nginx.enable = true;
}
