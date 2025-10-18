# Game Catalogue

A modern, minimalist web application built with Next.js and TypeScript that displays a catalogue of games and allows users to install them via configured external scripts.

## Features

- 🎮 **Game Grid Display**: Browse games in a clean, responsive grid layout
- 🖼️ **Visual Cards**: Each game card shows cover image, title, and description
- 🎨 **SteamGridDB Integration**: Automatically fetch high-quality game cover images from SteamGridDB
- 💾 **Smart Caching**: Cache game metadata to minimize API calls and improve performance
- ⚡ **One-Click Install**: Hover over a game card to reveal the install button
- 📊 **Real-time Status**: Visual feedback for installation states (Idle, Installing, Installed, Failed)
- 🔒 **Secure Execution**: Only commands defined in config file can be executed
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

# 3. (Optional) Configure SteamGridDB API key for automatic game images
cp .env.local.example .env.local
# Edit .env.local and add your SteamGridDB API key
# Get your API key from: https://www.steamgriddb.com/profile/preferences

# 4. Run the development server
npm run dev

# 5. Open http://localhost:3000 in your browser
```

That's it! The application will be running and you can start browsing and installing games.

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

### games-config.json

The `games-config.json` file defines the catalogue of games. Each game entry includes:

```json
{
  "games": [
    {
      "id": "unique-game-id",
      "title": "Game Title",
      "description": "Game description that appears on the card",
      "coverImage": "https://example.com/image.jpg",
      "installCommand": "echo 'Installing game...' && your-install-script.sh"
    }
  ]
}
```

#### Configuration Fields

- **id** (string, required): Unique identifier for the game
- **title** (string, required): Display name of the game
- **description** (string, required): Brief description shown on the card
- **coverImage** (string, required): URL to the game's cover image
- **installCommand** (string, required): Shell command to execute for installation

### Security Notes

⚠️ **Important**: The application only executes commands defined in `games-config.json`. This prevents arbitrary command injection. However, ensure that:

1. Only trusted users can modify `games-config.json`
2. Install commands are properly validated and tested
3. Commands don't require elevated privileges unless necessary
4. The application is run in a secure environment

### Custom Install Scripts

You can use any shell command or script for installation:

**⚠️ CRITICAL REQUIREMENT**: Your install command **must wait** for the installation to fully complete before exiting. If your script spawns background processes or detaches the installer, the API will think the installation is complete when it's actually still running.

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

- **Automatic Fetching**: When the application starts, it queries SteamGridDB for each game in `games-config.json` using the game's title
- **Smart Caching**: Fetched images are cached in `.cache/steamgriddb.json` for 7 days to minimize API calls
- **Graceful Fallback**: If SteamGridDB is unavailable or a game isn't found, the application uses the `coverImage` URL from `games-config.json`
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
4. Ensure the game names in `games-config.json` match actual game titles

**Want to use without SteamGridDB?**
Simply don't configure the `STEAMGRIDDB_API_KEY` environment variable. The application will use the `coverImage` URLs from `games-config.json` as fallbacks.

### Custom Install Scripts

You can use any shell command or script for installation:

**⚠️ CRITICAL REQUIREMENT**: Your install command **must wait** for the installation to fully complete before exiting. If your script spawns background processes or detaches the installer, the API will think the installation is complete when it's actually still running.

**Simple Echo Example:**
```json
"installCommand": "echo 'Installing Game...' && sleep 2 && echo 'Done!'"
```

**Shell Script Example (Correct - Waits for completion):**
```bash
#!/bin/bash
# install-game.sh
./installer.exe /SILENT
# Script waits for installer.exe to complete before exiting
exit $?
```

**Shell Script Example (INCORRECT - Returns immediately):**
```bash
#!/bin/bash
# install-game.sh - DON'T DO THIS!
./installer.exe /SILENT &
# Script exits immediately while installer runs in background
exit 0
```

**Handling Background Processes:**
If your installer tool spawns background processes, you must wait for them:
```bash
#!/bin/bash
my-installer-tool setup.exe &
INSTALLER_PID=$!
wait $INSTALLER_PID
EXIT_CODE=$?
exit $EXIT_CODE
```

**Monitoring Process Completion:**
For installers that detach, monitor the actual process:
```bash
#!/bin/bash
# Start installer
xvfb-run installer.exe &
INSTALLER_PID=$!

# Wait for the actual installer process to complete
while ps -p $INSTALLER_PID > /dev/null 2>&1; do
    sleep 1
done

exit 0
```

**Shell Script Example:**
```json
"installCommand": "/path/to/install-scripts/install-game.sh --game-id minecraft"
```

**Package Manager Example:**
```json
"installCommand": "apt-get install -y game-package || echo 'Installation failed'"
```

**Custom Script with Arguments:**
```json
"installCommand": "./scripts/installer.sh --name 'Game Name' --version 1.0.0"
```

## Project Structure

```
GameRepo/
├── app/                      # Next.js App Router
│   ├── api/                  # API routes
│   │   └── install/          # Installation endpoint
│   │       └── route.ts      # POST handler for installations
│   ├── layout.tsx            # Root layout
│   ├── page.tsx              # Home page with game grid
│   └── globals.css           # Global styles
├── components/               # React components
│   └── GameCard.tsx          # Game card component
├── types/                    # TypeScript type definitions
│   └── game.ts               # Game-related types
├── public/                   # Static assets
├── games-config.json         # Game catalogue configuration
├── package.json              # Project dependencies
├── tsconfig.json             # TypeScript configuration
├── tailwind.config.ts        # Tailwind CSS configuration
├── next.config.ts            # Next.js configuration
└── README.md                 # This file
```

## Usage

1. **Browse Games**: The home page displays all games from `games-config.json`
2. **View Details**: Each card shows the game's cover image, title, and description
3. **Install Game**: Hover over a game card to reveal the "Install" button
4. **Monitor Status**: The button shows real-time status:
   - **Install**: Ready to install
   - **Installing...**: Installation in progress (with spinner)
   - **Installed**: Successfully installed (with checkmark)
   - **Retry**: Failed installation, click to try again
5. **Status Messages**: Success/failure messages appear at the bottom of the card

## API Endpoints

### POST /api/install

Triggers installation of a game.

**Request Body:**
```json
{
  "gameId": "game-unique-id"
}
```

**Response (Success):**
```json
{
  "success": true,
  "message": "Game Title installed successfully",
  "gameId": "game-unique-id"
}
```

**Response (Error):**
```json
{
  "success": false,
  "message": "Error message",
  "gameId": "game-unique-id"
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

Edit `games-config.json` and add a new game entry:

```json
{
  "id": "new-game",
  "title": "New Game",
  "description": "Description of the new game",
  "coverImage": "https://example.com/cover.jpg",
  "installCommand": "your-install-command"
}
```

The changes will be reflected immediately in development mode.

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

This project includes a Nix flake for reproducible development environments and builds.

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

### Enabling Nix Flakes

If you don't have flakes enabled, add this to `~/.config/nix/nix.conf` or `/etc/nix/nix.conf`:
```
experimental-features = nix-command flakes
```

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
