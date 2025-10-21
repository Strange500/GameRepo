# Game Catalogue

A modern, minimalist web application built with Next.js and TypeScript that dynamically discovers games from a directory structure and allows users to install them using a configurable command.

## Features

- 🎮 **Dynamic Game Discovery**: Automatically discovers games from a configured directory structure
- 📁 **Directory-Based Configuration**: Each subdirectory represents a game with its executables
- 🎯 **Executable Selection**: When multiple .exe files exist, prompts user to select which one to install
- 🖼️ **Visual Cards**: Each game card shows cover image, title, and description
- 🎨 **SteamGridDB Integration**: Automatically fetch high-quality game cover images from SteamGridDB
- 💾 **Smart Caching**: Cache game metadata to minimize API calls and improve performance
- ⚡ **One-Click Install**: Hover over a game card to reveal the install button
- 📊 **Real-time Status**: Visual feedback for installation states (Idle, Installing, Installed, Failed)
- 🔧 **Configurable Install Command**: Use any command (like `wine`) via environment variable
- 🎨 **Minimalist Design**: Clean, dark-themed UI built with Tailwind CSS
- 📱 **Responsive**: Works seamlessly on desktop and mobile devices

## Tech Stack

- **Next.js 15**: React framework with App Router
- **TypeScript**: Type-safe code throughout
- **Tailwind CSS**: Utility-first CSS framework
- **React 19**: Latest React features
- **Node.js**: Server-side JavaScript runtime

## Getting Started

### Prerequisites

- Node.js 18.x or later
- npm or yarn

**OR**

- Nix with flakes enabled

### Quick Start with Nix (Recommended)

If you have Nix installed with flakes enabled, you can start the application instantly:

```bash
# Clone the repository
git clone <repository-url>
cd GameRepo

# Enter development environment
nix develop

# Install dependencies and run
npm install
npm run dev
```

Or run directly without cloning:

```bash
# Run the application directly
nix run github:Strange500/GameRepo
```

### Quick Start with npm

```bash
# 1. Clone the repository
git clone <repository-url>
cd GameRepo

# 2. Install dependencies
npm install

# 3. Configure environment variables
cp .env.local.example .env.local
# Edit .env.local and set:
#   - GAMES_DIR: Path to your games directory
#   - AUTO_INSTALL_GAME: Command to run for installation (e.g., "wine")
#   - STEAMGRIDDB_API_KEY: (Optional) For automatic game images

# 4. Set up your games directory structure
# Create a directory with game subdirectories, each containing .exe files
# Example:
#   /path/to/games/
#     Half-Life/
#       setup.exe
#     Portal/
#       setup.exe
#       portal.exe
#     Minecraft/
#       installer.exe

# 5. Run the development server
npm run dev

# 6. Open http://localhost:3000 in your browser
```

That's it! The application will automatically discover games from your configured directory.

### Installation

#### Option 1: Using Nix

```bash
# Clone the repository
git clone <repository-url>
cd GameRepo

# Enter the Nix development shell
nix develop

# The environment is now set up with Node.js and all tools
npm install
npm run dev
```

For automatic environment loading, install [direnv](https://direnv.net/) and run:
```bash
direnv allow
```

#### Option 2: Using npm/yarn

1. Clone the repository:
```bash
git clone <repository-url>
cd GameRepo
```

2. Install dependencies:
```bash
npm install
```

3. Run the development server:
```bash
npm run dev
```

4. Open [http://localhost:3000](http://localhost:3000) in your browser

### Building for Production

#### With Nix:
```bash
# Build the package
nix build

# Run the built package
./result/bin/game-catalogue
```

#### With npm:
```bash
npm run build
npm start
```

## Configuration

### Environment Variables

The application uses environment variables for configuration. Copy `.env.local.example` to `.env.local` and configure:

```bash
# Required: Path to directory containing game subdirectories
GAMES_DIR=/path/to/your/games

# Required: Command to execute for game installation
# The executable path will be appended as an argument
AUTO_INSTALL_GAME=wine

# Optional: SteamGridDB API key for automatic cover images
# Get your API key from: https://www.steamgriddb.com/profile/preferences
STEAMGRIDDB_API_KEY=your_api_key_here

# Optional: Installation timeout in milliseconds (default: 24 hours)
INSTALL_TIMEOUT_MS=86400000
```

### Games Directory Structure

Games are automatically discovered from the `GAMES_DIR` directory. Each subdirectory represents a game:

```
/path/to/games/
├── Half-Life/
│   └── setup.exe          # Single executable
├── Portal/
│   ├── setup.exe         # Multiple executables
│   ├── launcher.exe      # User will be prompted to select
│   └── portal.exe
└── Minecraft/
    └── installer.exe      # Single executable
```

**Requirements:**
- Each subdirectory name becomes the game title (used for SteamGridDB search)
- Each game directory must contain at least one `.exe` file
- If multiple `.exe` files exist, the user will be prompted to select one
- `setup.exe` is automatically prioritized if found

### Installation Command

The `AUTO_INSTALL_GAME` environment variable defines the base command used for installation. The application appends the absolute path of the selected executable.

**Example:**
```bash
AUTO_INSTALL_GAME=wine
```

Results in:
```bash
wine "/path/to/games/Half-Life/setup.exe"
```

**Common configurations:**

```bash
# For Wine (Windows games on Linux)
AUTO_INSTALL_GAME=wine

# For Proton
AUTO_INSTALL_GAME=proton run

# For direct execution (Linux native)
AUTO_INSTALL_GAME=bash

# For custom installer wrapper
AUTO_INSTALL_GAME=/usr/local/bin/my-installer
```

## SteamGridDB Integration

The application integrates with [SteamGridDB](https://www.steamgriddb.com/) to automatically fetch high-quality cover images for games in your catalogue.

### Setting Up SteamGridDB

1. **Get an API Key**:
   - Visit [SteamGridDB Preferences](https://www.steamgriddb.com/profile/preferences)
   - Create an account or sign in
   - Generate an API key

2. **Configure the Application**:
   ```bash
   # Copy the example environment file
   cp .env.local.example .env.local
   
   # Edit .env.local and add your API key
   STEAMGRIDDB_API_KEY=your_actual_api_key_here
   ```

3. **Restart the Development Server**:
   ```bash
   npm run dev
   ```

### How It Works

- **Automatic Fetching**: When the application starts, it queries SteamGridDB for each discovered game using the directory name as the search term
- **Smart Caching**: Fetched images are cached in `.cache/steamgriddb.json` for 7 days to minimize API calls
- **Graceful Fallback**: If SteamGridDB is unavailable or a game isn't found, the application uses a placeholder image
- **Server-Side Only**: All SteamGridDB API calls happen server-side, keeping your API key secure

### Cache Management

The cache is stored in `.cache/steamgriddb.json` and includes:
- Game ID from SteamGridDB
- Game name
- Image URL
- Timestamp of when the data was cached

To clear the cache:
```bash
rm -rf .cache/steamgriddb.json
```

The cache will be automatically regenerated on the next request.

### Benefits

- ✅ **High-Quality Images**: Get official, high-resolution game cover art
- ✅ **Automatic Updates**: Images are refreshed every 7 days
- ✅ **Reduced Maintenance**: No need to manually source and update game images
- ✅ **Consistent Look**: Professional grid artwork for all games
- ✅ **Rate Limit Friendly**: Caching prevents excessive API calls

### Troubleshooting

**Images not loading?**
1. Check that your API key is correctly set in `.env.local`
2. Verify the API key is valid on [SteamGridDB](https://www.steamgriddb.com/profile/preferences)
3. Check the console for error messages
4. Ensure the game directory names match actual game titles for better search results

**Want to use without SteamGridDB?**
Simply don't configure the `STEAMGRIDDB_API_KEY` environment variable. The application will use placeholder images.

**No games showing up?**
1. Verify `GAMES_DIR` is set correctly in `.env.local`
2. Ensure the directory exists and contains subdirectories
3. Each game subdirectory must have at least one `.exe` file
4. Check the server console for discovery errors

### Installation Process

The installation process works as follows:

1. User clicks "Install" on a game card
2. If multiple `.exe` files exist, a selection dialog appears
3. User selects the desired executable (or it's auto-selected if only one exists)
4. The application executes: `${AUTO_INSTALL_GAME} "/absolute/path/to/selected.exe"`
5. Installation status is displayed in real-time

**⚠️ CRITICAL REQUIREMENT**: The `AUTO_INSTALL_GAME` command **must wait** for the installation to fully complete before exiting. If your command spawns background processes or detaches the installer, the API will think the installation is complete when it's actually still running.

**Examples of proper configurations:**

**Simple Echo (for testing):**
```bash
AUTO_INSTALL_GAME="echo Installing:"
```

**Wine (Windows games on Linux):**
```bash
AUTO_INSTALL_GAME="wine"
```

**Wine with wrapper script:**
```bash
AUTO_INSTALL_GAME="/path/to/wine-wrapper.sh"
```

Where `wine-wrapper.sh` contains:
```bash
#!/bin/bash
wine "$1"
exit $?
```

**Handling Background Processes:**
If your installer tool spawns background processes, you must wait for them:
```bash
#!/bin/bash
my-installer-tool "$1" &
INSTALLER_PID=$!
wait $INSTALLER_PID
exit $?
```

**Monitoring Process Completion:**
For installers that detach, monitor the actual process:
```bash
#!/bin/bash
# Start installer
xvfb-run wine "$1" &
INSTALLER_PID=$!

# Wait for the actual installer process to complete
while ps -p $INSTALLER_PID > /dev/null 2>&1; do
    sleep 1
done

exit 0
```

## Project Structure

```
GameRepo/
├── app/                      # Next.js App Router
│   ├── api/                  # API routes
│   │   ├── games/            # Game discovery endpoint
│   │   │   └── route.ts      # GET handler for discovering games
│   │   └── install/          # Installation endpoint
│   │       └── route.ts      # POST handler for installations
│   ├── layout.tsx            # Root layout
│   ├── page.tsx              # Home page with game grid
│   └── globals.css           # Global styles
├── components/               # React components
│   └── GameCard.tsx          # Game card with executable selection
├── src/
│   └── lib/                  # Utility libraries
│       ├── gameDiscovery.ts  # Game directory discovery logic
│       └── steamgriddb.ts    # SteamGridDB integration
├── types/                    # TypeScript type definitions
│   └── game.ts               # Game-related types
├── public/                   # Static assets
├── .env.local.example        # Environment variable template
├── package.json              # Project dependencies
├── tsconfig.json             # TypeScript configuration
├── tailwind.config.ts        # Tailwind CSS configuration
├── next.config.ts            # Next.js configuration
└── README.md                 # This file
```

## Usage

1. **Configure Environment**: Set up `.env.local` with `GAMES_DIR` and `AUTO_INSTALL_GAME`
2. **Organize Games**: Create a directory structure with game subdirectories containing `.exe` files
3. **Browse Games**: The home page displays all discovered games with their metadata
4. **View Details**: Each card shows the game's cover image, title, and description
5. **Install Game**: Hover over a game card to reveal the "Install" button
6. **Select Executable** (if needed): If multiple `.exe` files exist, select which one to install
7. **Monitor Status**: The button shows real-time status:
   - **Install**: Ready to install
   - **Installing...**: Installation in progress (with spinner)
   - **Installed**: Successfully installed (with checkmark)
   - **Retry**: Failed installation, click to try again
8. **Status Messages**: Success/failure messages appear at the bottom of the card

## API Endpoints

### POST /api/install

Triggers installation of a game.

**Request Body:**
```json
{
  "gameId": "game-id",
  "executablePath": "/absolute/path/to/executable.exe"  // Optional, required if multiple executables
}
```

**Response (Success):**
```json
{
  "success": true,
  "message": "Game Title installed successfully",
  "gameId": "game-id"
}
```

**Response (Requires Selection):**
```json
{
  "success": false,
  "message": "Multiple executables found. Please select one.",
  "requiresSelection": true,
  "executables": [
    "/path/to/setup.exe",
    "/path/to/game.exe"
  ]
}
```

**Response (Error):**
```json
{
  "success": false,
  "message": "Error message",
  "gameId": "game-id"
}
```

### GET /api/games

Retrieves all discovered games.

**Response:**
```json
{
  "games": [
    {
      "id": "half-life",
      "title": "Half-Life",
      "description": "Half-Life",
      "coverImage": "https://...",
      "executables": ["/path/to/setup.exe"]
    }
  ]
}
```

## Development Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm start` - Start production server
- `npm run lint` - Run ESLint

## Customization

### Styling

The app uses Tailwind CSS for styling. Modify `tailwind.config.ts` to customize colors, spacing, and other design tokens.

### Adding New Games

Simply add a new subdirectory to your `GAMES_DIR` with at least one `.exe` file:

```bash
mkdir "$GAMES_DIR/New-Game"
cp /path/to/installer.exe "$GAMES_DIR/New-Game/"
```

The changes will be reflected immediately after refreshing the page.

### Timeout Configuration

The default installation timeout is 30 minutes (1800000ms). For long-running game installations, you can configure this via environment variable:

```bash
# Set timeout to 1 hour (3600000ms)
INSTALL_TIMEOUT_MS=3600000 npm run dev

# Or in production
INSTALL_TIMEOUT_MS=3600000 npm start
```

You can also set it in a `.env.local` file:
```
INSTALL_TIMEOUT_MS=3600000
```

The timeout setting:
- Default: 30 minutes (1800000ms)
- Prevents installations from running indefinitely
- Should be set based on your largest game installation time
- Configurable per deployment without code changes

## Troubleshooting

### Installation Never Completes (Loading State Stuck)

If the installation appears to complete but the UI stays in "Installing..." state forever:

**Cause**: Your install script is exiting before the actual installation finishes (spawning background processes).

**Solution**: Modify your install command to wait for completion:

```bash
# If using a script that backgrounds processes
your-installer-tool game.exe &
PID=$!
wait $PID

# Or monitor for specific completion indicators
while pgrep -f "installer.exe" > /dev/null; do
    sleep 1
done
```

**Verify your script waits** by running it manually and confirming it doesn't return until installation is truly complete.

### Configuration Errors

**GAMES_DIR not configured:**
1. Ensure `.env.local` exists and contains `GAMES_DIR=/path/to/games`
2. Verify the path is absolute and the directory exists
3. Restart the development server after changing `.env.local`

**AUTO_INSTALL_GAME not configured:**
1. Ensure `.env.local` contains `AUTO_INSTALL_GAME=your-command`
2. Verify the command is available in your PATH or use an absolute path
3. Restart the development server after changing `.env.local`

**No executables found:**
1. Ensure game directories contain `.exe` files
2. Check file permissions (files must be readable)
3. Verify file extensions are exactly `.exe` (case-insensitive)

### Installation Fails Due to Timeout

If you see errors like `SIGTERM` or timeout errors:

1. Increase the timeout using the `INSTALL_TIMEOUT_MS` environment variable
2. Check if the installation actually needs that much time
3. Consider optimizing your install scripts for faster execution

Example for very large games:
```bash
INSTALL_TIMEOUT_MS=7200000 npm run dev  # 2 hours
```

### Installation Fails

1. Check the browser console for error messages
2. Verify the install command works in terminal
3. Ensure proper permissions for executing scripts
4. Check server logs: `npm run dev` shows API errors
5. Note that stderr output doesn't always mean failure - many installers output warnings to stderr

### Images Not Loading

1. Verify image URLs are accessible
2. Check CORS settings if using external images
3. Consider hosting images in `public/images/` folder

### Port Already in Use

If port 3000 is busy, start on a different port:
```bash
PORT=3001 npm run dev
```

## Nix Support

This project includes a Nix flake for reproducible development environments, builds, and **declarative deployment** (NixOS and Home Manager).

### NixOS Module

The flake includes a NixOS module for system-wide declarative deployment! 🎉

**Quick Example:**
```nix
{
  inputs.game-installer-app.url = "github:Strange500/GameRepo";
  
  outputs = { nixpkgs, game-installer-app, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      modules = [
        game-installer-app.nixosModules.default
        ({ pkgs, ... }: {
          nixpkgs.overlays = [ game-installer-app.overlays.default ];
          
          services.game-installer-app = {
            enable = true;
            port = 3000;
            openFirewall = true;
            # Optional: use sops-nix for secrets
            # envFile = config.sops.secrets.game-installer-env.path;
          };
        })
      ];
    };
  };
}
```

**📚 Full Documentation**: See [NIXOS_MODULE.md](./NIXOS_MODULE.md) for complete documentation including:
- All configuration options
- sops-nix integration for secrets
- Reverse proxy setup examples
- Security hardening features

### Home Manager Module

The flake also includes a Home Manager module for user-level deployment! 🏠

**Quick Example:**
```nix
{
  inputs.game-installer-app.url = "github:Strange500/GameRepo";
  
  outputs = { nixpkgs, home-manager, game-installer-app, ... }: {
    homeConfigurations.myuser = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        game-installer-app.homeManagerModules.default
        ({ pkgs, ... }: {
          nixpkgs.overlays = [ game-installer-app.overlays.default ];
          
          services.game-installer-app = {
            enable = true;
            port = 3000;
            # Optional: specify an environment file for secrets
            # envFile = "${config.home.homeDirectory}/.secrets/game-installer.env";
          };
        })
      ];
    };
  };
}
```

**📚 Full Documentation**: See [HOME_MANAGER_MODULE.md](./HOME_MANAGER_MODULE.md) for complete documentation including:
- All configuration options
- sops-nix integration for user secrets
- Service management commands
- Comparison with NixOS module

**When to use which:**
- **NixOS Module**: System-wide deployment, production servers, multi-user systems
- **Home Manager Module**: Personal use, no root required, development/testing

### Using Nix Flakes

**Prerequisites:**
- Nix package manager installed
- Flakes enabled in your Nix configuration

**Development Environment:**
```bash
# Enter development shell with all dependencies
nix develop

# Or use direnv for automatic environment loading
echo "use flake" > .envrc
direnv allow
```

**Building:**
```bash
# Build the application
nix build

# Run the built application
./result/bin/game-catalogue
```

**Running Directly:**
```bash
# Run without building
nix run

# Run from GitHub without cloning
nix run github:Strange500/GameRepo
```

**What's Included:**
- Node.js 20
- npm and all required build tools
- TypeScript and language server
- Pre-configured development environment
- One-command build and run
- **NixOS module for system-wide declarative deployment**
- **Home Manager module for user-level declarative deployment**

### Enabling Nix Flakes

If you don't have flakes enabled, add this to `~/.config/nix/nix.conf` or `/etc/nix/nix.conf`:
```
experimental-features = nix-command flakes
```

For more details on Nix usage, see [NIX.md](./NIX.md).

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

ISC

## Support

For issues and questions, please open an issue on the GitHub repository.
