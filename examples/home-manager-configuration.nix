# Example Home Manager Configuration with Game Installer App
#
# This is a minimal example showing how to use the game-installer-app
# Home Manager module in your home configuration.
#
# To use this:
# 1. Add this flake to your home-manager's flake inputs
# 2. Import the module
# 3. Configure the service options

{
  description = "Example Home Manager configuration with game-installer-app";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    game-installer-app.url = "github:Strange500/GameRepo";
  };

  outputs = { self, nixpkgs, home-manager, game-installer-app, ... }: {
    homeConfigurations.myuser = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      
      modules = [
        # Import the game installer app module
        game-installer-app.homeManagerModules.default
        
        # Apply overlay to make the package available
        ({ pkgs, ... }: {
          nixpkgs.overlays = [ game-installer-app.overlays.default ];
        })
        
        # Your configuration
        ({ config, pkgs, ... }: {
          # Home Manager needs this
          home.username = "myuser";
          home.homeDirectory = "/home/myuser";
          home.stateVersion = "24.05";
          
          # Enable the game installer app
          services.game-installer-app = {
            enable = true;
            port = 3000;
            
            # Optional: use a custom data directory
            # dataDir = "${config.home.homeDirectory}/my-games";
            
            # Optional: specify an environment file for secrets
            # envFile = "${config.home.homeDirectory}/.secrets/game-installer.env";
          };
          
          # Let Home Manager manage itself
          programs.home-manager.enable = true;
        })
      ];
    };
  };
}
