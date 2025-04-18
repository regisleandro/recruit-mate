<script lang="ts">
  import { goto } from '$app/navigation';
  import ProtectedRoute from '$lib/components/ProtectedRoute.svelte';
  import CandidateForm from '$lib/components/CandidateForm.svelte';
  import T from '$lib/i18n/T.svelte';
  import { createCandidate } from '$lib/services/candidateService';
  import type { Candidate } from '$lib/services/candidateService';

  let error = '';
  let loading = false;

  async function handleSubmit(
    event: CustomEvent<{ candidate: Partial<Candidate>; file?: File }>
  ) {
    const { candidate, file } = event.detail;

    try {
      loading = true;
      await createCandidate(
        candidate as Omit<
          Candidate,
          'id' | 'created_at' | 'updated_at' | 'curriculum_url'
        >,
        file
      );
      goto('/candidates');
    } catch (err: any) {
      error = err.message || 'Failed to create candidate';
      console.error(error);
      loading = false;
    }
  }

  function handleCancel() {
    goto('/candidates');
  }
</script>

<ProtectedRoute>
  <div class="create-candidate-page">
    <div class="page-header">
      <h1><T key="createCandidate" /></h1>
    </div>

    {#if error}
      <div class="error-message">
        {error}
      </div>
    {/if}

    <CandidateForm
      isSubmitting={loading}
      on:submit={handleSubmit}
      on:cancel={handleCancel}
    />
  </div>
</ProtectedRoute>

<style>
  .create-candidate-page {
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
</style>
