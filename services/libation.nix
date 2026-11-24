{
  config,
  lib,
  pkgs,
  ...
}:
let
  dir = "${config.services.globalVars.dataDir}/libation";
  stateDir = "${dir}/config";
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
      LIBATION_FILES_DIR = stateDir;
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
    preStart = ''
      test -r ${lib.escapeShellArg "${stateDir}/AccountsSettings.json"}
      test -r ${lib.escapeShellArg "${stateDir}/Settings.json"}
      test -r ${lib.escapeShellArg "${stateDir}/LibationContext.db"}
      test -w ${lib.escapeShellArg books}
    '';
    script = ''
      ${pkgs.libation}/bin/libationcli scan --libationFiles ${lib.escapeShellArg stateDir}
      ${pkgs.libation}/bin/libationcli liberate --libationFiles ${lib.escapeShellArg stateDir}
    '';
  };

  systemd.timers.libation = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5min";
      OnUnitInactiveSec = "30min";
      Unit = "libation.service";
    };
  };
}
