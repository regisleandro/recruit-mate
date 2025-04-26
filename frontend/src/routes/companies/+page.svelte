<script lang="ts">
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import ProtectedRoute from '$lib/components/ProtectedRoute.svelte';
  import T from '$lib/i18n/T.svelte';
  import { getCompanies, deleteCompany } from '$lib/services/companyService';
  import type { Company } from '$lib/services/companyService';

  let companies: Company[] = [];
  let loading = true;
  let error = '';
  let showConfirmDelete = false;
  let companyToDelete: Company | null = null;

  onMount(async () => {
    try {
      loading = true;
      companies = await getCompanies();
    } catch (err: any) {
      error = err.message || 'Failed to load companies';
      console.error(error);
    } finally {
      loading = false;
    }
  });

  function handleCreate() {
    goto('/companies/new');
  }

  function handleEdit(id: string) {
    goto(`/companies/${id}/edit`);
  }

  function openDeleteConfirm(company: Company) {
    companyToDelete = company;
    showConfirmDelete = true;
  }

  function closeDeleteConfirm() {
    showConfirmDelete = false;
    companyToDelete = null;
  }

  async function confirmDelete() {
    if (!companyToDelete) return;

    try {
      await deleteCompany(companyToDelete.id);
      companies = companies.filter((c) => c.id !== companyToDelete?.id);
      closeDeleteConfirm();
    } catch (err: any) {
      error = err.message || 'Failed to delete company';
      console.error(error);
    }
  }
</script>

<ProtectedRoute>
  <div class="companies-page">
    <div class="page-header">
      <button type="button" class="create-button" on:click={handleCreate}>
        <T key="addCompany" />
      </button>
    </div>

    {#if loading}
      <div class="loading">
        <T key="loading" />
      </div>
    {:else if error}
      <div class="error-message">
        {error}
      </div>
    {:else if companies.length === 0}
      <div class="empty-state">
        <T key="noCompanies" />
      </div>
    {:else}
      <div class="companies-table-container">
        <table class="companies-table">
          <thead>
            <tr>
              <th><T key="companyName" /></th>
              <th class="actions-column"><T key="actions" /></th>
            </tr>
          </thead>
          <tbody>
            {#each companies as company (company.id)}
              <tr>
                <td>{company.name}</td>
                <td class="actions-cell">
                  <button
                    type="button"
                    class="edit-btn"
                    on:click={() => handleEdit(company.id)}
                  >
                    <T key="editCompany" />
                  </button>
                  <button
                    type="button"
                    class="delete-btn"
                    on:click={() => openDeleteConfirm(company)}
                  >
                    <T key="deleteCompany" />
                  </button>
                </td>
              </tr>
            {/each}
          </tbody>
        </table>
      </div>
    {/if}

    {#if showConfirmDelete && companyToDelete}
      <div class="modal-overlay">
        <div class="delete-confirm-modal">
          <h3><T key="confirmDeleteCompany" /></h3>
          <p>{companyToDelete.name}</p>
          <div class="modal-actions">
            <button
              type="button"
              class="cancel-btn"
              on:click={closeDeleteConfirm}
            >
              <T key="cancel" />
            </button>
            <button
              type="button"
              class="confirm-delete-btn"
              on:click={confirmDelete}
            >
              <T key="deleteCompany" />
            </button>
          </div>
        </div>
      </div>
    {/if}
  </div>
</ProtectedRoute>

<style>
  .companies-page {
    max-width: 1200px;
    margin: 0 auto;
    padding: 2rem;
  }

  .page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 2rem;
  }

  h1 {
    color: #333;
    margin: 0;
  }

  .create-button {
    background-color: #4a90e2;
    color: white;
    border: none;
    border-radius: 4px;
    padding: 0.5rem 1rem;
    font-size: 1rem;
    cursor: pointer;
    transition: background-color 0.2s;
    margin-left: auto;
  }

  .create-button:hover {
    background-color: #357abd;
  }

  .loading,
  .empty-state,
  .error-message {
    text-align: center;
    padding: 3rem;
    color: #666;
    background-color: #f9f9f9;
    border-radius: 8px;
    margin: 2rem 0;
  }

  .error-message {
    color: #e74c3c;
    background-color: #fdeaea;
  }

  .companies-table-container {
    background-color: white;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
    overflow: hidden;
  }

  .companies-table {
    width: 100%;
    border-collapse: collapse;
  }

  .companies-table th,
  .companies-table td {
    padding: 1rem;
    text-align: left;
    border-bottom: 1px solid #eee;
  }

  .companies-table th {
    background-color: #f9f9f9;
    font-weight: 500;
  }

  .actions-column {
    width: 250px;
  }

  .actions-cell {
    display: flex;
    gap: 0.5rem;
  }

  .edit-btn,
  .delete-btn {
    padding: 0.5rem 1rem;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 0.875rem;
    transition: background-color 0.2s;
  }

  .edit-btn {
    background-color: #f0f0f0;
    color: #333;
  }

  .edit-btn:hover {
    background-color: #e0e0e0;
  }

  .delete-btn {
    background-color: #fdeaea;
    color: #e74c3c;
  }

  .delete-btn:hover {
    background-color: #fcdddd;
  }

  .modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-color: rgba(0, 0, 0, 0.5);
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 1000;
  }

  .delete-confirm-modal {
    background-color: white;
    padding: 1.5rem;
    border-radius: 8px;
    width: 100%;
    max-width: 400px;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  }

  .delete-confirm-modal h3 {
    margin-top: 0;
    color: #333;
  }

  .modal-actions {
    display: flex;
    justify-content: flex-end;
    gap: 1rem;
    margin-top: 1.5rem;
  }

  .cancel-btn,
  .confirm-delete-btn {
    padding: 0.5rem 1rem;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-weight: 500;
    transition: background-color 0.2s;
  }

  .cancel-btn {
    background-color: #f0f0f0;
    color: #333;
  }

  .cancel-btn:hover {
    background-color: #e0e0e0;
  }

  .confirm-delete-btn {
    background-color: #e74c3c;
    color: white;
  }

  .confirm-delete-btn:hover {
    background-color: #d44637;
  }
</style>
