<script lang="ts">
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import { page } from '$app/stores';
  import ProtectedRoute from '$lib/components/ProtectedRoute.svelte';
  import T from '$lib/i18n/T.svelte';
  import { getJob } from '$lib/services/jobService';
  import {
    getJobApplications,
    deleteJobApplication,
    JobApplicationStatus,
    JobApplicationStatusLabels
  } from '$lib/services/jobApplicationService';
  import { getCandidates } from '$lib/services/candidateService';
  import type { Job } from '$lib/services/jobService';
  import type { Candidate } from '$lib/services/candidateService';
  import type { JobApplication } from '$lib/services/jobApplicationService';

  const jobId = $page.params.id;
  let job: Job | null = null;
  let applications: JobApplication[] = [];
  let candidates: Candidate[] = [];
  let loading = true;
  let error = '';
  let showConfirmDelete = false;
  let applicationToDelete: JobApplication | null = null;

  // Search and filter variables
  let searchQuery = '';
  let statusFilter = '';
  let startDateFilter = '';
  let endDateFilter = '';

  // Sidebar filter state
  let sidebarOpen = false;

  onMount(async () => {
    try {
      loading = true;
      // Load job data
      job = await getJob(jobId);

      // Load applications for this job
      applications = await getJobApplications({ jobId });

      // Load all candidates for filtering options
      candidates = await getCandidates();
    } catch (err: any) {
      error = err.message || 'Failed to load job applications';
      console.error(error);
    } finally {
      loading = false;
    }
  });

  function handleCreate() {
    goto(`/jobs/${jobId}/applications/new`);
  }

  function handleView(applicationId: string) {
    goto(`/jobs/${jobId}/applications/${applicationId}`);
  }

  function openDeleteConfirm(application: JobApplication) {
    applicationToDelete = application;
    showConfirmDelete = true;
  }

  function closeDeleteConfirm() {
    showConfirmDelete = false;
    applicationToDelete = null;
  }

  async function confirmDelete() {
    if (!applicationToDelete) return;

    try {
      await deleteJobApplication(applicationToDelete.id);
      applications = applications.filter(
        (a) => a.id !== applicationToDelete?.id
      );
      closeDeleteConfirm();
    } catch (err: any) {
      error = err.message || 'Failed to delete application';
      console.error(error);
    }
  }

  function resetFilters() {
    searchQuery = '';
    statusFilter = '';
    startDateFilter = '';
    endDateFilter = '';
    sidebarOpen = false;
  }

  function toggleSidebar() {
    sidebarOpen = !sidebarOpen;
  }

  // Computed property for filtered applications
  $: filteredApplications = applications.filter((application) => {
    // Filter by search query (candidate name)
    if (searchQuery && application.candidate?.name) {
      if (
        !application.candidate.name
          .toLowerCase()
          .includes(searchQuery.toLowerCase())
      ) {
        return false;
      }
    }

    // Filter by status
    if (statusFilter && application.status !== statusFilter) {
      return false;
    }

    // Filter by date range
    if (startDateFilter || endDateFilter) {
      const appDate = new Date(application.createdAt);

      if (startDateFilter) {
        const startDate = new Date(startDateFilter);
        if (appDate < startDate) {
          return false;
        }
      }

      if (endDateFilter) {
        const endDate = new Date(endDateFilter);
        // Set the end date to the end of the day
        endDate.setHours(23, 59, 59, 999);
        if (appDate > endDate) {
          return false;
        }
      }
    }

    return true;
  });
</script>

<ProtectedRoute>
  <div class="applications-page">
    <div class="page-header">
      <div class="header-left">
        <button
          type="button"
          class="back-button"
          on:click={() => goto('/jobs')}
        >
          &larr; <T key="back" />
        </button>
        <h1><T key="jobApplicationsList" />: <b>{job?.title}</b></h1>
      </div>
      <button type="button" class="create-button" on:click={handleCreate}>
        <T key="addApplication" />
      </button>
    </div>

    <div class="main-container">
      <!-- Sidebar filter -->
      <div class={`filter-sidebar ${sidebarOpen ? 'open' : ''}`}>
        <div class="sidebar-header">
          <h3><T key="filters" /></h3>
          <button type="button" class="close-sidebar" on:click={toggleSidebar}>
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="24"
              height="24"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              stroke-linecap="round"
              stroke-linejoin="round"
            >
              <line x1="18" y1="6" x2="6" y2="18"></line>
              <line x1="6" y1="6" x2="18" y2="18"></line>
            </svg>
          </button>
        </div>

        <div class="sidebar-content">
          <div class="filter-group">
            <label for="statusFilter"><T key="status" /></label>
            <select id="statusFilter" bind:value={statusFilter}>
              <option value=""><T key="allStatuses" /></option>
              {#each Object.entries(JobApplicationStatusLabels) as [key, label]}
                <option value={key}>{label}</option>
              {/each}
            </select>
          </div>

          <div class="filter-group">
            <label for="startDateFilter"><T key="fromDate" /></label>
            <input
              id="startDateFilter"
              type="date"
              bind:value={startDateFilter}
            />
          </div>

          <div class="filter-group">
            <label for="endDateFilter"><T key="untilDate" /></label>
            <input id="endDateFilter" type="date" bind:value={endDateFilter} />
          </div>

          <button
            type="button"
            class="reset-filters-btn"
            on:click={resetFilters}
          >
            <T key="clearFilters" />
          </button>
        </div>
      </div>

      <!-- Main content -->
      <div class="content">
        <div class="search-filter-row">
          <div class="search-box">
            <input
              type="text"
              bind:value={searchQuery}
              placeholder="Search candidate by name"
            />
            <button
              type="button"
              class="filter-toggle-btn"
              on:click={toggleSidebar}
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                width="20"
                height="20"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
                <line x1="4" y1="21" x2="4" y2="14"></line>
                <line x1="4" y1="10" x2="4" y2="3"></line>
                <line x1="12" y1="21" x2="12" y2="12"></line>
                <line x1="12" y1="8" x2="12" y2="3"></line>
                <line x1="20" y1="21" x2="20" y2="16"></line>
                <line x1="20" y1="12" x2="20" y2="3"></line>
                <line x1="1" y1="14" x2="7" y2="14"></line>
                <line x1="9" y1="8" x2="15" y2="8"></line>
                <line x1="17" y1="16" x2="23" y2="16"></line>
              </svg>
              <span class="sr-only">Toggle filters</span>
            </button>
          </div>
        </div>

        {#if loading}
          <div class="loading">
            <T key="loading" />
          </div>
        {:else if error}
          <div class="error-message">
            {error}
          </div>
        {:else if filteredApplications.length === 0}
          <div class="empty-state">
            <T key="noApplications" />
          </div>
        {:else}
          <div class="applications-table-container">
            <table class="applications-table">
              <thead>
                <tr>
                  <th><T key="candidateName" /></th>
                  <th><T key="applicationStatus" /></th>
                  <th><T key="applicationDate" /></th>
                  <th class="actions-column"><T key="actions" /></th>
                </tr>
              </thead>
              <tbody>
                {#each filteredApplications as application (application.id)}
                  <tr>
                    <td>{application.candidate?.name || ''}</td>
                    <td>
                      <span class="status-badge status-{application.status}"
                        >{application.statusLabel}</span
                      >
                    </td>
                    <td
                      >{new Date(
                        application.createdAt
                      ).toLocaleDateString()}</td
                    >
                    <td class="actions-cell">
                      <button
                        type="button"
                        class="view-btn"
                        on:click={() => handleView(application.id)}
                      >
                        <T key="viewApplication" />
                      </button>
                      <button
                        type="button"
                        class="delete-btn"
                        on:click={() => openDeleteConfirm(application)}
                      >
                        <T key="deleteApplication" />
                      </button>
                    </td>
                  </tr>
                {/each}
              </tbody>
            </table>
          </div>
        {/if}
      </div>
    </div>

    {#if showConfirmDelete && applicationToDelete}
      <div class="modal-overlay">
        <div class="delete-confirm-modal">
          <h3><T key="confirmDeleteApplication" /></h3>
          <p>
            <strong><T key="candidateName" />:</strong>
            {applicationToDelete.candidate?.name || ''}
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
              <T key="deleteApplication" />
            </button>
          </div>
        </div>
      </div>
    {/if}
  </div>
</ProtectedRoute>

<style>
  .applications-page {
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

  .header-left {
    display: flex;
    align-items: center;
    gap: 1rem;
  }

  .back-button {
    background: none;
    border: none;
    color: #4a90e2;
    cursor: pointer;
    font-size: 1rem;
    padding: 0.5rem;
  }

  h1 {
    color: #333;
    margin: 0;
  }

  /* Main container with sidebar and content */
  .main-container {
    display: flex;
    position: relative;
    margin-bottom: 2rem;
  }

  /* Sidebar styles */
  .filter-sidebar {
    position: fixed;
    top: 0;
    right: -320px;
    width: 320px;
    height: 100vh;
    background-color: white;
    box-shadow: -2px 0 10px rgba(0, 0, 0, 0.1);
    padding: 1.5rem;
    transition: right 0.3s ease;
    z-index: 50;
    overflow-y: auto;
  }

  .filter-sidebar.open {
    right: 0;
  }

  .sidebar-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1.5rem;
    padding-bottom: 0.5rem;
    border-bottom: 1px solid #eee;
  }

  .sidebar-header h3 {
    margin: 0;
    font-size: 1.25rem;
    color: #333;
  }

  .close-sidebar {
    background: none;
    border: none;
    color: #666;
    cursor: pointer;
    padding: 0.25rem;
  }

  .close-sidebar:hover {
    color: #333;
  }

  .sidebar-content {
    display: flex;
    flex-direction: column;
    gap: 1.5rem;
  }

  .filter-group {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }

  .filter-group label {
    font-size: 0.875rem;
    font-weight: 500;
    color: #555;
  }

  .filter-group select,
  .filter-group input {
    padding: 0.75rem;
    border: 1px solid #ddd;
    border-radius: 4px;
    font-size: 0.875rem;
    background-color: white;
  }

  .reset-filters-btn {
    margin-top: 1rem;
    background-color: #f0f0f0;
    color: #333;
    border: 1px solid #ddd;
    padding: 0.75rem 1rem;
    border-radius: 4px;
    font-size: 0.875rem;
    cursor: pointer;
    transition: background-color 0.2s;
  }

  .reset-filters-btn:hover {
    background-color: #e0e0e0;
  }

  /* Content styles */
  .content {
    flex: 1;
  }

  .search-filter-row {
    margin-bottom: 1.5rem;
    background-color: #f9f9f9;
    padding: 1rem;
    border-radius: 8px;
  }

  .search-box {
    display: flex;
    gap: 0.5rem;
  }

  .search-box input {
    flex: 1;
    padding: 0.75rem;
    border: 1px solid #ddd;
    border-radius: 4px;
    font-size: 1rem;
  }

  .filter-toggle-btn {
    display: flex;
    align-items: center;
    justify-content: center;
    background-color: #4a90e2;
    color: white;
    border: none;
    border-radius: 4px;
    padding: 0.75rem;
    cursor: pointer;
    transition: background-color 0.2s;
  }

  .filter-toggle-btn:hover {
    background-color: #357abd;
  }

  .sr-only {
    position: absolute;
    width: 1px;
    height: 1px;
    padding: 0;
    margin: -1px;
    overflow: hidden;
    clip: rect(0, 0, 0, 0);
    white-space: nowrap;
    border-width: 0;
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

  .applications-table-container {
    background-color: white;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
    overflow: hidden;
  }

  .applications-table {
    width: 100%;
    border-collapse: collapse;
  }

  .applications-table th,
  .applications-table td {
    padding: 1rem;
    text-align: left;
    border-bottom: 1px solid #eee;
  }

  .applications-table th {
    background-color: #f9f9f9;
    font-weight: 500;
  }

  .status-badge {
    display: inline-block;
    padding: 0.25rem 0.5rem;
    border-radius: 4px;
    font-size: 0.75rem;
    font-weight: 500;
    text-transform: capitalize;
  }

  .status-pending {
    background-color: #f8f9fa;
    color: #495057;
  }

  .status-reviewing {
    background-color: #e3f2fd;
    color: #0d47a1;
  }

  .status-phone_screen {
    background-color: #e8f5e9;
    color: #1b5e20;
  }

  .status-interviewing {
    background-color: #fff8e1;
    color: #ff6f00;
  }

  .status-technical_test {
    background-color: #f3e5f5;
    color: #7b1fa2;
  }

  .status-reference_check {
    background-color: #e1f5fe;
    color: #0288d1;
  }

  .status-offered {
    background-color: #e0f7fa;
    color: #00796b;
  }

  .status-accepted {
    background-color: #e8f5e9;
    color: #2e7d32;
  }

  .status-rejected {
    background-color: #ffebee;
    color: #c62828;
  }

  .status-withdrawn {
    background-color: #fafafa;
    color: #757575;
  }

  .actions-column {
    width: 200px;
  }

  .actions-cell {
    display: flex;
    gap: 0.5rem;
  }

  .view-btn {
    background-color: #4a90e2;
    color: white;
    border: none;
    padding: 0.4rem 0.6rem;
    border-radius: 4px;
    font-size: 0.75rem;
    cursor: pointer;
    transition: background-color 0.2s;
  }

  .view-btn:hover {
    background-color: #357abd;
  }

  .delete-btn {
    background-color: #e74c3c;
    color: white;
    border: none;
    padding: 0.4rem 0.6rem;
    border-radius: 4px;
    font-size: 0.75rem;
    cursor: pointer;
    transition: background-color 0.2s;
  }

  .delete-btn:hover {
    background-color: #c0392b;
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
    z-index: 100;
  }

  .delete-confirm-modal {
    background-color: white;
    border-radius: 8px;
    padding: 2rem;
    width: 100%;
    max-width: 500px;
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
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
    padding: 0.5rem 1rem;
    border-radius: 4px;
    cursor: pointer;
    transition: background-color 0.2s;
  }

  .cancel-btn:hover {
    background-color: #e0e0e0;
  }

  .confirm-delete-btn {
    background-color: #e74c3c;
    color: white;
    border: none;
    padding: 0.5rem 1rem;
    border-radius: 4px;
    cursor: pointer;
    transition: background-color 0.2s;
  }

  .confirm-delete-btn:hover {
    background-color: #c0392b;
  }
</style>
