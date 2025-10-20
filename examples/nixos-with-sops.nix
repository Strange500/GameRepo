# Example using sops-nix for secret management
#
# This example shows how to integrate game-installer-app with sops-nix
# to securely manage the SteamGridDB API key and other secrets.

{
  description = "Example with sops-nix integration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    game-installer-app.url = "github:Strange500/GameRepo";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = { self, nixpkgs, game-installer-app, sops-nix, ... }: {
    nixosConfigurations.secure-host = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # Import modules
        game-installer-app.nixosModules.default
        sops-nix.nixosModules.sops
        
        # Apply overlay
        ({ pkgs, ... }: {
          nixpkgs.overlays = [ game-installer-app.overlays.default ];
        })
        
        # Configuration
        ({ config, pkgs, ... }: {
          # Configure sops-nix
          sops = {
            defaultSopsFile = ./secrets/secrets.yaml;
            age.keyFile = "/var/lib/sops-nix/key.txt";
            
            # Define the secret
            secrets.game-installer-env = {
              format = "binary";
              sopsFile = ./secrets/game-installer.env;
              owner = config.services.game-installer-app.user;
              group = config.services.game-installer-app.group;
            };
          };
          
          # Configure game installer app
          services.game-installer-app = {
            enable = true;
            port = 3000;
            openFirewall = true;
            
            # Use the sops-managed secret
            envFile = config.sops.secrets.game-installer-env.path;
          };
          
          # Reverse proxy with nginx (optional)
          services.nginx = {
            enable = true;
            virtualHosts."games.example.com" = {
              enableACME = true;
              forceSSL = true;
              locations."/" = {
                proxyPass = "http://localhost:${toString config.services.game-installer-app.port}";
                proxyWebsockets = true;
                extraConfig = ''
                  proxy_set_header Host $host;
                  proxy_set_header X-Real-IP $remote_addr;
                  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                  proxy_set_header X-Forwarded-Proto $scheme;
                '';
              };
            };
          };
          
          # Open ports for nginx
          networking.firewall.allowedTCPPorts = [ 80 443 ];
          
          system.stateVersion = "24.05";
        })
      ];
    };
  };
}

# To set up secrets:
# 1. Create an age key: ssh-to-age -private-key -i ~/.ssh/id_ed25519 > /var/lib/sops-nix/key.txt
# 2. Create secrets/game-installer.env with:
#    STEAMGRIDDB_API_KEY=your_api_key_here
# 3. Encrypt it: sops -e secrets/game-installer.env
