{ config, ... }:
{
  services.endpoints.paperless.nginx = {
    proxy = true;
  };

  services.paperless = {
    enable = true;
    port = config.services.endpoints.paperless.tcp.http;
    dataDir = "${config.services.globalVars.dataDir}/paperless";
    passwordFile = "/etc/nixos/secrets/paperless-password";
    consumptionDirIsPublic = true;
    settings = {
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
      PAPERLESS_AUTO_LOGIN_USERNAME = "admin";
    };
  };
}
