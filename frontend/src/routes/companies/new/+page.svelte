<script lang="ts">
  import { goto } from '$app/navigation';
  import ProtectedRoute from '$lib/components/ProtectedRoute.svelte';
  import CompanyForm from '$lib/components/CompanyForm.svelte';
  import T from '$lib/i18n/T.svelte';
  import { createCompany } from '$lib/services/companyService';
  import type { Company } from '$lib/services/companyService';

  let error = '';
  let loading = false;

  async function handleSubmit(
    event: CustomEvent<{ company: Partial<Company> }>
  ) {
    const { company: newCompany } = event.detail;

    try {
      loading = true;
      await createCompany({ name: newCompany.name || '' });
      goto('/companies');
    } catch (err: any) {
      if (err.errors && Object.keys(err.errors).length > 0) {
        // Format validation errors from the API
        error = Object.entries(err.errors)
          .map(([field, messages]) => `${field}: ${messages}`)
          .join(', ');
      } else {
        error = err.message || 'Failed to create company';
      }
      console.error('Company creation error:', err);
      loading = false;
    }
  }

  function handleCancel() {
    goto('/companies');
  }
</script>

<ProtectedRoute>
  <div class="create-company-page">
    <div class="page-header">
      <h1><T key="createCompany" /></h1>
    </div>

    {#if error}
      <div class="error-message">
        {error}
      </div>
    {/if}

    <CompanyForm
      isSubmitting={loading}
      on:submit={handleSubmit}
      on:cancel={handleCancel}
    />
  </div>
</ProtectedRoute>

<style>
  .create-company-page {
    max-width: 800px;
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
