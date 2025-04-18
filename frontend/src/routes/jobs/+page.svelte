<script lang="ts">
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import ProtectedRoute from '$lib/components/ProtectedRoute.svelte';
  import T from '$lib/i18n/T.svelte';
  import {
    getJobs,
    deleteJob,
    JobStatusLabels
  } from '$lib/services/jobService';
  import type { Job } from '$lib/services/jobService';

  let jobs: Job[] = [];
  let loading = true;
  let error = '';
  let showConfirmDelete = false;
  let jobToDelete: Job | null = null;

  onMount(async () => {
    try {
      loading = true;
      jobs = await getJobs();
    } catch (err: any) {
      error = err.message || 'Failed to load jobs';
      console.error(error);
    } finally {
      loading = false;
    }
  });

  function handleCreate() {
    goto('/jobs/new');
  }

  function handleEdit(id: string) {
    goto(`/jobs/${id}/edit`);
  }

  function openDeleteConfirm(job: Job) {
    jobToDelete = job;
    showConfirmDelete = true;
  }

  function closeDeleteConfirm() {
    showConfirmDelete = false;
    jobToDelete = null;
  }

  async function confirmDelete() {
    if (!jobToDelete) return;

    try {
      await deleteJob(jobToDelete.id);
      jobs = jobs.filter((j) => j.id !== jobToDelete?.id);
      closeDeleteConfirm();
    } catch (err: any) {
      error = err.message || 'Failed to delete job';
      console.error(error);
    }
  }
</script>

<ProtectedRoute>
  <div class="jobs-page">
    <div class="page-header">
      <h1><T key="jobsList" /></h1>
      <button type="button" class="create-button" on:click={handleCreate}>
        <T key="addJob" />
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
    {:else if jobs.length === 0}
      <div class="empty-state">
        <T key="noJobs" />
      </div>
    {:else}
      <div class="jobs-table-container">
        <table class="jobs-table">
          <thead>
            <tr>
              <th><T key="jobDescription" /></th>
              <th><T key="jobCompany" /></th>
              <th><T key="jobStatus" /></th>
              <th class="actions-column"><T key="actions" /></th>
            </tr>
          </thead>
          <tbody>
            {#each jobs as job (job.id)}
              <tr>
                <td>
                  <div class="job-description-cell">
                    {job.description.substring(0, 100)}
                    {job.description.length > 100 ? '...' : ''}
                  </div>
                </td>
                <td>{job.company?.name || ''}</td>
                <td>
                  <span class="status-badge status-{job.status}"
                    >{job.statusLabel}</span
                  >
                </td>
                <td class="actions-cell">
                  <button
                    type="button"
                    class="edit-btn"
                    on:click={() => handleEdit(job.id)}
                  >
                    <T key="editJob" />
                  </button>
                  <button
                    type="button"
                    class="delete-btn"
                    on:click={() => openDeleteConfirm(job)}
                  >
                    <T key="deleteJob" />
                  </button>
                </td>
              </tr>
            {/each}
          </tbody>
        </table>
      </div>
    {/if}

    {#if showConfirmDelete && jobToDelete}
      <div class="modal-overlay">
        <div class="delete-confirm-modal">
          <h3><T key="confirmDeleteJob" /></h3>
          <p>
            {jobToDelete.description.substring(0, 100)}{jobToDelete.description
              .length > 100
              ? '...'
              : ''}
          </p>
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
              <T key="deleteJob" />
            </button>
          </div>
        </div>
      </div>
    {/if}
  </div>
</ProtectedRoute>

<style>
  .jobs-page {
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

  .jobs-table-container {
    background-color: white;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
    overflow: hidden;
  }

  .jobs-table {
    width: 100%;
    border-collapse: collapse;
  }

  .jobs-table th,
  .jobs-table td {
    padding: 1rem;
    text-align: left;
    border-bottom: 1px solid #eee;
  }

  .jobs-table th {
    background-color: #f9f9f9;
    font-weight: 500;
  }

  .job-description-cell {
    max-width: 400px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .status-badge {
    display: inline-block;
    padding: 0.25rem 0.5rem;
    border-radius: 4px;
    font-size: 0.75rem;
    font-weight: 500;
    text-transform: uppercase;
    color: white;
  }

  .status-draft {
    background-color: #7f8c8d;
  }

  .status-open {
    background-color: #2ecc71;
  }

  .status-on_hold {
    background-color: #f39c12;
  }

  .status-in_review {
    background-color: #3498db;
  }

  .status-interviewing {
    background-color: #9b59b6;
  }

  .status-offer_extended {
    background-color: #1abc9c;
  }

  .status-offer_accepted {
    background-color: #27ae60;
  }

  .status-closed {
    background-color: #34495e;
  }

  .status-archived {
    background-color: #95a5a6;
  }

  .status-offer_declined {
    background-color: #e67e22;
  }

  .status-reopened {
    background-color: #16a085;
  }

  .status-cancelled {
    background-color: #e74c3c;
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
</style>
