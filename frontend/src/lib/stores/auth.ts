import { writable } from 'svelte/store';
import type { AuthStore, AuthState } from './auth.d';

const API_URL = import.meta.env.API_URL || 'http://localhost:3000';

// Initial state
const initialState: AuthState = {
  user: null,
  token: null,
  isAuthenticated: false
};

// Load from localStorage if available
const loadState = (): AuthState => {
  if (typeof localStorage !== 'undefined') {
    const token = localStorage.getItem('token');
    const userStr = localStorage.getItem('user');

    if (token && userStr) {
      try {
        const user = JSON.parse(userStr);
        return {
          user,
          token,
          isAuthenticated: true
        };
      } catch (error) {
        // Failed to parse stored user data
        console.error('Failed to parse stored user data', error);
      }
    }
  }
  return initialState;
};

function createAuthStore(): AuthStore {
  const { subscribe, set, update } = writable<AuthState>(loadState());

  return {
    subscribe,
    login: async (email: string, password: string) => {
      try {
        const response = await fetch(`${API_URL}/login`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ user: { email, password } })
        });

        if (!response.ok) {
          throw new Error(`Login failed: ${response.status}`);
        }

        // Extract token from headers
        const authToken = response.headers.get('Authorization');
        if (!authToken) {
          throw new Error('No authorization token received');
        }

        // Parse the response JSON
        const data = await response.json();

        // Extract user from the response based on Rails API structure
        const user = data.data;

        // Store in localStorage
        localStorage.setItem('token', authToken);
        localStorage.setItem('user', JSON.stringify(user));

        // Update the store
        set({
          user,
          token: authToken,
          isAuthenticated: true
        });

        // Login successful
      } catch (error) {
        console.error('Error during login:', error);
        throw error;
      }
    },
    logout: async () => {
      try {
        const token = localStorage.getItem('token');

        if (token) {
          // Call the logout endpoint if needed
          await fetch(`${API_URL}/logout`, {
            method: 'DELETE',
            headers: {
              Authorization: token,
              'Content-Type': 'application/json'
            }
          });
        }
      } catch (error) {
        console.error('Error during logout:', error);
      } finally {
        // Clear regardless of server response
        localStorage.removeItem('token');
        localStorage.removeItem('user');
        set(initialState);
      }
    },
    set,
    update
  };
}

export const auth = createAuthStore();
