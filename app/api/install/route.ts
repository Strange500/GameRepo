import { NextRequest, NextResponse } from 'next/server';
import { exec } from 'child_process';
import { promisify } from 'util';
import gamesConfig from '@/games-config.json';
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
    const { gameId } = await request.json();

    if (!gameId) {
      return NextResponse.json(
        { success: false, message: 'Game ID is required' },
        { status: 400 }
      );
    }

    // Find the game in the configuration
    const game = gamesConfig.games.find((g) => g.id === gameId);

    if (!game) {
      return NextResponse.json(
        { success: false, message: 'Game not found' },
        { status: 404 }
      );
    }

    // Security: Only execute commands from the configuration file
    // This prevents arbitrary command injection
    const installCommand = game.installCommand;

    try {
      // Execute the install command
      // Use platform's default shell (cross-platform compatible)
      const shellPath = getShellPath();
      const { stdout, stderr } = await execPromise(installCommand, {
        timeout: INSTALL_TIMEOUT_MS, // Configurable timeout (default: 30 minutes)
        shell: shellPath,
        maxBuffer: 10 * 1024 * 1024, // 10MB buffer for long outputs
      });

      console.log(`Install output for ${gameId}:`, stdout);
      
      // Log stderr but don't treat it as an error unless the command failed
      // Many installers output warnings and info to stderr
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
