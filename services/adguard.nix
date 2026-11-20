{ config, ... }:
let
  port = config.services.endpoints.adguard.tcp.http;
in {
  services.endpoints.adguard.nginx = {
    proxy = true;
  };

  services.adguardhome = {
    enable = true;
    port = port;
    settings = {
      http = {
        address = "0.0.0.0:${toString port}";
      };
      dns = {
        filters_update_interval = 1;
        upstream_dns = ["1.1.1.2" "1.0.0.2" "94.140.14.14" "94.140.15.15"];
        all_servers = true;
        fastest_addr = false;
        bootstrap_dns = [];
        cache_optimistic = true;
      };
      filters = [
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
          name = "AdGuard DNS filter";
          id = 1;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt";
          name = "AdAway Default Blocklist";
          id = 2;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_27.txt";
          name = "OISD Blocklist Big";
          id = 1693232049;
        }
      ];
    };
  };
}
