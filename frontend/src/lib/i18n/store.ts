import { writable } from 'svelte/store';
import { browser } from '$app/environment';
import type { Language } from './translations';

// Get initial language from localStorage or default to 'en'
const initialLang =
  (browser && (localStorage.getItem('lang') as Language)) || 'en';

// Create the store
export const currentLang = writable<Language>(initialLang);

// Subscribe to changes and update localStorage
if (browser) {
  currentLang.subscribe((lang) => {
    localStorage.setItem('lang', lang);
  });
}
