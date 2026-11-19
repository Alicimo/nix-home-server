{ config, ... }:
let
  dir="${config.services.globalVars.containerDir}/stirling";
  port = toString config.services.endpoints.stirling.tcp.http;
in {
  virtualisation.oci-containers.containers = {
     stirling = {
      image = "frooodle/s-pdf";
      volumes = [
        "${dir}/trainingData:/usr/share/tessdata" #Required for extra OCR languages
        "${dir}/extraConfigs:/configs"
      ];
      ports = [ "${port}:8080" ];
    };
  };
}
