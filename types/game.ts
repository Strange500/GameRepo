export interface Game {
  id: string;
  title: string;
  description: string;
  coverImage: string;
  installCommand: string;
}

export type InstallStatus = 'idle' | 'installing' | 'installed' | 'failed';

export interface GameWithStatus extends Game {
  status: InstallStatus;
}

export interface InstallResponse {
  success: boolean;
  message: string;
  gameId: string;
}
