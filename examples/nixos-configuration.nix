# Example NixOS Configuration with Game Installer App
#
# This is a minimal example showing how to use the game-installer-app
# NixOS module in your system configuration.
#
# To use this:
# 1. Add this flake to your system's flake inputs
# 2. Import the module
# 3. Configure the service options

{
  description = "Example NixOS configuration with game-installer-app";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    game-installer-app.url = "github:Strange500/GameRepo";
    # Optional: for secret management
    # sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = { self, nixpkgs, game-installer-app, ... }: {
    nixosConfigurations.example-host = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # Import the game installer app module
        game-installer-app.nixosModules.default
        
        # Apply overlay to make the package available
        ({ pkgs, ... }: {
          nixpkgs.overlays = [ game-installer-app.overlays.default ];
        })
        
        # Your configuration
        ({ config, pkgs, ... }: {
          # Basic system configuration
          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;
          
          networking.hostName = "example-host";
          
          # Enable the game installer app
          services.game-installer-app = {
            enable = true;
            port = 3000;
            openFirewall = true;
            
            # Optional: use a custom data directory
            # dataDir = "/var/lib/game-installer-app";
            
            # Optional: specify an environment file for secrets
            # envFile = /run/secrets/game-installer.env;
          };
          
          # System-level packages
          environment.systemPackages = with pkgs; [
            vim
            git
          ];
          
          # Enable SSH for remote access
          services.openssh.enable = true;
          
          system.stateVersion = "24.05";
        })
      ];
    };
  };
}
