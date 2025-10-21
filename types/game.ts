export interface Game {
  id: string;
  title: string;
  description: string;
  coverImage: string;
  executables: string[]; // Array of executable file paths
  selectedExecutable?: string; // Selected executable for installation
}

export type InstallStatus = 'idle' | 'installing' | 'installed' | 'failed';

export interface GameWithStatus extends Game {
  status: InstallStatus;
}

export interface InstallResponse {
  success: boolean;
  message: string;
  gameId: string;
  requiresSelection?: boolean;
  executables?: string[];
}
