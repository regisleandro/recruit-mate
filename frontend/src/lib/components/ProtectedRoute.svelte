<script lang="ts">
  import { auth } from '$lib/stores/auth';
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';

  export let redirectTo = '/auth/login';

  let isLoading = true;

  onMount(() => {
    // Check auth state
    const unsubscribe = auth.subscribe((state) => {
      isLoading = false;

      if (!state.isAuthenticated) {
        goto(redirectTo);
      }
    });

    return unsubscribe;
  });
</script>

{#if isLoading}
  <div class="loading">Loading...</div>
{:else if $auth.isAuthenticated}
  <slot />
{/if}

<style>
  .loading {
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;
    font-size: 1.2rem;
    color: #555;
  }
</style>
