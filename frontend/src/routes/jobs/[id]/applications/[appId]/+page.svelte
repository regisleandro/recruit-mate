<script lang="ts">
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import { page } from '$app/stores';
  import ProtectedRoute from '$lib/components/ProtectedRoute.svelte';
  import T from '$lib/i18n/T.svelte';
  import { 
    getJobApplication, 
    updateJobApplication, 
    addNote,
    JobApplicationStatusLabels 
  } from '$lib/services/jobApplicationService';
  import type { JobApplication } from '$lib/services/jobApplicationService';

  const jobId = $page.params.id;
  const appId = $page.params.appId;
  
  let application: JobApplication | null = null;
  let loading = true;
  let error = '';
  let success = '';
  
  // Form states
  let showStatusForm = false;
  let showNoteForm = false;
  let newStatus = '';
  let newNote = '';
  
  onMount(async () => {
    await loadApplication();
  });
  
  async function loadApplication() {
    try {
      loading = true;
      application = await getJobApplication(appId);
      newStatus = application.status;
    } catch (err: any) {
      error = err.message || 'Failed to load application';
      console.error(error);
    } finally {
      loading = false;
    }
  }

  function toggleStatusForm() {
    showStatusForm = !showStatusForm;
    if (!showStatusForm) {
      newStatus = application?.status || '';
    }
  }

  function toggleNoteForm() {
    showNoteForm = !showNoteForm;
    if (!showNoteForm) {
      newNote = '';
    }
  }

  async function handleStatusUpdate() {
    if (!application || !newStatus) return;
    
    try {
      loading = true;
      error = '';
      
      await updateJobApplication(appId, { status: newStatus });
      
      success = 'Status updated successfully';
      await loadApplication();
      showStatusForm = false;
      
      // Clear success message after delay
      setTimeout(() => {
        success = '';
      }, 3000);
    } catch (err: any) {
      error = err.message || 'Failed to update status';
      console.error(error);
    } finally {
      loading = false;
    }
  }

  async function handleAddNote() {
    if (!application || !newNote.trim()) return;
    
    try {
      loading = true;
      error = '';
      
      await addNote(appId, newNote);
      
      success = 'Note added successfully';
      await loadApplication();
      newNote = '';
      showNoteForm = false;
      
      // Clear success message after delay
      setTimeout(() => {
        success = '';
      }, 3000);
    } catch (err: any) {
      error = err.message || 'Failed to add note';
      console.error(error);
    } finally {
      loading = false;
    }
  }

  function handleBack() {
    goto(`/jobs/${jobId}/applications`);
  }
  
  // Format notes for display
  $: noteEntries = application?.notes 
    ? application.notes.split('---').map(entry => entry.trim()).filter(entry => entry)
    : [];
</script>

<ProtectedRoute>
  <div class="application-detail-page">
    <div class="page-header">
      <div class="header-left">
        <button class="back-button" on:click={handleBack}>
          &larr; <T key="back" />
        </button>
        <h1><T key="jobApplicationDetails" /></h1>
      </div>
    </div>

    {#if loading && !application}
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
    {:else if application}
      <div class="application-container">
        <div class="application-header">
          <div class="application-meta">
            <div class="application-id">ID: {application.id}</div>
            <div class="application-date">
              <T key="applicationDate" />: {new Date(application.createdAt).toLocaleDateString()}
            </div>
          </div>
          <div class="application-status">
            <span class="status-badge status-{application.status}">
              {application.statusLabel}
            </span>
            <button class="change-status-btn" on:click={toggleStatusForm}>
              <T key="changeStatus" />
            </button>
          </div>
        </div>
        
        {#if showStatusForm}
          <div class="status-form">
            <h3><T key="changeStatus" /></h3>
            <select bind:value={newStatus}>
              {#each Object.entries(JobApplicationStatusLabels) as [key, label]}
                <option value={key}>{label}</option>
              {/each}
            </select>
            <div class="form-actions">
              <button class="cancel-btn" on:click={toggleStatusForm}>
                <T key="cancel" />
              </button>
              <button 
                class="submit-btn" 
                on:click={handleStatusUpdate}
                disabled={loading || newStatus === application.status}
              >
                <T key="saveApplication" />
              </button>
            </div>
          </div>
        {/if}
        
        <div class="sections-container">
          <div class="section candidate-section">
            <h2><T key="candidateInfo" /></h2>
            {#if application.candidate}
              <div class="candidate-card">
                <h3>{application.candidate.name}</h3>
                <p class="candidate-contact">{application.candidate.cellphone_number}</p>
                {#if application.candidate.curriculum_url}
                  <a 
                    href={application.candidate.curriculum_url} 
                    target="_blank" 
                    rel="noopener noreferrer"
                    class="curriculum-link"
                  >
                    <T key="downloadCurriculum" />
                  </a>
                {/if}
                {#if application.candidate.curriculum_summary}
                  <div class="curriculum-summary">
                    <h4><T key="candidateCurriculumSummary" /></h4>
                    <p>{application.candidate.curriculum_summary}</p>
                  </div>
                {/if}
              </div>
            {:else}
              <div class="empty-state">
                <T key="noCandidates" />
              </div>
            {/if}
          </div>
          
          <div class="section job-section">
            <h2><T key="jobInfo" /></h2>
            {#if application.job}
              <div class="job-card">
                <h3>{application.job.description.substring(0, 100)}{application.job.description.length > 100 ? '...' : ''}</h3>
                <div class="job-info">
                  <div class="job-section">
                    <h4><T key="jobKeywords" /></h4>
                    <p>{application.job.keywords || 'N/A'}</p>
                  </div>
                  
                  <div class="job-section">
                    <h4><T key="jobBenefits" /></h4>
                    <p>{application.job.benefits || 'N/A'}</p>
                  </div>
                  
                  <div class="job-status">
                    <h4><T key="jobStatus" /></h4>
                    <span class="status-badge status-job-{application.job.status}">
                      {application.job.statusLabel}
                    </span>
                  </div>
                </div>
              </div>
            {:else}
              <div class="empty-state">
                <T key="noJobs" />
              </div>
            {/if}
          </div>
        </div>
        
        <div class="section notes-section">
          <div class="notes-header">
            <h2><T key="applicationNotes" /></h2>
            <button class="add-note-btn" on:click={toggleNoteForm}>
              <T key="addNote" />
            </button>
          </div>
          
          {#if showNoteForm}
            <div class="note-form">
              <textarea
                bind:value={newNote}
                rows="4"
                placeholder={$page.data.translations.noteText}
              ></textarea>
              <div class="form-actions">
                <button class="cancel-btn" on:click={toggleNoteForm}>
                  <T key="cancel" />
                </button>
                <button 
                  class="submit-btn" 
                  on:click={handleAddNote}
                  disabled={loading || !newNote.trim()}
                >
                  <T key="saveNote" />
                </button>
              </div>
            </div>
          {/if}
          
          <div class="notes-list">
            {#if noteEntries.length === 0}
              <div class="empty-notes">
                <p>No notes yet.</p>
              </div>
            {:else}
              {#each noteEntries as note, index}
                <div class="note-entry">
                  {#if note.includes('\n')}
                    {@const [timestamp, ...noteContent] = note.split('\n')}
                    <div class="note-timestamp">{new Date(timestamp).toLocaleString()}</div>
                    <div class="note-content">{noteContent.join('\n')}</div>
                  {:else}
                    <div class="note-content">{note}</div>
                  {/if}
                </div>
              {/each}
            {/if}
          </div>
        </div>
      </div>
    {/if}
  </div>
</ProtectedRoute>

<style>
  .application-detail-page {
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
  
  h3 {
    font-size: 1.1rem;
    margin: 0 0 0.75rem 0;
  }
  
  h4 {
    font-size: 0.9rem;
    margin: 0.5rem 0;
    color: #555;
  }

  .loading,
  .empty-state,
  .error-message,
  .success-message {
    text-align: center;
    padding: 2rem;
    color: #666;
    background-color: #f9f9f9;
    border-radius: 8px;
    margin: 1rem 0;
  }

  .error-message {
    color: #e74c3c;
    background-color: #fdeaea;
  }

  .success-message {
    color: #27ae60;
    background-color: #eafaf1;
  }

  .application-container {
    background-color: white;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
    overflow: hidden;
    padding: 0;
  }
  
  .application-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 1.5rem;
    background-color: #f9f9f9;
    border-bottom: 1px solid #eee;
  }
  
  .application-meta {
    font-size: 0.9rem;
    color: #666;
  }
  
  .application-status {
    display: flex;
    align-items: center;
    gap: 1rem;
  }
  
  .change-status-btn {
    background-color: #f0f0f0;
    border: 1px solid #ddd;
    border-radius: 4px;
    padding: 0.4rem 0.8rem;
    font-size: 0.8rem;
    cursor: pointer;
    transition: background-color 0.2s;
  }
  
  .change-status-btn:hover {
    background-color: #e0e0e0;
  }
  
  .status-badge {
    display: inline-block;
    padding: 0.25rem 0.5rem;
    border-radius: 4px;
    font-size: 0.75rem;
    font-weight: 500;
    text-transform: capitalize;
  }
  
  .sections-container {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 1.5rem;
    padding: 1.5rem;
  }
  
  .section {
    background-color: #f9f9f9;
    border-radius: 8px;
    padding: 1.5rem;
  }
  
  .candidate-card,
  .job-card {
    background-color: white;
    border-radius: 4px;
    padding: 1.5rem;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
  }
  
  .candidate-contact {
    color: #666;
    margin: 0.5rem 0;
  }
  
  .curriculum-link {
    display: inline-block;
    margin: 0.5rem 0;
    color: #4a90e2;
    text-decoration: none;
  }
  
  .curriculum-link:hover {
    text-decoration: underline;
  }
  
  .curriculum-summary {
    margin-top: 1rem;
    font-size: 0.9rem;
  }
  
  .job-info {
    margin-top: 1rem;
  }
  
  .job-section {
    margin-bottom: 1rem;
  }
  
  .job-section p {
    margin: 0;
    font-size: 0.9rem;
  }
  
  .status-badge.status-pending {
    background-color: #f8f9fa;
    color: #495057;
  }

  .status-badge.status-reviewing {
    background-color: #e3f2fd;
    color: #0d47a1;
  }

  .status-badge.status-phone_screen {
    background-color: #e8f5e9;
    color: #1b5e20;
  }

  .status-badge.status-interviewing {
    background-color: #fff8e1;
    color: #ff6f00;
  }

  .status-badge.status-technical_test {
    background-color: #f3e5f5;
    color: #7b1fa2;
  }

  .status-badge.status-reference_check {
    background-color: #e1f5fe;
    color: #0288d1;
  }

  .status-badge.status-offered {
    background-color: #e0f7fa;
    color: #00796b;
  }

  .status-badge.status-accepted {
    background-color: #e8f5e9;
    color: #2e7d32;
  }

  .status-badge.status-rejected {
    background-color: #ffebee;
    color: #c62828;
  }

  .status-badge.status-withdrawn {
    background-color: #fafafa;
    color: #757575;
  }
  
  .status-badge.status-job-draft {
    background-color: #f5f5f5;
    color: #555;
  }
  
  .status-badge.status-job-open {
    background-color: #e0f2f1;
    color: #00695c;
  }
  
  .status-badge.status-job-closed {
    background-color: #f3e5f5;
    color: #6a1b9a;
  }
  
  .notes-section {
    grid-column: 1 / -1;
    margin-top: 1.5rem;
  }
  
  .notes-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
  
  .add-note-btn {
    background-color: #4a90e2;
    color: white;
    border: none;
    border-radius: 4px;
    padding: 0.5rem 1rem;
    font-size: 0.9rem;
    cursor: pointer;
    transition: background-color 0.2s;
  }
  
  .add-note-btn:hover {
    background-color: #357abd;
  }
  
  .notes-list {
    margin-top: 1rem;
  }
  
  .note-entry {
    background-color: white;
    border-radius: 4px;
    padding: 1rem;
    margin-bottom: 1rem;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
  }
  
  .note-timestamp {
    font-size: 0.8rem;
    color: #777;
    margin-bottom: 0.5rem;
  }
  
  .note-content {
    font-size: 0.9rem;
    white-space: pre-line;
  }
  
  .empty-notes {
    text-align: center;
    padding: 2rem;
    color: #999;
  }
  
  .status-form,
  .note-form {
    background-color: #f9f9f9;
    padding: 1.5rem;
    margin: 0 1.5rem 1.5rem;
    border-radius: 8px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
  }
  
  select,
  textarea {
    width: 100%;
    padding: 0.75rem;
    border: 1px solid #ddd;
    border-radius: 4px;
    font-size: 1rem;
    background-color: white;
    margin-bottom: 1rem;
  }
  
  textarea {
    resize: vertical;
    min-height: 100px;
  }
  
  .form-actions {
    display: flex;
    justify-content: flex-end;
    gap: 1rem;
  }
  
  .cancel-btn {
    background-color: #f0f0f0;
    color: #333;
    border: none;
    padding: 0.5rem 1rem;
    border-radius: 4px;
    font-size: 0.9rem;
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
    padding: 0.5rem 1rem;
    border-radius: 4px;
    font-size: 0.9rem;
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

  @media (max-width: 768px) {
    .sections-container {
      grid-template-columns: 1fr;
    }
  }
</style> 