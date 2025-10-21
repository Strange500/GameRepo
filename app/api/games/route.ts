import { NextResponse } from 'next/server';
import { fetchGameData } from '@/src/lib/steamgriddb';
import { discoverGames } from '@/src/lib/gameDiscovery';
import type { Game } from '@/types/game';

export async function GET() {
  try {
    const gamesDir = process.env.GAMES_DIR;

    if (!gamesDir) {
      return NextResponse.json(
        { 
          games: [], 
          error: 'GAMES_DIR environment variable not configured' 
        },
        { status: 500 }
      );
    }

    // Discover games from the directory
    const discoveredGames = discoverGames(gamesDir);

    // Fetch SteamGridDB data for each game
    const gamesWithData = await Promise.all(
      discoveredGames.map(async (game) => {
        const steamData = await fetchGameData(game.title);
        
        // Merge SteamGridDB data with discovered game data
        return {
          id: game.id,
          title: game.title,
          description: steamData?.name || game.title,
          coverImage: steamData?.image || 'https://via.placeholder.com/400x300?text=' + encodeURIComponent(game.title),
          executables: game.executables,
        } as Game;
      })
    );

    return NextResponse.json({ games: gamesWithData });
  } catch (error: any) {
    console.error('Error fetching game data:', error);
    return NextResponse.json(
      { 
        games: [], 
        error: 'Failed to load games' 
      },
      { status: 500 }
    );
  }
}
