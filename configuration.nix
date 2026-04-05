# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      dashy = prev.callPackage ./overlays/dashy.nix { };
      unstable = import inputs.nixpkgs-unstable {
        inherit (prev) system;
        config = config.nixpkgs.config;
      };
    })
  ];

  imports =
    [
      ./hardware-configuration.nix
      ./vim.nix
      modules/vars.nix
      services/samba.nix
      services/jellyfin.nix
      services/ersatztv.nix
      services/pinchflat.nix
      services/navidrome.nix
      services/nextcloud.nix
      services/adguard.nix
#      services/grafana.nix
#      services/prometheus.nix
#      services/fronius.nix
#      services/smokeping.nix
      services/vaultwarden.nix
      services/librespeed.nix
      services/libation.nix
      services/audiobookshelf.nix
      services/freshrss.nix
#      services/openvscode.nix
#      services/whoogle.nix
      services/duplicati.nix
      services/home_assistant.nix
      services/paperless.nix
      services/stirling.nix
#      services/tandoor.nix
      services/uptime.nix
    ];

  services.globalVars = {
    dataDir = "/mnt/data";
    domain = "alistair-martin.com";
  };

  # Bootloader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  system.autoUpgrade = {
    enable  = false;
    allowReboot  = true;
  };

  networking = {
    hostName = "tiefenbacher";
    domain = "home";
    firewall.enable = false;
    networkmanager.enable = true;
  };
  systemd.services.NetworkManager-wait-online.enable = false;

  # Set your time zone.
  time.timeZone = "Europe/Vienna";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  services = {
    xserver = {
      enable = true;

      # Enable the XFCE Desktop Environment.
      desktopManager.xfce.enable = true;
      displayManager.lightdm.enable = true;
    };
    displayManager = {
      autoLogin = {
        enable = true;
        user = "alistair";
      };
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.alistair = {
    isNormalUser = true;
    description = "Alistair";
    extraGroups = [ "networkmanager" "wheel" "docker" "video" "render" ];
  };


  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
  "openssl-1.1.1w"
  "nextcloud-31.0.14"
  ];

  # List packages installed in system profile. To seardch, run:
  environment.systemPackages = with pkgs; [

    # CLI tools
    bat # A cat clone with syntax highlighting and Git integration
    coreutils # GNU core utilities like ls, cp, mv, etc.
    dust # A more intuitive version of `du` for disk usage
    ripgrep # Fast recursive search like grep, but better
    tree # Displays directory structure in a tree-like format
    wget # Non-interactive network downloader
    delta # Syntax-aware diff tool
    eza # Modern replacement for `ls` with more features
    fd # Simple, fast and user-friendly alternative to `find`
    pciutils # Tools for inspecting and configuring PCI devices
    nixfmt-tree # treefmt combined w/ nix-fmt for linting/formating of .nix
    tldr # Simplified and community-driven man
    lazygit
    screen

    # Monitors
    btop # Resource monitor with a modern UI
    iotop # Monitor disk I/O usage by processes
    nload # Real-time network traffic monitor

    # File-related packages
    pandoc # Universal document converter
    imagemagick # Toolset for editing and converting images
    ffmpeg # Command-line tool for processing video and audio
    rsync # Efficiently sync files and directories over network or locally
    visidata # Terminal spreadsheet multitool for data exploration

    # Dev
    sqlite # Lightweight, self-contained SQL database engine
    devenv # Tool for reproducible, shareable developer environments
    git # Distributed version control system
    git-lfs
    repomix # Tool for managing monorepos (multi-package repositories)
    podman # Container runtime for building and running Docker containers
    nodejs_24 # Nodejs is required to run mcp servers
    uv # Ultra-fast Python package manager and environment manager
    python312 # System Python for non-uv usage

    docker-compose
    hwinfo
    lm_sensors
    unzip
    dig
    ffmpeg
    exiftool
    yt-dlp
    borgbackup

    # CLI utilities (included in MacOS)
    killall # Kill processes by name
    unzip # Extracts .zip archive files
    curl # Tool for transferring data with URLs
    zip # Package and compress files into .zip format
  ] ++ [ unstable.pkgs.opencode ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
  };
  services.atuin.enable = true;

  programs.direnv.enable = true;

  # Containers
  virtualisation = {
    docker = {
      enable = true;
      autoPrune.enable = true;
    };
    podman = {
      enable = true;
      autoPrune.enable = true;
    };
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    virtualHosts."mistake.${config.networking.fqdn}" = {
      default = true;
      locations."/".return = "404";
    };
  };


  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "contact@alistair-martin.com";
      group = "nginx";
      dnsProvider = "cloudflare";
      credentialsFile = "/etc/nixos/secrets/cloudflare.env";
    };
  };

  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
    optimise.automatic = true;
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
  };

  system.stateVersion = "23.05"; # Did you read the comment?
}
