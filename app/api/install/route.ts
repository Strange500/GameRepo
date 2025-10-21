import { NextRequest, NextResponse } from 'next/server';
import { exec } from 'child_process';
import { promisify } from 'util';
import { discoverGames } from '@/src/lib/gameDiscovery';
import type { InstallResponse } from '@/types/game';

const execPromise = promisify(exec);

// Configurable timeout for install commands (default: 24 hours)
// Can be overridden via INSTALL_TIMEOUT_MS environment variable
const INSTALL_TIMEOUT_MS = parseInt(process.env.INSTALL_TIMEOUT_MS || '86400000', 10);

// Get the appropriate shell for the platform
function getShellPath(): string | undefined {
  if (process.platform === 'win32') {
    // On Windows, use cmd.exe or powershell
    return process.env.ComSpec || 'cmd.exe';
  } else {
    // On Unix-like systems, try to find bash, sh, or use default
    return process.env.SHELL || '/bin/sh';
  }
}

export async function POST(request: NextRequest) {
  try {
    const { gameId, executablePath } = await request.json();

    if (!gameId) {
      return NextResponse.json(
        { success: false, message: 'Game ID is required' },
        { status: 400 }
      );
    }

    const gamesDir = process.env.GAMES_DIR;
    const autoInstallCommand = process.env.AUTO_INSTALL_GAME;

    if (!gamesDir) {
      return NextResponse.json(
        { success: false, message: 'GAMES_DIR environment variable not configured' },
        { status: 500 }
      );
    }

    if (!autoInstallCommand) {
      return NextResponse.json(
        { success: false, message: 'AUTO_INSTALL_GAME environment variable not configured' },
        { status: 500 }
      );
    }

    // Find the game in the discovered games
    const discoveredGames = discoverGames(gamesDir);
    const game = discoveredGames.find((g) => g.id === gameId);

    if (!game) {
      return NextResponse.json(
        { success: false, message: 'Game not found' },
        { status: 404 }
      );
    }

    // Determine which executable to use
    let executableToInstall: string;

    if (executablePath) {
      // Verify the provided executable is valid for this game
      if (!game.executables.includes(executablePath)) {
        return NextResponse.json(
          { success: false, message: 'Invalid executable path' },
          { status: 400 }
        );
      }
      executableToInstall = executablePath;
    } else if (game.executables.length === 1) {
      // Only one executable, use it
      executableToInstall = game.executables[0];
    } else {
      // Multiple executables but none selected
      return NextResponse.json(
        { 
          success: false, 
          message: 'Multiple executables found. Please select one.',
          requiresSelection: true,
          executables: game.executables,
        },
        { status: 400 }
      );
    }

    // Build the install command: AUTO_INSTALL_GAME + absolute path to executable
    const installCommand = `${autoInstallCommand} "${executableToInstall}"`;

    try {
      // Execute the install command
      const shellPath = getShellPath();
      const { stdout, stderr } = await execPromise(installCommand, {
        timeout: INSTALL_TIMEOUT_MS,
        shell: shellPath,
        maxBuffer: 10 * 1024 * 1024, // 10MB buffer for long outputs
      });

      console.log(`Install output for ${gameId}:`, stdout);
      
      // Log stderr but don't treat it as an error unless the command failed
      if (stderr) {
        console.log(`Install stderr for ${gameId}:`, stderr);
      }

      const response: InstallResponse = {
        success: true,
        message: `${game.title} installed successfully`,
        gameId: gameId,
      };

      return NextResponse.json(response);
    } catch (execError: any) {
      console.error(`Failed to install ${gameId}:`, execError);
      
      const response: InstallResponse = {
        success: false,
        message: `Failed to install ${game.title}: ${execError.message}`,
        gameId: gameId,
      };

      return NextResponse.json(response, { status: 500 });
    }
  } catch (error: any) {
    console.error('Install API error:', error);
    return NextResponse.json(
      { success: false, message: 'Internal server error' },
      { status: 500 }
    );
  }
}
