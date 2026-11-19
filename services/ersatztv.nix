{ config, pkgs, ... }:
let
  port = config.services.endpoints.ersatztv.tcp.http;
  ffmpegPath = "${pkgs.jellyfin-ffmpeg}/bin/ffmpeg";
  ffprobePath = "${pkgs.jellyfin-ffmpeg}/bin/ffprobe";
in
{
  services.ersatztv = {
    enable = true;
    baseUrl = "/";
    openFirewall = false;
    package = pkgs.ersatztv.override {
      ffmpeg = pkgs.jellyfin-ffmpeg;
    };
    environment.ETV_UI_PORT = port;
  };

  systemd.services.ersatztv = {
    path = [ pkgs.sqlite ];
    preStart = ''
      db=/var/lib/ersatztv/config/ersatztv.sqlite3

      if [ -e "$db" ]; then
        sqlite3 "$db" "
          INSERT INTO ConfigElement(Key, Value)
          VALUES ('ffmpeg.ffmpeg_path', '${ffmpegPath}')
          ON CONFLICT(Key) DO UPDATE SET Value = excluded.Value;
          INSERT INTO ConfigElement(Key, Value)
          VALUES ('ffmpeg.ffprobe_path', '${ffprobePath}')
          ON CONFLICT(Key) DO UPDATE SET Value = excluded.Value;
        "
      fi
    '';
    serviceConfig.SupplementaryGroups = [
      "render"
      "video"
    ];
  };
}
