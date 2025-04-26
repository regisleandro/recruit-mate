<script lang="ts">
  import { goto } from '$app/navigation';
  import { page } from '$app/stores';
  import { onMount } from 'svelte';
  import ProtectedRoute from '$lib/components/ProtectedRoute.svelte';
  import T from '$lib/i18n/T.svelte';
  import { getJob } from '$lib/services/jobService';
  import { getCandidates } from '$lib/services/candidateService';
  import {
    createJobApplication,
    JobApplicationStatus,
    JobApplicationStatusLabels
  } from '$lib/services/jobApplicationService';
  import type { Job } from '$lib/services/jobService';
  import type { Candidate } from '$lib/services/candidateService';

  const jobId = $page.params.id;

  let job: Job | null = null;
  let candidates: Candidate[] = [];
  let loading = true;
  let error = '';
  let success = '';

  // Form fields
  let selectedCandidateId = '';
  let status = JobApplicationStatus.PENDING;
  let notes = '';

  // Search
  let searchQuery = '';

  onMount(async () => {
    try {
      loading = true;

      // Load job data
      job = await getJob(jobId);

      // Load candidates
      candidates = await getCandidates();
    } catch (err: any) {
      error = err.message || 'Failed to load data';
      console.error(error);
    } finally {
      loading = false;
    }
  });

  async function handleSubmit() {
    if (!selectedCandidateId) {
      error = 'Please select a candidate';
      return;
    }

    try {
      error = '';
      loading = true;

      await createJobApplication({
        candidateId: selectedCandidateId,
        jobId,
        status,
        notes
      });

      success = 'Job application created successfully';

      // Redirect after short delay
      setTimeout(() => {
        goto(`/jobs/${jobId}/applications`);
      }, 1500);
    } catch (err: any) {
      error = err.message || 'Failed to create job application';
      console.error(error);
    } finally {
      loading = false;
    }
  }

  function handleCancel() {
    goto(`/jobs/${jobId}/applications`);
  }

  // Filter candidates by search query
  $: filteredCandidates = candidates.filter(
    (candidate) =>
      !searchQuery ||
      candidate.name.toLowerCase().includes(searchQuery.toLowerCase())
  );
</script>

<ProtectedRoute>
  <div class="new-application-page">
    <div class="page-header">
      <div class="header-left">
        <button type="button" class="back-button" on:click={handleCancel}>
          &larr; <T key="back" />
        </button>
        <h1>
          <T key="addApplication" />
          {#if job}({job.description.substring(0, 30)}{job.description.length >
            30
              ? '...'
              : ''}){/if}
        </h1>
      </div>
    </div>

    {#if loading && !success}
      <div class="loading">
        <T key="loading" />
      </div>
    {:else if error}
      <div class="error-message">
        {error}
      </div>
    {:else if success}
      <div class="success-message">
        {success}
      </div>
    {:else}
      <div class="application-form-container">
        <form on:submit|preventDefault={handleSubmit}>
          <div class="form-section">
            <h2><T key="candidateInfo" /></h2>

            <div class="search-box">
              <label for="candidate-search"><T key="searchCandidate" /></label>
              <input
                id="candidate-search"
                type="text"
                bind:value={searchQuery}
                placeholder={$page.data?.translations?.searchCandidate ||
                  'Search candidate'}
              />
            </div>

            <div class="candidates-list">
              {#if filteredCandidates.length === 0}
                <div class="empty-state">
                  <T key="noCandidates" />
                </div>
              {:else}
                {#each filteredCandidates as candidate}
                  <div
                    class="candidate-card {selectedCandidateId === candidate.id
                      ? 'selected'
                      : ''}"
                  >
                    <label class="candidate-label">
                      <input
                        type="radio"
                        name="candidate"
                        value={candidate.id}
                        bind:group={selectedCandidateId}
                      />
                      <div class="candidate-info">
                        <h3>{candidate.name}</h3>
                        <p class="candidate-contact">
                          {candidate.cellphone_number}
                        </p>
                        {#if candidate.curriculum_summary}
                          <p class="candidate-summary">
                            {candidate.curriculum_summary.substring(
                              0,
                              100
                            )}{candidate.curriculum_summary.length > 100
                              ? '...'
                              : ''}
                          </p>
                        {/if}
                      </div>
                    </label>
                  </div>
                {/each}
              {/if}
            </div>
          </div>

          <div class="form-section">
            <h2><T key="applicationStatus" /></h2>
            <div class="form-group">
              <label for="status">
                <T key="selectStatus" />
              </label>
              <select id="status" bind:value={status}>
                {#each Object.entries(JobApplicationStatusLabels) as [key, label]}
                  <option value={key}>{label}</option>
                {/each}
              </select>
            </div>

            <div class="form-group">
              <label for="notes">
                <T key="applicationNotes" />
              </label>
              <textarea
                id="notes"
                bind:value={notes}
                rows="5"
                placeholder={$page.data?.translations?.noteText ||
                  'Add notes about this application'}
              ></textarea>
            </div>
          </div>

          <div class="form-actions">
            <button type="button" class="cancel-btn" on:click={handleCancel}>
              <T key="cancel" />
            </button>
            <button
              type="submit"
              class="submit-btn"
              disabled={loading || !selectedCandidateId}
            >
              <T key="saveApplication" />
            </button>
          </div>
        </form>
      </div>
    {/if}
  </div>
</ProtectedRoute>

<style>
  .new-application-page {
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

  h2 {
    color: #444;
    font-size: 1.2rem;
    margin-top: 0;
    margin-bottom: 1rem;
    padding-bottom: 0.5rem;
    border-bottom: 1px solid #eee;
  }

  .loading,
  .empty-state,
  .error-message,
  .success-message {
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

  .success-message {
    color: #27ae60;
    background-color: #eafaf1;
  }

  .application-form-container {
    background-color: white;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
    overflow: hidden;
    padding: 2rem;
  }

  .form-section {
    margin-bottom: 2rem;
  }

  .form-group {
    margin-bottom: 1.5rem;
  }

  .form-group label {
    display: block;
    margin-bottom: 0.5rem;
    font-weight: 500;
    color: #444;
  }

  .search-box {
    margin-bottom: 1rem;
  }

  .search-box label {
    display: block;
    margin-bottom: 0.5rem;
    font-weight: 500;
    color: #444;
  }

  .search-box input {
    width: 100%;
    padding: 0.75rem;
    border: 1px solid #ddd;
    border-radius: 4px;
    font-size: 1rem;
  }

  .candidates-list {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
    gap: 1rem;
    margin-bottom: 1rem;
    max-height: 400px;
    overflow-y: auto;
    padding: 0.5rem;
  }

  .candidate-card {
    border: 1px solid #eee;
    border-radius: 8px;
    padding: 1rem;
    transition: all 0.2s;
  }

  .candidate-card.selected {
    border-color: #4a90e2;
    background-color: #f0f7ff;
  }

  .candidate-card:hover {
    border-color: #ddd;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
  }

  .candidate-label {
    display: flex;
    gap: 1rem;
    cursor: pointer;
  }

  .candidate-info {
    flex: 1;
  }

  .candidate-info h3 {
    margin: 0 0 0.5rem 0;
    font-size: 1rem;
    color: #333;
  }

  .candidate-contact {
    color: #666;
    margin: 0 0 0.5rem 0;
    font-size: 0.9rem;
  }

  .candidate-summary {
    color: #777;
    font-size: 0.85rem;
    margin: 0;
    line-height: 1.4;
  }

  select,
  textarea {
    width: 100%;
    padding: 0.75rem;
    border: 1px solid #ddd;
    border-radius: 4px;
    font-size: 1rem;
    background-color: white;
  }

  select {
    cursor: pointer;
  }

  textarea {
    resize: vertical;
    min-height: 100px;
  }

  .form-actions {
    display: flex;
    justify-content: flex-end;
    gap: 1rem;
    margin-top: 2rem;
  }

  .cancel-btn {
    background-color: #f0f0f0;
    color: #333;
    border: none;
    padding: 0.75rem 1.5rem;
    border-radius: 4px;
    font-size: 1rem;
    cursor: pointer;
    transition: background-color 0.2s;
  }

  .cancel-btn:hover {
    background-color: #e0e0e0;
  }

  .submit-btn {
    background-color: #4a90e2;
    color: white;
    border: none;
    padding: 0.75rem 1.5rem;
    border-radius: 4px;
    font-size: 1rem;
    cursor: pointer;
    transition: background-color 0.2s;
  }

  .submit-btn:hover:not(:disabled) {
    background-color: #357abd;
  }

  .submit-btn:disabled {
    background-color: #a9c6ea;
    cursor: not-allowed;
  }
</style>
