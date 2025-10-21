import fs from 'fs';
import path from 'path';

export interface DiscoveredGame {
  id: string;
  title: string;
  executables: string[];
}

/**
 * Discovers games from a directory structure.
 * Each subdirectory represents a game, and contains .exe files.
 * 
 * @param gamesDir - Root directory containing game subdirectories
 * @returns Array of discovered games with their executables
 */
export function discoverGames(gamesDir: string): DiscoveredGame[] {
  if (!gamesDir) {
    console.warn('GAMES_DIR not configured');
    return [];
  }

  if (!fs.existsSync(gamesDir)) {
    console.warn(`Games directory does not exist: ${gamesDir}`);
    return [];
  }

  const games: DiscoveredGame[] = [];

  try {
    const entries = fs.readdirSync(gamesDir, { withFileTypes: true });

    for (const entry of entries) {
      if (!entry.isDirectory()) {
        continue;
      }

      const gameDir = path.join(gamesDir, entry.name);
      const executables = findExecutables(gameDir);

      if (executables.length > 0) {
        games.push({
          id: entry.name.toLowerCase().replace(/\s+/g, '-'),
          title: entry.name,
          executables: executables,
        });
      } else {
        console.warn(`No .exe files found in game directory: ${gameDir}`);
      }
    }
  } catch (error) {
    console.error(`Error discovering games from ${gamesDir}:`, error);
  }

  return games;
}

/**
 * Finds all .exe files in a directory.
 * Prioritizes setup.exe if found.
 * 
 * @param gameDir - Directory to search for executables
 * @returns Array of absolute paths to executable files
 */
function findExecutables(gameDir: string): string[] {
  try {
    const files = fs.readdirSync(gameDir);
    const exeFiles = files.filter((file) => file.toLowerCase().endsWith('.exe'));

    if (exeFiles.length === 0) {
      return [];
    }

    // Convert to absolute paths
    const absolutePaths = exeFiles.map((file) => path.join(gameDir, file));

    // Sort to prioritize setup.exe
    absolutePaths.sort((a, b) => {
      const aIsSetup = path.basename(a).toLowerCase() === 'setup.exe';
      const bIsSetup = path.basename(b).toLowerCase() === 'setup.exe';

      if (aIsSetup && !bIsSetup) return -1;
      if (!aIsSetup && bIsSetup) return 1;
      return 0;
    });

    return absolutePaths;
  } catch (error) {
    console.error(`Error finding executables in ${gameDir}:`, error);
    return [];
  }
}
