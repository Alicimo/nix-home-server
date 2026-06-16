{ config, ... }:
let
  bucket = "tiefenbacher-restic";
  passwordFile = "/etc/nixos/secrets/restic-password";
  environmentFile = "/etc/nixos/secrets/restic-b2.env";
in
{
  services.restic.backups = {
    core = {
      initialize = true;
      inhibitsSleep = true;
      repository = "b2:${bucket}:core";
      inherit passwordFile environmentFile;
      paths = [
        "/var/lib/nextcloud"
        "/var/lib/hass"
        "/var/lib/bitwarden_rs"
        "/etc/nixos/secrets"
      ];
      pruneOpts = [
        "--keep-daily 14"
        "--keep-weekly 8"
        "--keep-monthly 12"
        "--keep-yearly 3"
      ];
      timerConfig = {
        OnCalendar = "01:15";
        RandomizedDelaySec = "45m";
        Persistent = true;
      };
    };

    documents = {
      initialize = true;
      inhibitsSleep = true;
      repository = "b2:${bucket}:documents";
      inherit passwordFile environmentFile;
      paths = [
        "${config.services.globalVars.dataDir}/documents"
        "${config.services.globalVars.dataDir}/backups"
        "${config.services.paperless.dataDir}"
      ];
      exclude = [
        "${config.services.paperless.dataDir}/consume"
        "${config.services.paperless.dataDir}/index"
        "${config.services.paperless.dataDir}/log"
      ];
      pruneOpts = [
        "--keep-daily 14"
        "--keep-weekly 8"
        "--keep-monthly 12"
        "--keep-yearly 5"
      ];
      timerConfig = {
        OnCalendar = "02:15";
        RandomizedDelaySec = "90m";
        Persistent = true;
      };
    };

    photos = {
      initialize = true;
      inhibitsSleep = true;
      repository = "b2:${bucket}:photos";
      inherit passwordFile environmentFile;
      paths = [ "${config.services.globalVars.mediaDir}/Photos" ];
      pruneOpts = [
        "--keep-daily 14"
        "--keep-weekly 8"
        "--keep-monthly 12"
        "--keep-yearly 10"
      ];
      timerConfig = {
        OnCalendar = "03:15";
        RandomizedDelaySec = "2h";
        Persistent = true;
      };
    };
  };
}
