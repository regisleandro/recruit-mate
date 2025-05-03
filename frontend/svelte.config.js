import adapter from '@sveltejs/adapter-node';
import { vitePreprocess } from '@sveltejs/vite-plugin-svelte';

/** @type {import('@sveltejs/kit').Config} */
const config = {
  kit: {
    // Use the default configuration for adapter-node
    adapter: adapter(),
    alias: {
      $lib: 'src/lib',
      $app: '.svelte-kit/types/@sveltejs/kit/types'
    }
  },
  preprocess: vitePreprocess()
};

export default config;
