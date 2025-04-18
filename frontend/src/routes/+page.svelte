<script lang="ts">
  import T from '$lib/i18n/T.svelte';
  import { currentLang } from '$lib/i18n/store';
  import type { Language } from '$lib/i18n/translations';

  function toggleLanguage() {
    $currentLang = $currentLang === 'en' ? 'pt' : 'en';
  }
</script>

<div class="text-center max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
  <h1 class="text-4xl font-bold text-gray-900 dark:text-white sm:text-5xl">
    <T key="appName" />
  </h1>

  <p class="mt-4 text-lg text-gray-600 dark:text-gray-300">
    <T key="tagline" />
  </p>

  <div class="flex flex-col items-center">
    <img
      src="/images/team-illustration.png"
      alt="Team using Recruit-Mate"
      class="w-full max-w-2xl mb-8 rounded-lg shadow-lg"
    />
  </div>
</div>
