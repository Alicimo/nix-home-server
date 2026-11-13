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

  services.nginx.virtualHosts."${config.services.endpoints.stirling.hostnames.public}" = {
    forceSSL = true;
    enableACME = true;
    acmeRoot = null;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${port}";
    };
  };
}
