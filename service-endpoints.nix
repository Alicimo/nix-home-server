{ config, lib, ... }:
let
  public = config.services.globalVars.domain;
  inventory = (import ./service-registry.nix { inherit lib; }).entries;
  applicationEndpoints = lib.mapAttrs (_: entry: {
    enable = entry.enabled;
    inherit (entry) icon;
    tcp = lib.optionalAttrs (entry.http_port != null) {
      http = entry.http_port;
    };
    hostnames = lib.optionalAttrs (entry.subdomain != "") {
      public = "${entry.subdomain}.${public}";
    };
  }) inventory;
  enabledEndpoints = lib.filterAttrs (_: endpoint: endpoint.enable) config.services.endpoints;
  nginxEndpoints = lib.filterAttrs (_: endpoint: endpoint.nginx.enable) enabledEndpoints;
  publicHostnames =
    endpoints:
    lib.concatMap (
      endpoint: lib.optional (endpoint.hostnames ? public) (endpoint.hostnames.public or "")
    ) (builtins.attrValues endpoints);
  disabledHostnames = lib.subtractLists (publicHostnames enabledEndpoints) (
    publicHostnames (lib.filterAttrs (_: endpoint: !endpoint.enable) config.services.endpoints)
  );
  webEndpoints = lib.filterAttrs (
    _: endpoint:
    endpoint.hostnames ? public
    && builtins.hasAttr endpoint.hostnames.public config.services.nginx.virtualHosts
  ) enabledEndpoints;
  assignments = lib.concatLists (
    lib.mapAttrsToList (
      name: endpoint:
      (map (hostname: {
        key = "hostname ${lib.toLower (lib.removeSuffix "." hostname)}";
        owner = name;
      }) (lib.unique (builtins.attrValues endpoint.hostnames)))
      ++
        lib.concatMap
          (
            protocol:
            lib.mapAttrsToList (purpose: port: {
              key = "${protocol} port ${toString port}";
              owner = "${name}.${protocol}.${purpose}";
            }) endpoint.${protocol}
          )
          [
            "tcp"
            "udp"
          ]
    ) enabledEndpoints
  );
  collisions = lib.filterAttrs (
    _: entries: builtins.length (lib.unique (map (entry: entry.owner) entries)) > 1
  ) (lib.groupBy (entry: entry.key) assignments);
in
{
  options.services.webEndpoints = lib.mkOption {
    description = "Enabled web endpoints, sorted by name, for service discovery consumers.";
    readOnly = true;
    type = lib.types.listOf (
      lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            description = "Endpoint registry name.";
          };
          url = lib.mkOption {
            type = lib.types.str;
            description = "Public HTTPS URL.";
          };
          icon = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "Homepage icon identifier or image URL; empty means no icon.";
          };
        };
      }
    );
  };

  config.services.webEndpoints = lib.mapAttrsToList (name: endpoint: {
    inherit name;
    inherit (endpoint) icon;
    url = "https://${endpoint.hostnames.public}/";
  }) webEndpoints;

  options.services.endpoints = lib.mkOption {
    description = ''
      Configured host-side assignments and known protocol defaults for tiefenbacher.
      This is not a live listener inventory; confirm listeners with sudo ss -lntup.
      Container-internal ports remain in the service modules.
    '';
    default = { };
    type = lib.types.attrsOf (
      lib.types.submodule (
        { config, ... }: {
          options = {
            icon = lib.mkOption {
              type = lib.types.str;
              default = "";
              description = "Homepage icon identifier or image URL; empty means no icon.";
            };
            enable = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Include this endpoint in assignment validation, nginx configuration, and discovery; application module inclusion is controlled by services.toml.";
            };
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
              enable = lib.mkOption {
                type = lib.types.bool;
                readOnly = true;
                default = config.hostnames ? public;
                description = "Whether this endpoint has a public hostname for nginx.";
              };
              proxy = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = "Internal service-module setting: request the shared localhost HTTP proxy; not an inventory flag.";
              };
              proxyWebsockets = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = "Enable WebSocket forwarding for the root proxy location.";
              };
            };
          };
        }
      )
    );
  };

  config.assertions =
    (lib.mapAttrsToList (key: entries: {
      assertion = false;
      message = "Endpoint clash for ${key}: ${
        lib.concatMapStringsSep ", " (entry: entry.owner) entries
      }.";
    }) collisions)
    ++ lib.concatLists (
      lib.mapAttrsToList (name: endpoint: [
        {
          assertion = endpoint.hostnames ? public;
          message = "services.endpoints.${name}: nginx.enable requires hostnames.public.";
        }
        {
          assertion = !endpoint.nginx.proxy || endpoint.tcp ? http;
          message = "services.endpoints.${name}: nginx.proxy requires tcp.http.";
        }
      ]) nginxEndpoints
    );

  # Service modules can also generate virtual hosts. Preserve shared hostnames
  # when an active endpoint uses the same hostname as a disabled entry.
  options.services.nginx.virtualHosts = lib.mkOption {
    apply = lib.filterAttrs (hostname: _: !(builtins.elem hostname disabledHostnames));
  };

  config.services.nginx.virtualHosts = lib.mapAttrs' (
    _: endpoint:
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

  config.services.endpoints = applicationEndpoints // {
    # Current NixOS default: TCP 22.
    openssh.tcp = lib.listToAttrs (
      map (port: lib.nameValuePair "ssh-${toString port}" port) config.services.openssh.ports
    );
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
  };
}
