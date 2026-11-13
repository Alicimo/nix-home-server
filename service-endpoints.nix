{ config, lib, ... }:
let
  public = config.services.globalVars.domain;
  nginxEndpoints = lib.filterAttrs (_: endpoint: endpoint.nginx.enable) config.services.endpoints;
in
{
  options.services.endpoints = lib.mkOption {
    description = ''
      Configured host-side assignments and known protocol defaults for tiefenbacher.
      This is not a live listener inventory; confirm listeners with sudo ss -lntup.
      Container-internal ports remain in the service modules.
    '';
    default = { };
    type = lib.types.attrsOf (lib.types.submodule {
      options = {
        tcp = lib.mkOption {
          type = lib.types.attrsOf lib.types.port;
          default = { };
          description = "Named host-side TCP ports.";
        };
        udp = lib.mkOption {
          type = lib.types.attrsOf lib.types.port;
          default = { };
          description = "Named host-side UDP ports.";
        };
        hostnames = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = { };
          description = "Named nginx hostnames.";
        };
        nginx = {
          enable = lib.mkEnableOption "an HTTPS nginx virtual host for this endpoint";
          proxy = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Proxy / to the endpoint's HTTP port on IPv4 loopback.";
          };
          proxyWebsockets = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable WebSocket forwarding for the root proxy location.";
          };
        };
      };
    });
  };

  config.assertions = lib.concatLists (lib.mapAttrsToList (name: endpoint: [
    {
      assertion = endpoint.hostnames ? public;
      message = "services.endpoints.${name}: nginx.enable requires hostnames.public.";
    }
    {
      assertion = !endpoint.nginx.proxy || endpoint.tcp ? http;
      message = "services.endpoints.${name}: nginx.proxy requires tcp.http.";
    }
  ]) nginxEndpoints);

  config.services.nginx.virtualHosts = lib.mapAttrs' (_: endpoint:
    lib.nameValuePair (endpoint.hostnames.public or "invalid-endpoint") {
      forceSSL = true;
      enableACME = true;
      acmeRoot = null;
      locations = lib.mkIf endpoint.nginx.proxy {
        "/" = {
          proxyPass = "http://127.0.0.1:${toString (endpoint.tcp.http or 0)}";
          proxyWebsockets = endpoint.nginx.proxyWebsockets;
        };
      };
    }
  ) nginxEndpoints;

  config.services.endpoints = {
    # Current NixOS default: TCP 22.
    openssh.tcp = lib.listToAttrs (map (port: lib.nameValuePair "ssh-${toString port}" port) config.services.openssh.ports);
    nginx = {
      tcp.http = config.services.nginx.defaultHTTPListenPort; # Current NixOS default: 80.
      tcp.https = config.services.nginx.defaultSSLListenPort; # Current NixOS default: 443.
      hostnames.fallback = "_";
    };
    tailscale.udp.transport = config.services.tailscale.port; # Current NixOS default: 41641.
    # SMB, NetBIOS and WSD protocol defaults; not explicit listener overrides.
    samba = {
      tcp = {
        smb = 445;
        netbios = 139;
        wsd = 5357;
      };
      udp = {
        netbiosName = 137;
        netbiosDatagram = 138;
        wsd = 3702;
      };
    };
    adguard = {
      # DNS TCP/UDP 53 are protocol defaults; HTTP is explicitly configured.
      tcp = {
        http = 999;
        dns = 53;
      };
      udp.dns = 53;
    };
    audiobookshelf = {
      tcp.http = 13378;
      hostnames.public = "audiobook.${public}";
    };
    baby-names = {
      tcp.http = 8023;
      hostnames.public = "baby-names.${public}";
    };
    duplicati = {
      tcp.http = 1066;
      hostnames.public = "backup.${public}";
    };
    ersatztv = {
      tcp.http = 8409;
      hostnames.public = "tv.${public}";
    };
    freshrss.hostnames.public = "rss.${public}";
    home-assistant = {
      tcp.http = 8123;
      hostnames.public = "hass.${public}";
    };
    jellyfin = {
      # Backend HTTP port is application-managed; nginx assumes this value.
      tcp.http = 8096;
      hostnames.public = "jellyfin.${public}";
    };
    learnr = {
      tcp.http = 8016;
      hostnames.public = "learnr.${public}";
    };
    librespeed = {
      tcp.http = 777;
      hostnames.public = "speed.${public}";
    };
    navidrome = {
      tcp.http = 4533;
      hostnames.public = "music.${public}";
    };
    nextcloud.hostnames.public = "nextcloud.${public}";
    opencode = {
      tcp.http = 4096;
      hostnames.public = "opencode.${public}";
    };
    paperless = {
      tcp.http = config.services.paperless.port; # Current NixOS default: 28981.
      hostnames.public = "paperless.${public}";
    };
    pinchflat = {
      tcp.http = 8945;
      hostnames.public = "pinchflat.${public}";
    };
    retirement-planning = {
      tcp.http = 8024;
      hostnames.public = "retirement.${public}";
    };
    stirling = {
      tcp.http = 1966;
      hostnames.public = "pdf.${public}";
    };
    uptime-kuma = {
      tcp.http = 2542;
      hostnames.public = "uptime.${public}";
    };
    vaultwarden = {
      tcp.http = 8222;
      hostnames.public = "vault.${public}";
    };
  };
}
