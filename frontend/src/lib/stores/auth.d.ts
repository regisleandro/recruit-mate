import type { Writable } from 'svelte/store';

export interface User {
  id: number;
  email: string;
  name: string;
}

export interface AuthResponse {
  status: {
    code: number;
    message: string;
    data: {
      user: User;
    };
  };
}

export interface AuthState {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
}

export interface AuthStore extends Writable<AuthState> {
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
}
