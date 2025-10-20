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
      
      # Home Manager module for the game installer app
      homeManagerModule = import ./home-manager/modules/game-installer-app.nix;
      
      # Function to build the game catalogue package
      buildGameCatalogue = pkgs: pkgs.buildNpmPackage {
        pname = "game-catalogue";
        version = "1.0.0";
        
        src = ./.;
        
        # IMPORTANT: This hash needs to be updated when package-lock.json changes
        # 
        # First time setup or after dependency changes:
        # 1. Run: ./update-npm-hash.sh (automatic)
        #    OR
        # 2. Run: nix build
        #    The build will fail and show the correct hash
        #    Copy the hash and replace the line below
        # 
        # See NPM_HASH.md for more details
        npmDepsHash = pkgs.lib.fakeHash;
        
        # Use legacy peer deps for compatibility
        npmFlags = [ "--legacy-peer-deps" ];
        
        # Build the Next.js application
        buildPhase = ''
          runHook preBuild
          export HOME=$TMPDIR
          npm run build
          runHook postBuild
        '';
        
        installPhase = ''
          runHook preInstall
          
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
          exec ${pkgs.nodejs_20}/bin/node node_modules/.bin/next start "\$@"
          EOF
          
          chmod +x $out/bin/game-catalogue
          
          runHook postInstall
        '';
        
        meta = with pkgs.lib; {
          description = "Game catalogue with install script support";
          license = licenses.isc;
          platforms = platforms.all;
        };
      };
    in
    {
      # NixOS module available to all systems
      nixosModules.default = nixosModule;
      nixosModules.game-installer-app = nixosModule;

      # Home Manager module available to all systems
      homeManagerModules.default = homeManagerModule;
      homeManagerModules.game-installer-app = homeManagerModule;

      # Overlay to make the package available in nixpkgs
      overlays.default = final: prev: {
        game-installer-app = buildGameCatalogue final;
      };
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        nodejs = pkgs.nodejs_20;
        
        # Build the application using the shared function
        gameCatalogue = buildGameCatalogue pkgs;
        
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
