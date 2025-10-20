# NixOS Module for Game Installer App

This flake provides a NixOS module to declaratively deploy and configure the Game Installer App.

## Quick Start

### 1. Add the Flake to Your NixOS Configuration

In your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    game-installer-app.url = "github:Strange500/GameRepo";
  };

  outputs = { self, nixpkgs, game-installer-app, ... }: {
    nixosConfigurations.yourhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # Import the game installer app module
        game-installer-app.nixosModules.default
        
        # Apply the overlay to make the package available
        ({ pkgs, ... }: {
          nixpkgs.overlays = [ game-installer-app.overlays.default ];
        })
        
        ./configuration.nix
      ];
    };
  };
}
```

### 2. Enable and Configure the Service

In your `configuration.nix`:

```nix
{
  services.game-installer-app = {
    enable = true;
    port = 3000;
    openFirewall = true;
  };
}
```

### 3. Rebuild Your System

```bash
sudo nixos-rebuild switch --flake .#yourhost
```

The service will be available at `http://localhost:3000` (or your configured port).

## Configuration Options

### `services.game-installer-app.enable`

- **Type**: boolean
- **Default**: `false`
- **Description**: Whether to enable the Game Installer App service.

### `services.game-installer-app.port`

- **Type**: port (integer, 1-65535)
- **Default**: `3000`
- **Description**: Port on which the game installer app will listen.

### `services.game-installer-app.user`

- **Type**: string
- **Default**: `"game-installer"`
- **Description**: User account under which the game installer app runs.

### `services.game-installer-app.group`

- **Type**: string
- **Default**: `"game-installer"`
- **Description**: Group under which the game installer app runs.

### `services.game-installer-app.dataDir`

- **Type**: path
- **Default**: `"/var/lib/game-installer-app"`
- **Description**: Directory where the game installer app stores its data.

### `services.game-installer-app.envFile`

- **Type**: null or path
- **Default**: `null`
- **Description**: Path to an environment file containing environment variables for the app. This can be used with `sops-nix` for secrets like the SteamGridDB API key.
- **Example**: `"/run/secrets/game-installer.env"`

Example `.env` file content:
```env
STEAMGRIDDB_API_KEY=your_api_key_here
```

### `services.game-installer-app.package`

- **Type**: package
- **Default**: `pkgs.game-installer-app`
- **Description**: The game installer app package to use. You can override this to use a custom build.

### `services.game-installer-app.openFirewall`

- **Type**: boolean
- **Default**: `false`
- **Description**: Whether to automatically open the firewall for the configured port.

## Usage Examples

### Basic Setup

```nix
{
  services.game-installer-app = {
    enable = true;
    port = 3000;
    openFirewall = true;
  };
}
```

### With Custom User and Data Directory

```nix
{
  services.game-installer-app = {
    enable = true;
    port = 8080;
    user = "my-game-user";
    group = "my-game-group";
    dataDir = "/opt/game-installer";
    openFirewall = true;
  };
}
```

### With sops-nix for Secrets

First, set up `sops-nix` in your configuration:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    game-installer-app.url = "github:Strange500/GameRepo";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = { self, nixpkgs, game-installer-app, sops-nix, ... }: {
    nixosConfigurations.yourhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        game-installer-app.nixosModules.default
        sops-nix.nixosModules.sops
        
        ({ pkgs, ... }: {
          nixpkgs.overlays = [ game-installer-app.overlays.default ];
        })
        
        ./configuration.nix
      ];
    };
  };
}
```

Then in your `configuration.nix`:

```nix
{
  # Configure sops
  sops.secrets.game-installer-env = {
    format = "binary";
    sopsFile = ./secrets/game-installer.env;
  };

  # Configure the service
  services.game-installer-app = {
    enable = true;
    port = 3000;
    envFile = config.sops.secrets.game-installer-env.path;
    openFirewall = true;
  };
}
```

### Custom Port Behind Reverse Proxy

```nix
{
  services.game-installer-app = {
    enable = true;
    port = 3000;
    # Don't open firewall - nginx will handle external access
    openFirewall = false;
  };

  services.nginx = {
    enable = true;
    virtualHosts."games.example.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:3000";
        proxyWebsockets = true;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
```

## Service Management

### Check Service Status

```bash
systemctl status game-installer-app
```

### View Logs

```bash
journalctl -u game-installer-app -f
```

### Restart Service

```bash
sudo systemctl restart game-installer-app
```

## Security Considerations

The module includes several security hardening measures:

- **Dedicated User**: Runs as a non-root system user
- **NoNewPrivileges**: Prevents privilege escalation
- **PrivateTmp**: Isolated /tmp directory
- **ProtectSystem**: Read-only access to system directories
- **ProtectHome**: No access to user home directories
- **ReadWritePaths**: Only writes to the configured dataDir

### Using Secrets Safely

Always use `sops-nix` or similar secret management for sensitive data like API keys:

1. Never commit `.env` files to git
2. Use `sops-nix` to encrypt secrets
3. Reference encrypted secrets via `envFile` option
4. Secrets will be decrypted at runtime and loaded into the service

## Troubleshooting

### Service Won't Start

Check the logs:
```bash
journalctl -u game-installer-app -n 50
```

Common issues:
- Port already in use
- Missing environment file
- Permission issues with dataDir

### Port Already in Use

Change the port in your configuration:
```nix
services.game-installer-app.port = 3001;
```

Then rebuild:
```bash
sudo nixos-rebuild switch
```

### Permission Denied Errors

Ensure the dataDir exists and has correct permissions:
```bash
sudo systemctl restart game-installer-app
```

The service will automatically set up permissions on start.

## Development

To test changes to the module locally:

```nix
{
  services.game-installer-app = {
    enable = true;
    package = pkgs.callPackage /path/to/local/GameRepo {};
  };
}
```

## Contributing

To improve the module:

1. Edit `nixos/modules/game-installer-app.nix`
2. Test with `nixos-rebuild test`
3. Submit a pull request

## Support

For issues or questions:

- GitHub Issues: https://github.com/Strange500/GameRepo/issues
- NixOS Discourse: https://discourse.nixos.org/

## License

This module is part of the GameRepo project and is licensed under the ISC license.
