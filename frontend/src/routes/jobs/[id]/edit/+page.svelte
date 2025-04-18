<script lang="ts">
  import { goto } from '$app/navigation';
  import { onMount } from 'svelte';
  import ProtectedRoute from '$lib/components/ProtectedRoute.svelte';
  import JobForm from '$lib/components/JobForm.svelte';
  import T from '$lib/i18n/T.svelte';
  import { getJob, updateJob } from '$lib/services/jobService';
  import type { Job } from '$lib/services/jobService';
  import { page } from '$app/stores';

  let job: Partial<Job> = {};
  let error = '';
  let loading = false;
  let fetching = true;

  onMount(async () => {
    try {
      const jobId = $page.params.id;
      fetching = true;
      job = await getJob(jobId);
      fetching = false;
    } catch (err: any) {
      error = err.message || 'Failed to load job';
      console.error(error);
      fetching = false;
    }
  });

  async function handleSubmit(event: CustomEvent<{ job: Partial<Job> }>) {
    const jobData = event.detail.job;

    try {
      loading = true;
      await updateJob(job.id as string, jobData);
      goto('/jobs');
    } catch (err: any) {
      error = err.message || 'Failed to update job';
      console.error(error);
      loading = false;
    }
  }

  function handleCancel() {
    goto('/jobs');
  }
</script>

<ProtectedRoute>
  <div class="edit-job-page">
    <div class="page-header">
      <h1><T key="editJob" /></h1>
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
      <JobForm
        {job}
        isSubmitting={loading}
        submitButtonText="saveJob"
        formTitle="editJob"
        on:submit={handleSubmit}
        on:cancel={handleCancel}
      />
    {/if}
  </div>
</ProtectedRoute>

<style>
  .edit-job-page {
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
