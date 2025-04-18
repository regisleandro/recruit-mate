<script lang="ts">
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import ProtectedRoute from '$lib/components/ProtectedRoute.svelte';
  import T from '$lib/i18n/T.svelte';
  import {
    getRecruiters,
    deleteRecruiter
  } from '$lib/services/recruiterService';
  import type { Recruiter } from '$lib/services/recruiterService';

  let recruiters: Recruiter[] = [];
  let loading = true;
  let error = '';
  let showConfirmDelete = false;
  let recruiterToDelete: Recruiter | null = null;

  onMount(async () => {
    try {
      loading = true;
      recruiters = await getRecruiters();
    } catch (err: any) {
      error = err.message || 'Failed to load recruiters';
      console.error(error);
    } finally {
      loading = false;
    }
  });

  function handleCreate() {
    goto('/recruiters/new');
  }

  function handleEdit(id: string) {
    goto(`/recruiters/${id}/edit`);
  }

  function openDeleteConfirm(recruiter: Recruiter) {
    recruiterToDelete = recruiter;
    showConfirmDelete = true;
  }

  function closeDeleteConfirm() {
    showConfirmDelete = false;
    recruiterToDelete = null;
  }

  async function confirmDelete() {
    if (!recruiterToDelete) return;

    try {
      await deleteRecruiter(recruiterToDelete.id);
      recruiters = recruiters.filter((r) => r.id !== recruiterToDelete?.id);
      closeDeleteConfirm();
    } catch (err: any) {
      error = err.message || 'Failed to delete recruiter';
      console.error(error);
    }
  }
</script>

<ProtectedRoute>
  <div class="recruiters-page">
    <div class="page-header">
      <h1><T key="recruitersList" /></h1>
      <button type="button" class="create-button" on:click={handleCreate}>
        <T key="addRecruiter" />
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
    {:else if recruiters.length === 0}
      <div class="empty-state">
        <T key="noRecruiters" />
      </div>
    {:else}
      <div class="recruiters-table-container">
        <table class="recruiters-table">
          <thead>
            <tr>
              <th><T key="recruiterName" /></th>
              <th class="actions-column"><T key="actions" /></th>
            </tr>
          </thead>
          <tbody>
            {#each recruiters as recruiter (recruiter.id)}
              <tr>
                <td>{recruiter.name}</td>
                <td class="actions-cell">
                  <button
                    type="button"
                    class="edit-btn"
                    on:click={() => handleEdit(recruiter.id)}
                  >
                    <T key="editRecruiter" />
                  </button>
                  <button
                    type="button"
                    class="delete-btn"
                    on:click={() => openDeleteConfirm(recruiter)}
                  >
                    <T key="deleteRecruiter" />
                  </button>
                </td>
              </tr>
            {/each}
          </tbody>
        </table>
      </div>
    {/if}

    {#if showConfirmDelete && recruiterToDelete}
      <div class="modal-overlay">
        <div class="delete-confirm-modal">
          <h3><T key="confirmDelete" /></h3>
          <p>{recruiterToDelete.name}</p>
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
              <T key="deleteRecruiter" />
            </button>
          </div>
        </div>
      </div>
    {/if}
  </div>
</ProtectedRoute>

<style>
  .recruiters-page {
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

  .recruiters-table-container {
    background-color: white;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
    overflow: hidden;
  }

  .recruiters-table {
    width: 100%;
    border-collapse: collapse;
  }

  .recruiters-table th,
  .recruiters-table td {
    padding: 1rem;
    text-align: left;
    border-bottom: 1px solid #eee;
  }

  .recruiters-table th {
    background-color: #f5f5f5;
    font-weight: 600;
    color: #333;
  }

  .actions-column {
    width: 200px;
    text-align: center;
  }

  .actions-cell {
    display: flex;
    gap: 0.5rem;
    justify-content: center;
  }

  .edit-btn,
  .delete-btn {
    padding: 0.4rem 0.8rem;
    border: none;
    border-radius: 4px;
    font-size: 0.9rem;
    cursor: pointer;
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
    background-color: #fad3d3;
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
    border-radius: 8px;
    padding: 1.5rem;
    width: 90%;
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

  .cancel-btn {
    background-color: #f0f0f0;
    color: #333;
    border: none;
    border-radius: 4px;
    padding: 0.5rem 1rem;
    cursor: pointer;
  }

  .confirm-delete-btn {
    background-color: #e74c3c;
    color: white;
    border: none;
    border-radius: 4px;
    padding: 0.5rem 1rem;
    cursor: pointer;
  }

  @media (max-width: 768px) {
    .actions-cell {
      flex-direction: column;
      gap: 0.5rem;
    }

    .page-header {
      flex-direction: column;
      gap: 1rem;
      align-items: flex-start;
    }
  }
</style>
