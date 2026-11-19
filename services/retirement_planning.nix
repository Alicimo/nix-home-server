{ config, pkgs, ... }:
let
  port = config.services.endpoints.retirement-planning.tcp.http;
  appDir = "/home/alistair/workspace/retirement_planning";
  dataDir = "${appDir}/data";
in
{
  systemd.services.retirement-planning = {
    description = "Retirement Planning FastAPI app";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    environment = {
      LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib";
      RETIREMENT_DATA_DIR = dataDir;
      UV_PYTHON_DOWNLOADS = "never";
    };

    serviceConfig = {
      User = "alistair";
      WorkingDirectory = appDir;
      ExecStartPre = "${pkgs.uv}/bin/uv sync --frozen --no-dev --no-install-project --python ${pkgs.python313}/bin/python";
      ExecStart = "${appDir}/.venv/bin/python -m uvicorn retirement_planning.main:app --host 127.0.0.1 --port ${toString port} --reload";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
}
