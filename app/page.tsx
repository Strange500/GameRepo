import GameCard from '@/components/GameCard';
import gamesConfig from '@/games-config.json';

export default function Home() {
  return (
    <main className="min-h-screen bg-gray-950">
      {/* Header */}
      <header className="bg-gray-900 border-b border-gray-800">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <h1 className="text-3xl font-bold text-white">Game Catalogue</h1>
          <p className="text-gray-400 mt-2">Browse and install your favorite games</p>
        </div>
      </header>

      {/* Game Grid */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          {gamesConfig.games.map((game) => (
            <GameCard key={game.id} game={game} />
          ))}
        </div>
      </div>

      {/* Footer */}
      <footer className="mt-16 bg-gray-900 border-t border-gray-800">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6 text-center text-gray-400 text-sm">
          <p>Game Catalogue - Install games with ease</p>
        </div>
      </footer>
    </main>
  );
}
