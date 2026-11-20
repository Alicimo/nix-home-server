{ config, pkgs, ... }:
let
  port = toString config.services.endpoints.whoogle.tcp.http;
in
{
  virtualisation.oci-containers.containers.whoogle = {
    image = "benbusby/whoogle-search";
    ports = [ "${port}:5000" ];
    environment = {
      WHOOGLE_CONFIG_LANGUAGE = "lang_en";
      WHOOGLE_CONFIG_SEARCH_LANGUAGE = "lang_en";
      WHOOGLE_CONFIG_COUNTRY = "AT";
    };
  };
  services.endpoints.whoogle.nginx.proxy = true;
}
