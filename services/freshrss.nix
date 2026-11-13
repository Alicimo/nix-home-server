{ config, ... }:
let
  fqdn = config.services.endpoints.freshrss.hostnames.public;
  dir = "${config.services.globalVars.containerDir}/freshrss";
in {
  services.freshrss = {
    enable = true;
    baseUrl = "https://${fqdn}";
    passwordFile = "${dir}/secret";
    database.port = 3306;
    virtualHost = "${fqdn}";
    dataDir = "${dir}";
  };
  services.endpoints.freshrss.nginx = {
    enable = true;
    proxy = false;
  };
}
