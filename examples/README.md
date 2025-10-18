# NixOS Module Examples

This directory contains example configurations showing how to use the game-installer-app NixOS module.

## Files

### `nixos-configuration.nix`

A basic example showing minimal configuration to get the game installer app running on NixOS.

**Features:**
- Simple setup with default options
- Opens firewall automatically
- Runs on port 3000

### `nixos-with-sops.nix`

An advanced example demonstrating:
- Integration with `sops-nix` for secret management
- Reverse proxy setup with nginx
- SSL/TLS configuration with Let's Encrypt
- Best practices for production deployment

## Usage

These are not meant to be used directly, but rather as references for your own NixOS configuration.

Copy the relevant parts into your own:
- `flake.nix` (for flake-based configs)
- `configuration.nix` (for traditional configs importing the flake)

## Testing

To test the module without deploying to a real system, you can use NixOS containers or VMs:

```bash
# Build a VM for testing
nixos-rebuild build-vm --flake .#example-host
./result/bin/run-example-host-vm
```

## More Information

See [NIXOS_MODULE.md](../NIXOS_MODULE.md) for complete documentation of all available options.
