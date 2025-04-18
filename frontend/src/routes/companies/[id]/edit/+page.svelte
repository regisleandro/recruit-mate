<script lang="ts">
  import { goto } from '$app/navigation';
  import { page } from '$app/stores';
  import { onMount } from 'svelte';
  import ProtectedRoute from '$lib/components/ProtectedRoute.svelte';
  import CompanyForm from '$lib/components/CompanyForm.svelte';
  import T from '$lib/i18n/T.svelte';
  import { getCompany, updateCompany } from '$lib/services/companyService';
  import type { Company } from '$lib/services/companyService';

  let company: Partial<Company> = {};
  let error = '';
  let loading = false;
  let pageLoading = true;

  onMount(async () => {
    try {
      const companyId = $page.params.id;
      company = await getCompany(companyId);
      pageLoading = false;
    } catch (err: any) {
      error = err.message || 'Failed to load company';
      console.error(error);
      pageLoading = false;
    }
  });

  async function handleSubmit(
    event: CustomEvent<{ company: Partial<Company> }>
  ) {
    const { company: updatedCompany } = event.detail;

    try {
      loading = true;
      const companyId = $page.params.id;
      await updateCompany(companyId, updatedCompany);
      goto('/companies');
    } catch (err: any) {
      error = err.message || 'Failed to update company';
      console.error(error);
      loading = false;
    }
  }

  function handleCancel() {
    goto('/companies');
  }
</script>

<ProtectedRoute>
  <div class="edit-company-page">
    <div class="page-header">
      <h1><T key="editCompany" /></h1>
    </div>

    {#if error}
      <div class="error-message">
        {error}
      </div>
    {/if}

    {#if pageLoading}
      <div class="loading">
        <T key="loading" />...
      </div>
    {:else}
      <CompanyForm
        {company}
        isSubmitting={loading}
        submitButtonText="saveCompany"
        on:submit={handleSubmit}
        on:cancel={handleCancel}
      />
    {/if}
  </div>
</ProtectedRoute>

<style>
  .edit-company-page {
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

  .loading {
    text-align: center;
    padding: 2rem;
    font-size: 1.2rem;
    color: #666;
  }
</style>
