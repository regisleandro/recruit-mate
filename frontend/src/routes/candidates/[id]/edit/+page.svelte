<script lang="ts">
  import { goto } from '$app/navigation';
  import { onMount } from 'svelte';
  import ProtectedRoute from '$lib/components/ProtectedRoute.svelte';
  import CandidateForm from '$lib/components/CandidateForm.svelte';
  import T from '$lib/i18n/T.svelte';
  import {
    getCandidate,
    updateCandidate
  } from '$lib/services/candidateService';
  import type { Candidate } from '$lib/services/candidateService';
  import { page } from '$app/stores';

  let candidate: Partial<Candidate> = {};
  let error = '';
  let loading = false;
  let fetching = true;

  onMount(async () => {
    try {
      const candidateId = $page.params.id;
      fetching = true;
      candidate = await getCandidate(candidateId);
      fetching = false;
    } catch (err: any) {
      error = err.message || 'Failed to load candidate';
      console.error(error);
      fetching = false;
    }
  });

  async function handleSubmit(
    event: CustomEvent<{ candidate: Partial<Candidate>; file?: File }>
  ) {
    const { candidate: candidateData, file } = event.detail;

    try {
      loading = true;
      await updateCandidate(candidate.id as string, candidateData, file);
      goto('/candidates');
    } catch (err: any) {
      error = err.message || 'Failed to update candidate';
      console.error(error);
      loading = false;
    }
  }

  function handleCancel() {
    goto('/candidates');
  }
</script>

<ProtectedRoute>
  <div class="edit-candidate-page">
    <div class="page-header">
      <h1><T key="editCandidate" /></h1>
    </div>

    {#if error}
      <div class="error-message">
        {error}
      </div>
    {/if}

    {#if fetching}
      <div class="loading">
        <T key="loading" />
      </div>
    {:else}
      <CandidateForm
        {candidate}
        isSubmitting={loading}
        submitButtonText="saveCandidate"
        formTitle="editCandidate"
        on:submit={handleSubmit}
        on:cancel={handleCancel}
      />
    {/if}
  </div>
</ProtectedRoute>

<style>
  .edit-candidate-page {
    max-width: 900px;
    margin: 0 auto;
    padding: 2rem;
  }

  .page-header {
    margin-bottom: 2rem;
  }

  h1 {
    color: #333;
    margin: 0;
  }

  .error-message {
    background-color: #fdeaea;
    color: #e74c3c;
    padding: 1rem;
    border-radius: 4px;
    margin-bottom: 1.5rem;
  }

  .loading {
    text-align: center;
    padding: 3rem;
    color: #666;
    background-color: #f9f9f9;
    border-radius: 8px;
    margin: 2rem 0;
  }
</style>
