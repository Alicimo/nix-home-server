{ config, ... }:
{
  services.paperless = {
    enable = true;
    dataDir = "${config.services.globalVars.dataDir}/paperless";
    passwordFile = "/etc/nixos/secrets/paperless-password";
    consumptionDirIsPublic = true;
    settings = {
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
      PAPERLESS_AUTO_LOGIN_USERNAME = "admin";
    };
  };
  services.nginx.virtualHosts."${config.services.endpoints.paperless.hostnames.public}" = {
    locations."/".proxyPass = "http://127.0.0.1:${toString config.services.endpoints.paperless.tcp.http}";
    forceSSL = true;
    enableACME = true;
    acmeRoot = null;
  };
}
