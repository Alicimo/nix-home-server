{ config, ... }:
{
  services.tandoor-recipes = {
    enable = true;
    port = config.services.endpoints.tandoor.tcp.http;
    extraConfig.MEDIA_ROOT = "/var/lib/tandoor-recipes/media";
  };
  services.endpoints.tandoor.nginx.proxy = true;
}
