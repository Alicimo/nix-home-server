{ ... }:
{
  services.endpoints.jellyfin.nginx = {
    proxy = true;
  };

  services.jellyfin.enable = true;
}
