{
  description = "Game Catalogue - A Next.js application for browsing and installing games";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      # NixOS module for the game installer app
      nixosModule = import ./nixos/modules/game-installer-app.nix;
    in
    {
      # NixOS module available to all systems
      nixosModules.default = nixosModule;
      nixosModules.game-installer-app = nixosModule;

      # Overlay to make the package available in nixpkgs
      overlays.default = final: prev: {
        game-installer-app = self.packages.${final.system}.game-catalogue;
      };
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        nodejs = pkgs.nodejs_20;
        
        # Build the application
        gameCatalogue = pkgs.stdenv.mkDerivation {
          pname = "game-catalogue";
          version = "1.0.0";
          
          src = ./.;
          
          nativeBuildInputs = [ nodejs ];
          
          buildPhase = ''
            export HOME=$TMPDIR
            npm ci --legacy-peer-deps
            npm run build
          '';
          
          installPhase = ''
            mkdir -p $out/bin $out/lib
            
            # Copy application files
            cp -r .next $out/lib/
            cp -r public $out/lib/ || true
            cp -r node_modules $out/lib/
            cp package.json $out/lib/
            cp next.config.ts $out/lib/
            cp games-config.json $out/lib/
            cp -r scripts $out/lib/ || true
            cp -r app $out/lib/
            cp -r components $out/lib/
            cp -r types $out/lib/
            cp postcss.config.mjs $out/lib/
            cp tsconfig.json $out/lib/
            
            # Create startup script
            cat > $out/bin/game-catalogue <<EOF
            #!/bin/sh
            cd $out/lib
            exec ${nodejs}/bin/node node_modules/.bin/next start "\$@"
            EOF
            
            chmod +x $out/bin/game-catalogue
          '';
          
          meta = with pkgs.lib; {
            description = "Game catalogue with install script support";
            license = licenses.isc;
            platforms = platforms.all;
          };
        };
        
      in {
        packages = {
          default = gameCatalogue;
          game-catalogue = gameCatalogue;
          game-installer-app = gameCatalogue; # Alias for the NixOS module
        };
        
        # Development shell with all dependencies
        devShells.default = pkgs.mkShell {
          buildInputs = [
            nodejs
            pkgs.nodePackages.npm
            pkgs.nodePackages.typescript
            pkgs.nodePackages.typescript-language-server
          ];
          
          shellHook = ''
            echo "🎮 Game Catalogue Development Environment"
            echo ""
            echo "Available commands:"
            echo "  npm install    - Install dependencies"
            echo "  npm run dev    - Start development server"
            echo "  npm run build  - Build for production"
            echo "  npm start      - Start production server"
            echo ""
            echo "Node.js version: $(node --version)"
            echo "npm version: $(npm --version)"
          '';
        };
        
        # Quick start application for testing
        apps.default = {
          type = "app";
          program = "${gameCatalogue}/bin/game-catalogue";
        };
      }
    );
}
