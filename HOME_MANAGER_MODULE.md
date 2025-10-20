# Home Manager Module for Game Installer App

This flake provides a Home Manager module to declaratively deploy and configure the Game Installer App as a user service.

## Quick Start

### 1. Add the Flake to Your Home Manager Configuration

In your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    game-installer-app.url = "github:Strange500/GameRepo";
  };

  outputs = { self, nixpkgs, home-manager, game-installer-app, ... }: {
    homeConfigurations.youruser = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        # Import the game installer app home-manager module
        game-installer-app.homeManagerModules.default
        
        # Apply the overlay to make the package available
        ({ pkgs, ... }: {
          nixpkgs.overlays = [ game-installer-app.overlays.default ];
        })
        
        ./home.nix
      ];
    };
  };
}
```

### 2. Enable and Configure the Service

In your `home.nix`:

```nix
{
  services.game-installer-app = {
    enable = true;
    port = 3000;
  };
}
```

### 3. Apply Your Configuration

```bash
home-manager switch --flake .#youruser
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

### `services.game-installer-app.dataDir`

- **Type**: string
- **Default**: `"${config.xdg.dataHome}/game-installer-app"` (typically `~/.local/share/game-installer-app`)
- **Description**: Directory where the game installer app stores its data.

### `services.game-installer-app.envFile`

- **Type**: null or path
- **Default**: `null`
- **Description**: Path to an environment file containing environment variables for the app. This can be used for secrets like the SteamGridDB API key.
- **Example**: `"${config.home.homeDirectory}/.secrets/game-installer.env"`

Example `.env` file content:
```env
STEAMGRIDDB_API_KEY=your_api_key_here
```

### `services.game-installer-app.package`

- **Type**: package
- **Default**: `pkgs.game-installer-app`
- **Description**: The game installer app package to use. You can override this to use a custom build.

## Differences from NixOS Module

The Home Manager module differs from the NixOS module in several ways:

1. **User Service**: Runs as a systemd user service instead of a system service
2. **No User/Group Options**: Runs as your user account
3. **No Firewall Control**: Cannot control firewall (system-level)
4. **XDG Compliance**: Uses XDG directories by default (`~/.local/share/game-installer-app`)
5. **No Root Required**: Can be managed without system administrator privileges

## Usage Examples

### Basic Setup

```nix
{
  services.game-installer-app = {
    enable = true;
    port = 3000;
  };
}
```

### With Custom Data Directory

```nix
{
  services.game-installer-app = {
    enable = true;
    port = 8080;
    dataDir = "${config.home.homeDirectory}/game-installer-data";
  };
}
```

### With Environment File for Secrets

```nix
{
  services.game-installer-app = {
    enable = true;
    port = 3000;
    envFile = "${config.home.homeDirectory}/.secrets/game-installer.env";
  };
}
```

Create the environment file:
```bash
mkdir -p ~/.secrets
echo "STEAMGRIDDB_API_KEY=your_api_key_here" > ~/.secrets/game-installer.env
chmod 600 ~/.secrets/game-installer.env
```

### With sops-nix for Secrets

First, set up `sops-nix` in your home-manager configuration:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    game-installer-app.url = "github:Strange500/GameRepo";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = { self, nixpkgs, home-manager, game-installer-app, sops-nix, ... }: {
    homeConfigurations.youruser = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        game-installer-app.homeManagerModules.default
        sops-nix.homeManagerModules.sops
        
        ({ pkgs, ... }: {
          nixpkgs.overlays = [ game-installer-app.overlays.default ];
        })
        
        ./home.nix
      ];
    };
  };
}
```

Then in your `home.nix`:

```nix
{ config, pkgs, ... }:

{
  # Configure sops
  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = ./secrets/secrets.yaml;
    
    secrets.game-installer-env = {
      format = "binary";
      sopsFile = ./secrets/game-installer.env;
    };
  };

  # Configure the service
  services.game-installer-app = {
    enable = true;
    port = 3000;
    envFile = config.sops.secrets.game-installer-env.path;
  };
}
```

### Custom Port and Package

```nix
{ pkgs, ... }:

{
  services.game-installer-app = {
    enable = true;
    port = 3001;
    package = pkgs.game-installer-app.override {
      # Custom package overrides if needed
    };
  };
}
```

## Service Management

### Check Service Status

```bash
systemctl --user status game-installer-app
```

### View Logs

```bash
journalctl --user -u game-installer-app -f
```

### Restart Service

```bash
systemctl --user restart game-installer-app
```

### Stop Service

```bash
systemctl --user stop game-installer-app
```

### Start Service

```bash
systemctl --user start game-installer-app
```

### Disable Service (temporarily)

```bash
systemctl --user disable game-installer-app
```

## Firewall Configuration

Since the Home Manager module runs as a user service, it cannot control the system firewall. If you need to access the service from other machines:

**On NixOS**, add to your system configuration:
```nix
{
  networking.firewall.allowedTCPPorts = [ 3000 ];
}
```

**On other systems**, configure your firewall manually:
```bash
# Example for ufw
sudo ufw allow 3000/tcp

# Example for firewalld
sudo firewall-cmd --add-port=3000/tcp --permanent
sudo firewall-cmd --reload
```

## Automatic Startup

The service is configured to start automatically on login (`default.target`). To ensure it runs even when you're not logged in, you may need to enable lingering for your user:

```bash
loginctl enable-linger $USER
```

This allows user services to run even when you're not logged in to a graphical session.

## Troubleshooting

### Service Won't Start

Check the logs:
```bash
journalctl --user -u game-installer-app -n 50
```

Common issues:
- Port already in use
- Missing environment file
- Permission issues with dataDir
- Package not available (overlay not applied)

### Port Already in Use

Change the port in your configuration:
```nix
services.game-installer-app.port = 3001;
```

Then rebuild:
```bash
home-manager switch
```

### Permission Denied Errors

Ensure the dataDir is in your home directory and you have write permissions:
```bash
chmod 755 ~/.local/share/game-installer-app
```

### Service Not Starting on Login

Enable lingering:
```bash
loginctl enable-linger $USER
```

Check that the service is enabled:
```bash
systemctl --user is-enabled game-installer-app
```

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

## Comparison: Home Manager vs NixOS Module

| Feature | Home Manager Module | NixOS Module |
|---------|-------------------|--------------|
| Service Type | User service | System service |
| Requires Root | No | Yes |
| Firewall Control | No | Yes |
| User/Group Config | Uses your user | Configurable |
| Data Directory | `~/.local/share/...` | `/var/lib/...` |
| Auto-start | On login | On boot |
| Isolation | Lower | Higher (sandboxing) |

**When to use Home Manager module:**
- Personal use on your own machine
- Don't have root access
- Want service to run as your user
- Testing and development

**When to use NixOS module:**
- System-wide deployment
- Production servers
- Need firewall control
- Want stronger security isolation
- Multi-user systems

## Contributing

To improve the module:

1. Edit `home-manager/modules/game-installer-app.nix`
2. Test with `home-manager switch`
3. Submit a pull request

## Support

For issues or questions:

- GitHub Issues: https://github.com/Strange500/GameRepo/issues
- Home Manager Manual: https://nix-community.github.io/home-manager/
- NixOS Discourse: https://discourse.nixos.org/

## License

This module is part of the GameRepo project and is licensed under the ISC license.
