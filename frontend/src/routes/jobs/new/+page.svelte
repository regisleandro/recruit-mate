<script lang="ts">
  import { goto } from '$app/navigation';
  import ProtectedRoute from '$lib/components/ProtectedRoute.svelte';
  import JobForm from '$lib/components/JobForm.svelte';
  import T from '$lib/i18n/T.svelte';
  import { createJob } from '$lib/services/jobService';
  import type { Job } from '$lib/services/jobService';

  let error = '';
  let loading = false;

  async function handleSubmit(
    event: CustomEvent<{ job: Omit<Job, 'id' | 'statusLabel'> }>
  ) {
    const { job } = event.detail;

    try {
      loading = true;
      await createJob(job);
      goto('/jobs');
    } catch (err: any) {
      error = err.message || 'Failed to create job';
      console.error(error);
      loading = false;
    }
  }

  function handleCancel() {
    goto('/jobs');
  }
</script>

<ProtectedRoute>
  <div class="create-job-page">
    <div class="page-header">
      <h1><T key="createJob" /></h1>
    </div>

    {#if error}
      <div class="error-message">
        {error}
      </div>
    {/if}

    <JobForm
      isSubmitting={loading}
      on:submit={handleSubmit}
      on:cancel={handleCancel}
    />
  </div>
</ProtectedRoute>

<style>
  .create-job-page {
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
