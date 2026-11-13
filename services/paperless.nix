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
  services.endpoints.paperless.nginx.enable = true;
}
