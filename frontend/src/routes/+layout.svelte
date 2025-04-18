<script lang="ts">
  import '../app.css';
  import Navbar from '$lib/components/Navbar.svelte';
</script>

<!-- Main application layout -->
<div class="app-container">
  <!-- Navigation bar that will show/hide items based on auth status -->
  <Navbar />

  <!-- Content area -->
  <main>
    <slot />
  </main>
</div>

<style>
  .app-container {
    display: flex;
    flex-direction: column;
    min-height: 100vh;
  }

  main {
    flex: 1;
    padding: 2rem;
    max-width: 1200px;
    margin: 0 auto;
    width: 100%;
  }
</style>
