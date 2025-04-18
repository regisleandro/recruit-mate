<script lang="ts">
  import { goto } from '$app/navigation';
  import { auth } from '$lib/stores/auth';
  import T from '$lib/i18n/T.svelte';
  import { currentLang } from '$lib/i18n/store';
  import { translations } from '$lib/i18n/translations';

  let email = '';
  let password = '';
  let loading = false;
  let error: keyof typeof translations.en | null = null;

  async function handleSubmit() {
    loading = true;
    error = null;

    // Form validation
    if (!email || !password) {
      error = 'errorRequiredFields';
      loading = false;
      return;
    }

    try {
      // Use our JWT-based authentication
      await auth.login(email, password);
      goto('/dashboard');
    } catch (e) {
      console.error('Login error:', e);
      error = 'errorInvalidCredentials';
    } finally {
      loading = false;
    }
  }
</script>

<div
  class="min-h-[calc(100vh-4rem)] flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8"
>
  <div class="w-full max-w-md">
    <div class="form-container">
      <div class="text-center">
        <h2
          class="text-3xl font-bold tracking-tight text-gray-900 dark:text-white"
        >
          <T key="login" />
        </h2>
        <p class="mt-2 text-sm text-gray-600 dark:text-gray-400">
          <T key="or" />
          <a
            href="/auth/register"
            class="font-medium text-primary-600 hover:text-primary-500 dark:text-primary-400"
          >
            <T key="createNewAccount" />
          </a>
        </p>
      </div>

      <form class="mt-8 space-y-6" on:submit|preventDefault={handleSubmit}>
        {#if error}
          <div class="rounded-md bg-red-50 dark:bg-red-900/50 p-4">
            <div class="text-sm text-red-700 dark:text-red-200">
              <T key={error} />
            </div>
          </div>
        {/if}

        <div class="space-y-4">
          <div>
            <label for="email" class="form-label">
              <T key="email" />
            </label>
            <input
              id="email"
              name="email"
              type="email"
              required
              class="input-field"
              bind:value={email}
              placeholder={$currentLang === 'en'
                ? 'Enter your email'
                : 'Digite seu email'}
            />
          </div>

          <div>
            <label for="password" class="form-label">
              <T key="password" />
            </label>
            <input
              id="password"
              name="password"
              type="password"
              required
              class="input-field"
              bind:value={password}
              placeholder={$currentLang === 'en'
                ? 'Enter your password'
                : 'Digite sua senha'}
            />
          </div>
        </div>

        <div class="flex items-center justify-between">
          <div class="flex items-center">
            <input
              id="remember-me"
              name="remember-me"
              type="checkbox"
              class="h-4 w-4 rounded border-gray-300 text-primary-600 focus:ring-primary-500 dark:border-gray-600 dark:bg-gray-700"
            />
            <label
              for="remember-me"
              class="ml-2 block text-sm text-gray-900 dark:text-gray-300"
            >
              <T key="rememberMe" />
            </label>
          </div>

          <div class="text-sm">
            <a
              href="/auth/reset-password"
              class="font-medium text-primary-600 hover:text-primary-500 dark:text-primary-400"
            >
              <T key="forgotPassword" />
            </a>
          </div>
        </div>

        <button type="submit" class="btn-primary w-full" disabled={loading}>
          {#if loading}
            <T key="signingIn" />
          {:else}
            <T key="signIn" />
          {/if}
        </button>
      </form>
    </div>
  </div>
</div>
