{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.game-installer-app;
in
{
  options.services.game-installer-app = {
    enable = mkEnableOption "Game Installer App service";

    port = mkOption {
      type = types.port;
      default = 3000;
      description = "Port on which the game installer app will listen.";
    };

    user = mkOption {
      type = types.str;
      default = "game-installer";
      description = "User account under which the game installer app runs.";
    };

    group = mkOption {
      type = types.str;
      default = "game-installer";
      description = "Group under which the game installer app runs.";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/game-installer-app";
      description = "Directory where the game installer app stores its data.";
    };

    envFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        Path to an environment file containing environment variables for the app.
        This can be used with sops-nix for secrets like the SteamGridDB API key.
        
        Example content:
          STEAMGRIDDB_API_KEY=your_api_key_here
      '';
      example = "/run/secrets/game-installer.env";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.game-installer-app or (throw "game-installer-app package not found. Make sure the flake overlay is applied.");
      defaultText = literalExpression "pkgs.game-installer-app";
      description = "The game installer app package to use.";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to open the firewall for the configured port.";
    };
  };

  config = mkIf cfg.enable {
    # Create user and group
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      description = "Game Installer App service user";
      home = cfg.dataDir;
      createHome = true;
    };

    users.groups.${cfg.group} = {};

    # Systemd service
    systemd.services.game-installer-app = {
      description = "Game Installer App";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        PORT = toString cfg.port;
        NODE_ENV = "production";
      };

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.dataDir;
        ExecStart = "${cfg.package}/bin/game-catalogue";
        Restart = "on-failure";
        RestartSec = "10s";
        
        # Security hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ cfg.dataDir ];
        
        # Load environment file if specified
        EnvironmentFile = mkIf (cfg.envFile != null) cfg.envFile;
      };

      preStart = ''
        # Ensure data directory exists and has correct permissions
        mkdir -p ${cfg.dataDir}
        chown -R ${cfg.user}:${cfg.group} ${cfg.dataDir}
      '';
    };

    # Open firewall if requested
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];
  };
}
