<script lang="ts">
  import { auth } from '$lib/stores/auth';
  import { goto } from '$app/navigation';
  import T from '$lib/i18n/T.svelte';
  import { currentLang } from '$lib/i18n/store';
  import type { Language } from '$lib/i18n/translations';

  function handleLogout() {
    auth.logout();
    goto('/auth/login');
  }

  function toggleLanguage() {
    $currentLang = $currentLang === 'en' ? 'pt' : 'en';
  }

  $: if ($currentLang) {
    language = $currentLang;
  }

  let language = $currentLang;
</script>

<nav>
  <div class="logo">
    <a href="/">Recruit Mate</a>
  </div>

  <div class="nav-links">
    {#if $auth.isAuthenticated}
      <a href="/dashboard"><T key="home" /></a>
      <a href="/recruiters"><T key="recruiters" /></a>
      <a href="/jobs"><T key="jobs" /></a>
      <a href="/companies"><T key="companies" /></a>
      <a href="/candidates"><T key="candidates" /></a>
      <button type="button" on:click={handleLogout} class="logout-btn">
        <T key="logout" />
      </button>
    {:else}
      <a href="/auth/login"><T key="login" /></a>
      <a href="/auth/register" class="register-btn"><T key="register" /></a>
      <button on:click={toggleLanguage} class="lang-toggle-btn" type="button">
        <T key="changeLanguage" />
      </button>
    {/if}
  </div>
</nav>

<style>
  nav {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 1rem 2rem;
    background-color: #ffffff;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  }

  .logo a {
    font-size: 1.5rem;
    font-weight: bold;
    color: #4a90e2;
    text-decoration: none;
  }

  .nav-links {
    display: flex;
    gap: 1.5rem;
    align-items: center;
  }

  .nav-links a {
    color: #333;
    text-decoration: none;
    font-weight: 500;
  }

  .nav-links a:hover {
    color: #4a90e2;
  }

  .register-btn {
    background-color: #4a90e2;
    color: white !important;
    padding: 0.5rem 1rem;
    border-radius: 4px;
  }

  .logout-btn {
    background: none;
    border: none;
    color: #333;
    cursor: pointer;
    font-weight: 500;
    font-size: 1rem;
    padding: 0;
  }

  .logout-btn:hover {
    color: #e74c3c;
  }

  .lang-toggle-btn {
    background-color: #f0f0f0;
    color: #333;
    border: none;
    border-radius: 4px;
    padding: 0.5rem 1rem;
    font-size: 0.875rem;
    font-weight: 500;
    cursor: pointer;
    transition: background-color 0.2s;
  }

  .lang-toggle-btn:hover {
    background-color: #e0e0e0;
  }
</style>
