import { NextResponse } from 'next/server';
import gamesConfig from '@/games-config.json';
import { fetchGameData } from '@/src/lib/steamgriddb';
import type { Game } from '@/types/game';

export async function GET() {
  try {
    // Fetch SteamGridDB data for each game
    const gamesWithData = await Promise.all(
      gamesConfig.games.map(async (game) => {
        const steamData = await fetchGameData(game.title);
        
        // Merge SteamGridDB data with config data
        return {
          ...game,
          // Use SteamGridDB image if available, otherwise use config image
          coverImage: steamData?.image || game.coverImage,
          // Description comes from config
        } as Game;
      })
    );

    return NextResponse.json({ games: gamesWithData });
  } catch (error: any) {
    console.error('Error fetching game data:', error);
    // Return original config data as fallback
    return NextResponse.json({ games: gamesConfig.games });
  }
}
