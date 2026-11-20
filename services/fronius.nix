{ config, ... }:
{
  virtualisation.oci-containers.containers = {
    fronius-exporter = {
      image = "ghcr.io/ccremer/fronius-exporter";
      ports = [ "${toString config.services.endpoints.fronius.tcp.http}:8080" ];
      cmd = [
        "--symo.url"
        "http://192.168.68.102"
      ];
    };
  };
}
