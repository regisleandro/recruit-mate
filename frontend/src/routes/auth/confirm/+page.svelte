<script lang="ts">
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import T from '$lib/i18n/T.svelte';
  import { translations } from '$lib/i18n/translations';
  import { onMount } from 'svelte';

  let status: 'loading' | 'success' | 'error' = 'loading';
  let message: keyof typeof translations.en | null = null;
  let customMessage = '';

  onMount(async () => {
    const confirmationToken = $page.url.searchParams.get('confirmation_token');
    
    if (!confirmationToken) {
      status = 'error';
      message = 'errorMissingToken';
      return;
    }
    
    try {
      const response = await fetch(
        `${import.meta.env.API_URL || 'http://localhost:3000'}/confirm_email?confirmation_token=${confirmationToken}`,
        {
          method: 'GET',
          headers: {
            'Content-Type': 'application/json'
          }
        }
      );
      
      const data = await response.json();
      
      if (response.ok) {
        status = 'success';
        customMessage = data.status?.message || 'Email confirmed successfully! You can now log in.';
      } else {
        status = 'error';
        customMessage = data.status?.message || 'Invalid confirmation token.';
      }
    } catch (err) {
      console.error('Confirmation error:', err);
      status = 'error';
      message = 'errorConfirmation';
    }
  });

  function handleLogin() {
    goto('/auth/login');
  }
</script>

<div class="min-h-[calc(100vh-8rem)] flex items-start justify-center py-6 px-4 sm:px-6 lg:px-8 mt-8">
  <div class="w-full max-w-md">
    <div class="form-container text-center">
      <h2 class="text-3xl font-bold tracking-tight text-gray-900 dark:text-white mb-6">
        <T key="emailConfirmation" />
      </h2>

      {#if status === 'loading'}
        <div class="my-8 flex flex-col items-center justify-center">
          <div class="w-12 h-12 border-4 border-primary-200 border-t-primary-600 rounded-full animate-spin"></div>
          <p class="mt-4 text-gray-600 dark:text-gray-400">
            <T key="verifyingEmail" />
          </p>
        </div>
      {:else if status === 'success'}
        <div class="my-8 rounded-md bg-green-50 dark:bg-green-900/30 p-6">
          <div class="flex items-center justify-center">
            <svg class="h-12 w-12 text-green-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
            </svg>
          </div>
          <p class="mt-4 text-lg text-center text-green-800 dark:text-green-200">
            {customMessage}
          </p>
          <button 
            class="mt-6 btn-primary w-full"
            on:click={handleLogin}
          >
            <T key="signIn" />
          </button>
        </div>
      {:else}
        <div class="my-8 rounded-md bg-red-50 dark:bg-red-900/30 p-6">
          <div class="flex items-center justify-center">
            <svg class="h-12 w-12 text-red-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </div>
          <p class="mt-4 text-lg text-center text-red-800 dark:text-red-200">
            {message ? $translations[$page.data.lang][message] : customMessage}
          </p>
          <div class="mt-6 flex space-x-4">
            <button 
              class="btn-secondary flex-1"
              on:click={() => goto('/auth/register')}
            >
              <T key="signUp" />
            </button>
            <button 
              class="btn-primary flex-1"
              on:click={handleLogin}
            >
              <T key="signIn" />
            </button>
          </div>
        </div>
      {/if}
    </div>
  </div>
</div> 