{
  config,
  pkgs,
  ...
}:
let
  dir = "${config.services.globalVars.dataDir}/libation";
  books = "${config.services.globalVars.mediaDir}/Audiobooks";
in
{
  systemd.tmpfiles.rules = [
    "d ${dir} 0700 alistair users -"
    "d ${dir}/in-progress 0700 alistair users -"
  ];

  systemd.services.libation = {
    description = "Scan Audible purchases and export audiobooks";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    unitConfig.RequiresMountsFor = [
      dir
      books
    ];
    environment = {
      HOME = dir;
      LIBATION_FILES_DIR = "${dir}/config";
      DOTNET_CLI_TELEMETRY_OPTOUT = "1";
    };
    serviceConfig = {
      Type = "oneshot";
      User = "alistair";
      Group = "users";
      UMask = "0022";
      WorkingDirectory = dir;
      TimeoutStartSec = "infinity";
      NoNewPrivileges = true;
    };
    script = ''
      ${pkgs.libation}/bin/libationcli scan
      ${pkgs.libation}/bin/libationcli liberate
    '';
  };

  systemd.timers.libation = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5min";
      OnUnitInactiveSec = "30min";
    };
  };
}
