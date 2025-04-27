<script lang="ts">
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import ProtectedRoute from '$lib/components/ProtectedRoute.svelte';
  import T from '$lib/i18n/T.svelte';
  import {
    getCandidates,
    deleteCandidate
  } from '$lib/services/candidateService';
  import type { Candidate } from '$lib/services/candidateService';

  let candidates: Candidate[] = [];
  let loading = true;
  let error = '';
  let showConfirmDelete = false;
  let candidateToDelete: Candidate | null = null;
  let pageTitle = 'Todos';

  onMount(async () => {
    try {
      loading = true;
      candidates = await getCandidates();
    } catch (err: any) {
      error = err.message || 'Failed to load candidates';
      console.error(error);
    } finally {
      loading = false;
    }
  });

  function handleCreate() {
    goto('/candidates/new');
  }

  function handleEdit(id: string) {
    goto(`/candidates/${id}/edit`);
  }

  function openDeleteConfirm(candidate: Candidate) {
    candidateToDelete = candidate;
    showConfirmDelete = true;
  }

  function closeDeleteConfirm() {
    showConfirmDelete = false;
    candidateToDelete = null;
  }

  async function confirmDelete() {
    if (!candidateToDelete) return;

    try {
      await deleteCandidate(candidateToDelete.id);
      candidates = candidates.filter((c) => c.id !== candidateToDelete?.id);
      closeDeleteConfirm();
    } catch (err: any) {
      error = err.message || 'Failed to delete candidate';
      console.error(error);
    }
  }

  function goBack() {
    window.history.back();
  }

  $: filteredCandidates = candidates;
</script>

<ProtectedRoute>
  <div class="candidates-page">
    <!-- Header with back button and job title -->
    <div class="page-header">
      <button type="button" class="create-button" on:click={handleCreate}>
        <T key="addCandidate" />
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
    {:else if filteredCandidates.length === 0}
      <div class="empty-state">
        <T key="noCandidates" />
      </div>
    {:else}
      <div class="candidates-table-container">
        <table class="candidates-table">
          <thead>
            <tr>
              <th><T key="candidateName" /></th>
              <th><T key="candidateCPF" /></th>
              <th><T key="candidateCurriculum" /></th>
              <th class="actions-column"><T key="actions" /></th>
            </tr>
          </thead>
          <tbody>
            {#each candidates as candidate (candidate.id)}
              <tr>
                <td>{candidate.name}</td>
                <td>{candidate.cpf || '-'}</td>
                <td>
                  {#if candidate.curriculum_url}
                    <a
                      href={candidate.curriculum_url}
                      target="_blank"
                      rel="noopener noreferrer"
                      class="curriculum-link"
                    >
                      <T key="downloadCurriculum" />
                    </a>
                  {:else}
                    <span class="no-curriculum"><T key="noCurriculum" /></span>
                  {/if}
                </td>
                <td class="actions-cell">
                  <button
                    type="button"
                    class="edit-btn"
                    on:click={() => handleEdit(candidate.id)}
                  >
                    <T key="editCandidate" />
                  </button>
                  <button
                    type="button"
                    class="delete-btn"
                    on:click={() => openDeleteConfirm(candidate)}
                  >
                    <T key="deleteCandidate" />
                  </button>
                </td>
              </tr>
            {/each}
          </tbody>
        </table>
      </div>
    {/if}

    {#if showConfirmDelete && candidateToDelete}
      <div class="modal-overlay">
        <div class="delete-confirm-modal">
          <h3><T key="confirmDeleteCandidate" /></h3>
          <p>{candidateToDelete.name}</p>
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
              <T key="deleteCandidate" />
            </button>
          </div>
        </div>
      </div>
    {/if}
  </div>
</ProtectedRoute>

<style>
  .candidates-page {
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

  .candidates-table-container {
    background-color: white;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
    overflow: hidden;
  }

  .candidates-table {
    width: 100%;
    border-collapse: collapse;
  }

  .candidates-table th,
  .candidates-table td {
    padding: 1rem;
    text-align: left;
    border-bottom: 1px solid #eee;
  }

  .candidates-table th {
    background-color: #f9f9f9;
    font-weight: 500;
  }

  .actions-column {
    width: 200px;
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

  .curriculum-link {
    color: #4a90e2;
    text-decoration: none;
  }

  .curriculum-link:hover {
    text-decoration: underline;
  }

  .no-curriculum {
    color: #999;
    font-style: italic;
  }
</style>
