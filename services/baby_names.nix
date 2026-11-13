{ config, pkgs, ... }:
let
  port = config.services.endpoints.baby-names.tcp.http;
  appDir = "/home/alistair/workspace/baby_names";
in
{
  systemd.services.baby-names = {
    description = "Baby Name Ranker FastAPI app";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    environment = {
      LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib";
      UV_PYTHON_DOWNLOADS = "never";
    };

    serviceConfig = {
      User = "alistair";
      WorkingDirectory = appDir;
      EnvironmentFile = "-${appDir}/.env";
      ExecStartPre = "${pkgs.uv}/bin/uv sync --frozen --no-dev --no-install-project --python ${pkgs.python313}/bin/python";
      ExecStart = "${appDir}/.venv/bin/python -m uvicorn app.main:app --host 127.0.0.1 --port ${toString port} --reload";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };

  services.endpoints.baby-names.nginx = {
    enable = true;
    proxyWebsockets = true;
  };
}
