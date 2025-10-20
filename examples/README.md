# NixOS Module Examples

This directory contains example configurations showing how to use the game-installer-app NixOS and Home Manager modules.

## Files

### NixOS Module Examples

#### `nixos-configuration.nix`

A basic NixOS example showing minimal configuration to get the game installer app running as a system service.

**Features:**
- Simple setup with default options
- Opens firewall automatically
- Runs on port 3000

#### `nixos-with-sops.nix`

An advanced NixOS example demonstrating:
- Integration with `sops-nix` for secret management
- Reverse proxy setup with nginx
- SSL/TLS configuration with Let's Encrypt
- Best practices for production deployment

### Home Manager Module Examples

#### `home-manager-configuration.nix`

A basic Home Manager example showing minimal configuration to run the game installer app as a user service.

**Features:**
- Runs as your user (no root required)
- Simple setup with default options
- Uses XDG data directory
- Runs on port 3000

#### `home-manager-with-sops.nix`

An advanced Home Manager example demonstrating:
- Integration with `sops-nix` for secret management in Home Manager
- Encrypted secrets with age
- Best practices for user-level deployment

## Usage

These are not meant to be used directly, but rather as references for your own configuration.

Copy the relevant parts into your own:
- `flake.nix` (for flake-based configs)
- `configuration.nix` (for NixOS traditional configs)
- `home.nix` (for Home Manager configs)

## When to Use Which Module

### Use the NixOS Module When:
- Deploying on a server or multi-user system
- Need system-wide service
- Want automatic firewall management
- Need stronger security isolation
- Have root access

### Use the Home Manager Module When:
- Personal use on your own machine
- Don't have root access
- Want service to run as your user
- Testing and development
- Prefer XDG-compliant directories

## Testing

### Testing NixOS Module

To test the NixOS module without deploying to a real system, you can use NixOS containers or VMs:

```bash
# Build a VM for testing
nixos-rebuild build-vm --flake .#example-host
./result/bin/run-example-host-vm
```

### Testing Home Manager Module

To test the Home Manager module:

```bash
# Build the home-manager configuration
home-manager build --flake .#myuser

# Apply the configuration
home-manager switch --flake .#myuser
```

## More Information

- NixOS Module: See [NIXOS_MODULE.md](../NIXOS_MODULE.md) for complete documentation
- Home Manager Module: See [HOME_MANAGER_MODULE.md](../HOME_MANAGER_MODULE.md) for complete documentation
