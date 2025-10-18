# Nix Flake Usage Guide

This document provides detailed information about using the Nix flake for the Game Catalogue project.

## What is Nix?

Nix is a package manager and build system that provides:
- **Reproducible builds**: Same code produces same results everywhere
- **Declarative environments**: Specify exact dependencies needed
- **Isolated development**: No conflicts with system packages
- **Atomic upgrades**: Safe installation and rollback

## Prerequisites

### Install Nix

If you don't have Nix installed:

**Linux/macOS:**
```bash
curl -L https://nixos.org/nix/install | sh
```

**Windows:**
Use WSL2 with the Linux instructions above.

### Enable Flakes

Flakes are an experimental feature. Enable them by adding to `~/.config/nix/nix.conf`:

```
experimental-features = nix-command flakes
```

Or for system-wide (NixOS), add to `/etc/nixos/configuration.nix`:

```nix
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
```

## Quick Start

### 1. Development Environment

Enter a shell with all dependencies:

```bash
cd GameRepo
nix develop
```

This gives you:
- Node.js 20
- npm
- TypeScript
- TypeScript language server

Now you can use standard npm commands:
```bash
npm install
npm run dev
npm run build
```

### 2. Automatic Environment (direnv)

Install direnv for automatic environment loading:

```bash
# On NixOS
nix-env -iA nixpkgs.direnv

# On other systems with Nix
nix-env -i direnv
```

Setup:
```bash
cd GameRepo
direnv allow
```

Now the environment loads automatically when you enter the directory!

### 3. Building the Package

Build the complete application:

```bash
nix build
```

This creates a `result` symlink with the built application.

Run it:
```bash
./result/bin/game-catalogue
```

The application starts on http://localhost:3000

### 4. Running Without Cloning

Test the application without cloning:

```bash
# Run from GitHub
nix run github:Strange500/GameRepo
```

## Available Commands

### Development Shell
```bash
nix develop              # Enter development environment
nix develop -c npm run dev  # Run command in dev environment
```

### Building
```bash
nix build                # Build the package
nix build .#game-catalogue  # Explicitly build game-catalogue
```

### Running
```bash
nix run                  # Run the default app
nix run .#default        # Same as above
```

## Flake Structure

The `flake.nix` file defines:

### Outputs

**packages.default**: The built Game Catalogue application
- Includes all dependencies
- Pre-built Next.js production bundle
- Executable script at `bin/game-catalogue`

**devShells.default**: Development environment with:
- Node.js 20
- npm
- TypeScript tools
- Language server for IDE integration

**apps.default**: Runnable application
- Starts the production server
- Available via `nix run`

## Customization

### Changing Node.js Version

Edit `flake.nix` and change:
```nix
nodejs = pkgs.nodejs_20;
```

To:
```nix
nodejs = pkgs.nodejs_18;  # or nodejs_21, nodejs-latest, etc.
```

### Adding Development Tools

Add to `devShells.default.buildInputs`:
```nix
devShells.default = pkgs.mkShell {
  buildInputs = [
    nodejs
    pkgs.nodePackages.npm
    pkgs.git
    pkgs.vim
    # Add more tools here
  ];
};
```

## Troubleshooting

### Flakes Not Recognized

Error: `error: experimental Nix feature 'flakes' is disabled`

**Solution:** Enable flakes as described in Prerequisites.

### Build Fails

**Check Node version:**
```bash
nix develop -c node --version
```

**Clean and rebuild:**
```bash
rm -rf .next node_modules
nix develop
npm install
npm run build
```

### direnv Not Loading

**Check direnv hook:**
```bash
eval "$(direnv hook bash)"  # For bash
eval "$(direnv hook zsh)"   # For zsh
```

Add to your shell RC file (~/.bashrc or ~/.zshrc).

### Port Already in Use

The application uses port 3000 by default. Change it:

```bash
PORT=3001 ./result/bin/game-catalogue
```

Or in development:
```bash
nix develop -c env PORT=3001 npm run dev
```

## Benefits of Using Nix

### For Development
- ✅ Consistent environment across machines
- ✅ No global package pollution
- ✅ Easy onboarding for new developers
- ✅ Works on any Linux/macOS system

### For Deployment
- ✅ Reproducible builds
- ✅ All dependencies included
- ✅ Easy to deploy to NixOS
- ✅ Rollback capability

### For Testing
- ✅ Isolated test environments
- ✅ Test different Node.js versions
- ✅ Clean state for each test
- ✅ Fast CI/CD integration

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Build with Nix

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: cachix/install-nix-action@v22
        with:
          extra_nix_config: |
            experimental-features = nix-command flakes
      - run: nix build
      - run: nix flake check
```

## Additional Resources

- [Nix Manual](https://nixos.org/manual/nix/stable/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
- [direnv Documentation](https://direnv.net/)
- [NixOS Weekly Newsletter](https://weekly.nixos.org/)

## Getting Help

- **Nix Community**: https://discourse.nixos.org/
- **Matrix Chat**: #nix:nixos.org
- **GitHub Issues**: For project-specific problems

Happy Nix-ing! ❄️
