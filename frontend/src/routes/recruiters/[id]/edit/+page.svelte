<script lang="ts">
  import { onMount } from 'svelte';
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import ProtectedRoute from '$lib/components/ProtectedRoute.svelte';
  import RecruiterForm from '$lib/components/RecruiterForm.svelte';
  import T from '$lib/i18n/T.svelte';
  import {
    getRecruiter,
    updateRecruiter
  } from '$lib/services/recruiterService';
  import type { Recruiter } from '$lib/services/recruiterService';

  let recruiter: Partial<Recruiter> = {};
  let isSubmitting = false;
  let isLoading = true;
  let error = '';

  // Get the recruiter ID from the URL parameter
  $: recruiterId = $page.params.id;

  onMount(async () => {
    try {
      isLoading = true;
      error = '';

      if (!recruiterId) {
        error = 'Recruiter ID is missing';
        return;
      }

      recruiter = await getRecruiter(recruiterId);
    } catch (err: any) {
      error = err.message || 'Failed to load recruiter';
      console.error(error);
    } finally {
      isLoading = false;
    }
  });

  async function handleSubmit(
    event: CustomEvent<{ recruiter: Partial<Recruiter> }>
  ) {
    const updatedRecruiter = event.detail.recruiter;

    if (!updatedRecruiter.name || !updatedRecruiter.prompt) {
      error = 'Name and prompt are required fields';
      return;
    }

    try {
      isSubmitting = true;
      error = '';

      await updateRecruiter(recruiterId, updatedRecruiter);

      // Navigate back to recruiters list
      goto('/recruiters');
    } catch (err: any) {
      error = err.message || 'Failed to update recruiter';
      console.error(error);
    } finally {
      isSubmitting = false;
    }
  }

  function handleCancel() {
    goto('/recruiters');
  }
</script>

<ProtectedRoute>
  <div class="edit-recruiter-page">
    <div class="back-link">
      <a href="/recruiters" class="back-button">
        <span class="back-icon">←</span>
        <T key="back" />
      </a>
    </div>

    {#if error}
      <div class="error-message">
        {error}
      </div>
    {:else if isLoading}
      <div class="loading">
        <T key="loading" />
      </div>
    {:else}
      <RecruiterForm
        formTitle="editRecruiter"
        submitButtonText="saveRecruiter"
        {recruiter}
        {isSubmitting}
        on:submit={handleSubmit}
        on:cancel={handleCancel}
      />
    {/if}
  </div>
</ProtectedRoute>

<style>
  .edit-recruiter-page {
    max-width: 800px;
    margin: 0 auto;
    padding: 2rem;
  }

  .back-link {
    margin-bottom: 1.5rem;
  }

  .back-button {
    display: flex;
    align-items: center;
    color: #4a90e2;
    text-decoration: none;
    font-weight: 500;
    width: fit-content;
  }

  .back-icon {
    margin-right: 0.5rem;
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
