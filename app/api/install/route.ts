import { NextRequest, NextResponse } from 'next/server';
import { exec } from 'child_process';
import { promisify } from 'util';
import gamesConfig from '@/games-config.json';
import type { InstallResponse } from '@/types/game';

const execPromise = promisify(exec);

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
        timeout: 30000, // 30 second timeout
        shell: shellPath,
      });

      console.log(`Install output for ${gameId}:`, stdout);
      if (stderr) {
        console.error(`Install errors for ${gameId}:`, stderr);
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
