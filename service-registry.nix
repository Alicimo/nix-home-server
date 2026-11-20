{
  lib,
  inventoryFile ? ./services.toml,
}:
let
  entries =
    (lib.evalModules {
      modules = [
        {
          options.entries = lib.mkOption {
            type = lib.types.attrsOf (
              lib.types.submodule {
                options = {
                  module = lib.mkOption {
                    type = lib.types.str;
                    description = "Repository-relative application module path.";
                  };
                  enabled = lib.mkOption {
                    type = lib.types.bool;
                    default = true;
                  };
                  subdomain = lib.mkOption {
                    type = lib.types.str;
                    default = "";
                  };
                  http_port = lib.mkOption {
                    type = lib.types.nullOr lib.types.port;
                    default = null;
                  };
                  icon = lib.mkOption {
                    type = lib.types.str;
                    default = "";
                  };
                };
              }
            );
          };
          config.entries = builtins.fromTOML (builtins.readFile inventoryFile);
        }
      ];
    }).config.entries;
  validate =
    name: entry:
    let
      parts = lib.splitString "/" entry.module;
      path = ./. + "/${entry.module}";
      safe = lib.all (
        part:
        !(builtins.elem part [
          ""
          "."
          ".."
        ])
      ) parts;
      noSymlinks = lib.all (
        index:
        builtins.readFileType (./. + "/${lib.concatStringsSep "/" (lib.take (index + 1) parts)}")
        != "symlink"
      ) (lib.range 0 (builtins.length parts - 1));
    in
    if name == "" then
      throw "Service registry: service names must not be empty."
    else if
      builtins.elem name [
        "openssh"
        "nginx"
        "tailscale"
        "samba"
      ]
    then
      throw "Service registry: infrastructure assignments must remain in Nix."
    else if !safe || !(lib.hasSuffix ".nix" entry.module) then
      throw "Service registry: ${name}.module must be a repository-relative Nix file without traversal."
    else if !(builtins.pathExists path) then
      throw "Service registry: ${name}.module '${entry.module}' does not exist."
    else if !noSymlinks || builtins.readFileType path != "regular" then
      throw "Service registry: ${name}.module must be a regular file without symlinks."
    else
      entry;
  validated = builtins.deepSeq entries (lib.mapAttrs validate entries);
  moduleNames = map (entry: entry.module) (builtins.attrValues validated);
  checked = builtins.deepSeq validated (
    if builtins.length moduleNames != builtins.length (lib.unique moduleNames) then
      throw "Service registry: duplicate module assignments."
    else
      validated
  );
in
{
  entries = checked;
  imports = map (entry: ./. + "/${entry.module}") (
    builtins.attrValues (lib.filterAttrs (_: entry: entry.enabled) checked)
  );
}
