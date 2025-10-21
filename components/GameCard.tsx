'use client';

import { useState } from 'react';
import type { Game, InstallStatus } from '@/types/game';

interface GameCardProps {
  game: Game;
}

// Helper function to extract filename from path (works in browser)
function getFilename(filePath: string): string {
  return filePath.split(/[/\\]/).pop() || filePath;
}

export default function GameCard({ game }: GameCardProps) {
  const [status, setStatus] = useState<InstallStatus>('idle');
  const [message, setMessage] = useState<string>('');
  const [showExecutableSelection, setShowExecutableSelection] = useState(false);
  const [selectedExecutable, setSelectedExecutable] = useState<string>('');

  const handleInstall = async (executablePath?: string) => {
    setStatus('installing');
    setMessage('');
    setShowExecutableSelection(false);

    try {
      const response = await fetch('/api/install', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ 
          gameId: game.id,
          executablePath: executablePath || (game.executables.length === 1 ? game.executables[0] : undefined)
        }),
      });

      const data = await response.json();

      if (data.success) {
        setStatus('installed');
        setMessage(data.message);
      } else if (data.requiresSelection) {
        // Multiple executables found, show selection UI
        setStatus('idle');
        setShowExecutableSelection(true);
        setMessage('Please select an executable to install');
      } else {
        setStatus('failed');
        setMessage(data.message || 'Installation failed');
      }
    } catch (error) {
      setStatus('failed');
      setMessage('Failed to install game. Please try again.');
      console.error('Install error:', error);
    }
  };

  const handleExecutableSelect = (execPath: string) => {
    setSelectedExecutable(execPath);
    handleInstall(execPath);
  };

  const getStatusColor = () => {
    switch (status) {
      case 'installing':
        return 'bg-blue-500';
      case 'installed':
        return 'bg-green-500';
      case 'failed':
        return 'bg-red-500';
      default:
        return 'bg-gray-800';
    }
  };

  const getButtonText = () => {
    switch (status) {
      case 'installing':
        return 'Installing...';
      case 'installed':
        return 'Installed';
      case 'failed':
        return 'Retry';
      default:
        return 'Install';
    }
  };

  return (
    <div className="group relative bg-gray-900 rounded-lg overflow-hidden shadow-lg transition-transform hover:scale-105 hover:shadow-2xl">
      {/* Cover Image */}
      <div className="relative h-48 overflow-hidden">
        <img
          src={game.coverImage}
          alt={game.title}
          className="w-full h-full object-cover"
        />
        <div className="absolute inset-0 bg-gradient-to-t from-gray-900 to-transparent" />
      </div>

      {/* Game Info */}
      <div className="p-4">
        <h3 className="text-xl font-bold text-white mb-2">{game.title}</h3>
        <p className="text-gray-400 text-sm line-clamp-3">{game.description}</p>
      </div>

      {/* Install Button or Executable Selection - Shows on hover */}
      <div className="absolute inset-0 bg-black bg-opacity-0 group-hover:bg-opacity-60 transition-all flex items-center justify-center opacity-0 group-hover:opacity-100">
        {showExecutableSelection ? (
          <div className="bg-gray-800 rounded-lg p-4 max-w-md mx-4 max-h-96 overflow-y-auto">
            <h4 className="text-white font-semibold mb-3 text-center">Select Executable</h4>
            <div className="space-y-2">
              {game.executables.map((exe) => (
                <button
                  key={exe}
                  onClick={() => handleExecutableSelect(exe)}
                  className="w-full text-left px-4 py-2 bg-gray-700 hover:bg-gray-600 text-white rounded transition-colors text-sm break-all"
                >
                  {getFilename(exe)}
                </button>
              ))}
            </div>
            <button
              onClick={() => setShowExecutableSelection(false)}
              className="mt-3 w-full px-4 py-2 bg-red-600 hover:bg-red-700 text-white rounded transition-colors text-sm"
            >
              Cancel
            </button>
          </div>
        ) : (
          <button
            onClick={() => handleInstall()}
            disabled={status === 'installing' || status === 'installed'}
            className={`${getStatusColor()} text-white px-8 py-3 rounded-lg font-semibold transition-all disabled:opacity-50 disabled:cursor-not-allowed hover:opacity-90 flex items-center gap-2`}
          >
            {status === 'installing' && (
              <svg className="animate-spin h-5 w-5" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
            )}
            {status === 'installed' && (
              <svg className="h-5 w-5" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
                <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
              </svg>
            )}
            {getButtonText()}
          </button>
        )}
      </div>

      {/* Status Message */}
      {message && (
        <div className={`absolute bottom-0 left-0 right-0 p-2 text-center text-sm ${
          status === 'installed' ? 'bg-green-900 text-green-200' : 
          status === 'failed' ? 'bg-red-900 text-red-200' : 
          'bg-blue-900 text-blue-200'
        }`}>
          {message}
        </div>
      )}
    </div>
  );
}
