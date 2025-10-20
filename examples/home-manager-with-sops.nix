# Example Home Manager with sops-nix integration
#
# This example shows how to integrate game-installer-app with sops-nix
# to securely manage the SteamGridDB API key and other secrets.

{
  description = "Example Home Manager with sops-nix integration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    game-installer-app.url = "github:Strange500/GameRepo";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = { self, nixpkgs, home-manager, game-installer-app, sops-nix, ... }: {
    homeConfigurations.myuser = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      
      modules = [
        # Import modules
        game-installer-app.homeManagerModules.default
        sops-nix.homeManagerModules.sops
        
        # Apply overlay
        ({ pkgs, ... }: {
          nixpkgs.overlays = [ game-installer-app.overlays.default ];
        })
        
        # Configuration
        ({ config, pkgs, ... }: {
          home.username = "myuser";
          home.homeDirectory = "/home/myuser";
          home.stateVersion = "24.05";
          
          # Configure sops-nix
          sops = {
            # Path to your age key
            age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
            
            defaultSopsFile = ./secrets/secrets.yaml;
            
            # Define the secret
            secrets.game-installer-env = {
              format = "binary";
              sopsFile = ./secrets/game-installer.env;
            };
          };
          
          # Configure game installer app
          services.game-installer-app = {
            enable = true;
            port = 3000;
            
            # Use the sops-managed secret
            envFile = config.sops.secrets.game-installer-env.path;
          };
          
          programs.home-manager.enable = true;
        })
      ];
    };
  };
}

# To set up secrets:
# 1. Install age and sops:
#    nix-shell -p age sops
#
# 2. Generate an age key:
#    mkdir -p ~/.config/sops/age
#    age-keygen -o ~/.config/sops/age/keys.txt
#
# 3. Note your public key from the output
#
# 4. Create .sops.yaml in your config directory:
#    creation_rules:
#      - path_regex: secrets/.*\.env$
#        age: <your-public-key-here>
#
# 5. Create and encrypt your secret file:
#    mkdir -p secrets
#    echo "STEAMGRIDDB_API_KEY=your_api_key_here" > secrets/game-installer.env
#    sops -e -i secrets/game-installer.env
#
# 6. Apply your home-manager configuration:
#    home-manager switch --flake .#myuser
