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

    dataDir = mkOption {
      type = types.str;
      default = "${config.xdg.dataHome}/game-installer-app";
      defaultText = literalExpression ''"''${config.xdg.dataHome}/game-installer-app"'';
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
      example = literalExpression ''"''${config.home.homeDirectory}/.secrets/game-installer.env"'';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.game-installer-app or (throw "game-installer-app package not found. Make sure the flake overlay is applied.");
      defaultText = literalExpression "pkgs.game-installer-app";
      description = "The game installer app package to use.";
    };
  };

  config = mkIf cfg.enable {
    # Ensure data directory exists
    home.activation.createGameInstallerDataDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD mkdir -p ${escapeShellArg cfg.dataDir}
    '';

    # Systemd user service
    systemd.user.services.game-installer-app = {
      Unit = {
        Description = "Game Installer App";
        After = [ "network.target" ];
      };

      Service = {
        Type = "simple";
        WorkingDirectory = cfg.dataDir;
        ExecStart = "${cfg.package}/bin/game-catalogue";
        Restart = "on-failure";
        RestartSec = "10s";
        
        # Environment variables
        Environment = [
          "PORT=${toString cfg.port}"
          "NODE_ENV=production"
        ];
        
        # Load environment file if specified
        EnvironmentFile = mkIf (cfg.envFile != null) cfg.envFile;
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
