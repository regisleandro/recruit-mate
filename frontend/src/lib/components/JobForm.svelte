<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import T from '$lib/i18n/T.svelte';
  import { translations } from '$lib/i18n/translations';
  import { currentLang } from '$lib/i18n/store';
  import type { Job } from '$lib/services/jobService';
  import { JobStatus, JobStatusLabels } from '$lib/services/jobService';
  import type { TranslationKey } from '$lib/i18n/translations';
  import type { Company } from '$lib/services/companyService';
  import { getCompanies } from '$lib/services/companyService';
  import { onMount } from 'svelte';

  export let job: Partial<Job> = {
    title: '',
    description: '',
    benefits: '',
    keywords: '',
    startTime: new Date(),
    endTime: new Date(),
    intervalTime: 30,
    status: JobStatus.DRAFT,
    prompt: '',
    companyId: ''
  };
  export let isSubmitting = false;
  export let submitButtonText: TranslationKey = 'saveJob';
  export let formTitle: TranslationKey = 'createJob';

  let companies: Company[] = [];
  let loadingCompanies = true;

  onMount(async () => {
    try {
      companies = await getCompanies();
      loadingCompanies = false;

      // Set default company if none selected and companies are available
      if (!job.companyId && companies.length > 0) {
        job.companyId = companies[0].id;
      }

      // Initialize default time values if not set
      if (!job.startTime) {
        job.startTime = parseTimeToDate('09:00');
      }

      if (!job.endTime) {
        job.endTime = parseTimeToDate('18:00');
      }

      // Console log for debugging
      console.log('Job data:', job);
      console.log('Companies:', companies);
    } catch (error) {
      console.error('Error loading companies:', error);
      loadingCompanies = false;
    }
  });

  const dispatch = createEventDispatcher<{
    submit: { job: Partial<Job> };
    cancel: void;
  }>();

  function handleSubmit() {
    dispatch('submit', { job });
  }

  function handleCancel() {
    dispatch('cancel');
  }

  const statusOptions = Object.entries(JobStatus).map(([key, value]) => ({
    value,
    label: JobStatusLabels[value]
  }));

  // Helper to format dates for input
  function formatDateForInput(date: Date | undefined): string {
    if (!date) return '';
    const d = new Date(date);
    return d.toISOString().slice(0, 16); // Format as "YYYY-MM-DDThh:mm"
  }

  // Helper to format time for input
  function getTimeString(date: Date | undefined): string {
    if (!date) return '09:00';
    return date instanceof Date
      ? `${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`
      : date;
  }

  // Helper to parse time string to Date
  function parseTimeToDate(timeString: string): Date {
    const [hours, minutes] = timeString.split(':').map(Number);
    const date = new Date();
    date.setHours(hours, minutes, 0, 0);
    return date;
  }
</script>

<div class="job-form">
  <h1><T key={formTitle} /></h1>

  <form on:submit|preventDefault={handleSubmit}>
    {#if loadingCompanies}
      <div class="loading">
        <T key="loading" />
      </div>
    {:else}
      <div class="form-group">
        <label for="company">
          <T key="jobCompany" />
          <span class="required">*</span>
        </label>
        <select id="company" bind:value={job.companyId} required>
          <option value="" disabled>Select a company</option>
          {#each companies as company}
            <option value={company.id} selected={company.id === job.companyId}
              >{company.name}</option
            >
          {/each}
        </select>
      </div>

      <div class="form-group">
        <label for="title">
          <T key="jobTitle" />
          <span class="required">*</span>
        </label>
        <input
          id="title"
          type="text"
          bind:value={job.title}
          required
          placeholder="Job title"
        />
      </div>

      <div class="form-group">
        <label for="description">
          <T key="jobDescription" />
          <span class="required">*</span>
        </label>
        <textarea
          id="description"
          bind:value={job.description}
          required
          rows="5"
          placeholder={translations[$currentLang].jobDescriptionPlaceholder}
        ></textarea>
      </div>

      <div class="form-group">
        <label for="benefits">
          <T key="jobBenefits" />
        </label>
        <textarea
          id="benefits"
          bind:value={job.benefits}
          rows="3"
          placeholder={translations[$currentLang].jobBenefitsPlaceholder}
        ></textarea>
      </div>

      <div class="form-group">
        <label for="keywords">
          <T key="jobKeywords" />
        </label>
        <input
          id="keywords"
          type="text"
          bind:value={job.keywords}
          placeholder={translations[$currentLang].jobKeywordsPlaceholder}
        />
      </div>

      <div class="form-row">
        <div class="form-group">
          <label for="startTime">
            <T key="jobStartTime" />
            <span class="required">*</span>
          </label>
          <input
            id="startTime"
            type="time"
            value={getTimeString(job.startTime)}
            on:change={(e) =>
              (job.startTime = parseTimeToDate(e.currentTarget.value))}
            required
          />
        </div>

        <div class="form-group">
          <label for="endTime">
            <T key="jobEndTime" />
            <span class="required">*</span>
          </label>
          <input
            id="endTime"
            type="time"
            value={getTimeString(job.endTime)}
            on:change={(e) =>
              (job.endTime = parseTimeToDate(e.currentTarget.value))}
            required
          />
        </div>
      </div>

      <div class="form-row">
        <div class="form-group">
          <label for="intervalTime">
            <T key="jobIntervalTime" />
          </label>
          <input
            id="intervalTime"
            type="number"
            bind:value={job.intervalTime}
            min="1"
            max="120"
          />
        </div>

        <div class="form-group">
          <label for="status">
            <T key="jobStatus" />
            <span class="required">*</span>
          </label>
          <select id="status" bind:value={job.status} required>
            {#each statusOptions as option}
              <option value={option.value}>{option.label}</option>
            {/each}
          </select>
        </div>
      </div>

      <div class="form-group">
        <label for="prompt">
          <T key="jobPrompt" />
        </label>
        <textarea
          id="prompt"
          bind:value={job.prompt}
          rows="5"
          placeholder={translations[$currentLang].jobPromptPlaceholder}
        ></textarea>
      </div>

      <div class="form-actions">
        <button
          type="button"
          class="cancel-button"
          on:click={handleCancel}
          disabled={isSubmitting}
        >
          <T key="cancel" />
        </button>
        <button
          type="submit"
          class="submit-button"
          disabled={isSubmitting || loadingCompanies}
        >
          {#if isSubmitting}
            <T key="loading" />
          {:else}
            <T key={submitButtonText} />
          {/if}
        </button>
      </div>
    {/if}
  </form>
</div>

<style>
  .job-form {
    max-width: 800px;
    margin: 0 auto;
    padding: 2rem;
    background-color: white;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
  }

  h1 {
    color: #333;
    margin-top: 0;
    margin-bottom: 1.5rem;
    font-size: 1.5rem;
  }

  .form-group {
    margin-bottom: 1.5rem;
    width: 100%;
  }

  .form-row {
    display: flex;
    gap: 1rem;
    margin-bottom: 1rem;
  }

  label {
    display: block;
    font-weight: 500;
    margin-bottom: 0.5rem;
    color: #333;
  }

  .required {
    color: #e74c3c;
    margin-left: 0.25rem;
  }

  input,
  select,
  textarea {
    width: 100%;
    padding: 0.75rem;
    border: 1px solid #ddd;
    border-radius: 4px;
    font-size: 1rem;
    transition: border-color 0.2s;
  }

  input:focus,
  select:focus,
  textarea:focus {
    border-color: #4a90e2;
    outline: none;
  }

  textarea {
    resize: vertical;
  }

  .form-actions {
    display: flex;
    justify-content: flex-end;
    gap: 1rem;
    margin-top: 2rem;
  }

  button {
    padding: 0.75rem 1.5rem;
    font-size: 1rem;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    transition: background-color 0.2s;
  }

  button:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }

  .submit-button {
    background-color: #4a90e2;
    color: white;
  }

  .submit-button:hover:not(:disabled) {
    background-color: #357abd;
  }

  .cancel-button {
    background-color: #f0f0f0;
    color: #333;
  }

  .cancel-button:hover:not(:disabled) {
    background-color: #e0e0e0;
  }

  .loading {
    text-align: center;
    padding: 2rem;
    color: #666;
  }

  @media (max-width: 768px) {
    .job-form {
      padding: 1.5rem;
    }

    .form-row {
      flex-direction: column;
      gap: 0;
    }
  }
</style>
