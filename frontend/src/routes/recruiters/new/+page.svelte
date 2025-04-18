<script lang="ts">
  import { goto } from '$app/navigation';
  import ProtectedRoute from '$lib/components/ProtectedRoute.svelte';
  import RecruiterForm from '$lib/components/RecruiterForm.svelte';
  import T from '$lib/i18n/T.svelte';
  import { createRecruiter } from '$lib/services/recruiterService';
  import type { Recruiter } from '$lib/services/recruiterService';

  let isSubmitting = false;
  let error = '';

  async function handleSubmit(
    event: CustomEvent<{ recruiter: Partial<Recruiter> }>
  ) {
    const { recruiter } = event.detail;

    if (!recruiter.name || !recruiter.prompt) {
      error = 'Name and prompt are required fields';
      return;
    }

    try {
      isSubmitting = true;
      error = '';

      // The type check ensures name and prompt are present, so we can safely cast
      const newRecruiter = {
        name: recruiter.name,
        prompt: recruiter.prompt,
        telegram_token: recruiter.telegram_token || ''
      };

      await createRecruiter(newRecruiter);

      // Navigate back to recruiters list
      goto('/recruiters');
    } catch (err: any) {
      error = err.message || 'Failed to create recruiter';
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
  <div class="new-recruiter-page">
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
    {/if}

    <RecruiterForm
      formTitle="createRecruiter"
      submitButtonText="saveRecruiter"
      {isSubmitting}
      on:submit={handleSubmit}
      on:cancel={handleCancel}
    />
  </div>
</ProtectedRoute>

<style>
  .new-recruiter-page {
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
</style>
