<script lang="ts">
  import { goto } from '$app/navigation';
  import T from '$lib/i18n/T.svelte';
  import { currentLang } from '$lib/i18n/store';
  import { translations } from '$lib/i18n/translations';
  import type { Language } from '$lib/i18n/translations';
  import { auth } from '$lib/stores/auth';

  let fullName = '';
  let email = '';
  let password = '';
  let loading = false;
  let error: keyof typeof translations.en | null = null;
  let language: Language = $currentLang;

  // Update language preference when user changes language
  $: if ($currentLang) {
    language = $currentLang;
  }

  async function handleSubmit() {
    loading = true;
    error = null;

    // Form validation
    if (!fullName || !email || !password) {
      error = 'errorRequiredFields';
      loading = false;
      return;
    }

    // Password strength validation
    if (password.length < 8) {
      error = 'errorPasswordLength';
      loading = false;
      return;
    }

    try {
      // Call the signup API endpoint
      const response = await fetch(
        `${import.meta.env.API_URL || 'http://localhost:3000'}/signup`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            user: {
              email,
              password,
              name: fullName
            }
          })
        }
      );

      if (!response.ok) {
        // Handle API error responses
        const data = await response.json();
        if (data.status && data.status.message) {
          console.error('Registration error:', data.status.message);
        }
        throw new Error('Registration failed');
      }

      // Registration successful - now login with credentials
      await auth.login(email, password);

      // Redirect to dashboard
      goto('/dashboard');
    } catch (err) {
      console.error('Error during registration:', err);
      error = 'errorRegistration';
    } finally {
      loading = false;
    }
  }
</script>

<div
  class="min-h-[calc(100vh-8rem)] flex items-start justify-center py-6 px-4 sm:px-6 lg:px-8 mt-8"
>
  <div class="w-full max-w-md">
    <div class="form-container">
      <div class="text-center">
        <h2
          class="text-3xl font-bold tracking-tight text-gray-900 dark:text-white"
        >
          <T key="register" />
        </h2>
        <p class="mt-2 text-sm text-gray-600 dark:text-gray-400">
          <T key="alreadyHaveAccount" />
          <a
            href="/auth/login"
            class="font-medium text-primary-600 hover:text-primary-500 dark:text-primary-400"
          >
            <T key="signIn" />
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
            <label for="fullName" class="form-label">
              <T key="fullName" />
            </label>
            <input
              id="fullName"
              name="fullName"
              type="text"
              required
              class="input-field"
              bind:value={fullName}
              placeholder={$currentLang === 'en'
                ? 'Enter your full name'
                : 'Digite seu nome completo'}
            />
          </div>

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

        <button type="submit" class="btn-primary w-full" disabled={loading}>
          {#if loading}
            <T key="creatingAccount" />
          {:else}
            <T key="signUp" />
          {/if}
        </button>
      </form>
    </div>
  </div>
</div>
