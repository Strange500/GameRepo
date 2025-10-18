import SGDB from "steamgriddb";
import fs from "fs";
import path from "path";

const client = new SGDB({
  key: process.env.STEAMGRIDDB_API_KEY!,
  baseURL: "https://www.steamgriddb.com/api/v2",
});

const CACHE_DIR = path.join(process.cwd(), ".cache");
const CACHE_FILE = path.join(CACHE_DIR, "steamgriddb.json");

interface CachedGameData {
  id: number;
  name: string;
  image: string | null;
  cachedAt: number;
}

interface GameCache {
  [gameName: string]: CachedGameData;
}

// Cache duration: 7 days
const CACHE_DURATION = 7 * 24 * 60 * 60 * 1000;

function loadCache(): GameCache {
  try {
    if (fs.existsSync(CACHE_FILE)) {
      const data = fs.readFileSync(CACHE_FILE, "utf-8");
      return JSON.parse(data);
    }
  } catch (error) {
    console.error("Error loading cache:", error);
  }
  return {};
}

function saveCache(cache: GameCache): void {
  try {
    if (!fs.existsSync(CACHE_DIR)) {
      fs.mkdirSync(CACHE_DIR, { recursive: true });
    }
    fs.writeFileSync(CACHE_FILE, JSON.stringify(cache, null, 2));
  } catch (error) {
    console.error("Error saving cache:", error);
  }
}

export async function fetchGameData(gameName: string) {
  // Check if API key is configured
  if (!process.env.STEAMGRIDDB_API_KEY) {
    console.warn("STEAMGRIDDB_API_KEY not configured");
    return null;
  }

  // Check cache first
  const cache = loadCache();
  const cached = cache[gameName];
  
  if (cached && Date.now() - cached.cachedAt < CACHE_DURATION) {
    console.log(`Using cached data for ${gameName}`);
    return {
      id: cached.id,
      name: cached.name,
      image: cached.image,
    };
  }

  try {
    // Search for the game
    const games = await client.searchGame(gameName);
    if (!games.length) {
      console.log(`No SteamGridDB results for ${gameName}`);
      return null;
    }

    const game = games[0];
    
    // Fetch grids for the first match
    const grids = await client.getGrids({ type: "game", id: game.id });

    const result = {
      id: game.id,
      name: game.name,
      image: grids[0]?.url ? grids[0].url.toString() : null,
    };

    // Update cache
    cache[gameName] = {
      ...result,
      cachedAt: Date.now(),
    };
    saveCache(cache);

    return result;
  } catch (error: any) {
    console.error(`SteamGridDB error for ${gameName}:`, error.message);
    return null;
  }
}
