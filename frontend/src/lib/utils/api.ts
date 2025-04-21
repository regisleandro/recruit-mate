import { auth } from '../stores/auth';
import { get } from 'svelte/store';

const API_URL = import.meta.env.API_URL || 'http://localhost:3000';
const API_PREFIX = '/api/v1';

type RequestMethod = 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH';

interface RequestOptions {
  method?: RequestMethod;
  body?: Record<string, unknown>;
  headers?: Record<string, string>;
}

/**
 * Makes an authenticated API request using the stored JWT token
 */
export async function apiRequest<T = Record<string, unknown>>(
  endpoint: string,
  options: RequestOptions = {}
): Promise<T> {
  const authState = get(auth);
  const { token } = authState;

  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    ...options.headers
  };

  // Add authorization header if token exists
  if (token) {
    headers['Authorization'] = token;
  }

  // Normalize the endpoint and add the API prefix
  const normalizedEndpoint = endpoint.startsWith('/') ? endpoint : `/${endpoint}`;
  const url = `${API_URL}${API_PREFIX}${normalizedEndpoint}`;

  const config: RequestInit = {
    method: options.method || 'GET',
    headers,
    body: options.body ? JSON.stringify(options.body) : undefined
  };

  try {
    const response = await fetch(url, config);

    // Handle unauthorized errors (expired token)
    if (response.status === 401) {
      // Log the user out if token is invalid/expired
      auth.logout();
      throw new Error('Your session has expired. Please log in again.');
    }

    if (!response.ok) {
      throw new Error(`API request failed: ${response.status}`);
    }

    // Check if there's content to parse
    const contentType = response.headers.get('content-type');
    if (contentType && contentType.includes('application/json')) {
      return await response.json();
    }

    return {} as T;
  } catch (error) {
    console.error('API request error:', error);
    throw error;
  }
}
