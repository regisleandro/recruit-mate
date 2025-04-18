<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import T from '$lib/i18n/T.svelte';
  import { translations } from '$lib/i18n/translations';
  import { currentLang } from '$lib/i18n/store';
  import type { Candidate } from '$lib/services/candidateService';
  import type { TranslationKey } from '$lib/i18n/translations';

  export let candidate: Partial<Candidate> = {
    name: '',
    curriculum: null,
    curriculum_url: null,
    curriculum_summary: '',
    cellphone_number: '',
    cpf: ''
  };
  export let isSubmitting = false;
  export let submitButtonText: TranslationKey = 'saveCandidate';
  export let formTitle: TranslationKey = 'createCandidate';

  let curriculumFile: File | null = null;
  let fileError = '';

  const dispatch = createEventDispatcher<{
    submit: { candidate: Partial<Candidate>; file?: File };
    cancel: void;
  }>();

  function handleSubmit() {
    // Clear any previous file errors
    fileError = '';

    // Validate file size if a file is selected
    if (curriculumFile && curriculumFile.size > 5 * 1024 * 1024) {
      fileError = translations[$currentLang].fileTooBig;
      return;
    }

    dispatch('submit', {
      candidate,
      file: curriculumFile || undefined
    });
  }

  function handleCancel() {
    dispatch('cancel');
  }

  function handleFileChange(event: Event) {
    const input = event.target as HTMLInputElement;
    if (input.files && input.files.length > 0) {
      curriculumFile = input.files[0];

      // Check file size
      if (curriculumFile.size > 5 * 1024 * 1024) {
        fileError = translations[$currentLang].fileTooBig;
      } else {
        fileError = '';
      }
    }
  }

  function formatCPF(event: Event) {
    const input = event.target as HTMLInputElement;
    // Remove any non-numeric characters
    candidate.cpf = input.value.replace(/\D/g, '');

    // Limit to 11 digits
    if (candidate.cpf && candidate.cpf.length > 11) {
      candidate.cpf = candidate.cpf.substring(0, 11);
    }
  }

  function formatPhoneNumber(event: Event) {
    const input = event.target as HTMLInputElement;
    // Remove any non-numeric characters
    candidate.cellphone_number = input.value.replace(/\D/g, '');

    // Limit to 11 digits
    if (candidate.cellphone_number && candidate.cellphone_number.length > 11) {
      candidate.cellphone_number = candidate.cellphone_number.substring(0, 11);
    }
  }
</script>

<div class="candidate-form">
  <h1><T key={formTitle} /></h1>

  <form on:submit|preventDefault={handleSubmit}>
    <div class="form-group">
      <label for="name">
        <T key="candidateName" />
        <span class="required">*</span>
      </label>
      <input
        id="name"
        type="text"
        bind:value={candidate.name}
        placeholder={translations[$currentLang].candidateNamePlaceholder}
        required
      />
    </div>

    <div class="form-group">
      <label for="cpf">
        <T key="candidateCPF" />
        <span class="required">*</span>
      </label>
      <input
        id="cpf"
        type="text"
        bind:value={candidate.cpf}
        placeholder={translations[$currentLang].candidateCPFPlaceholder}
        on:input={formatCPF}
        required
        maxlength="11"
      />
    </div>

    <div class="form-group">
      <label for="cellphone_number">
        <T key="candidateCellphone" />
      </label>
      <input
        id="cellphone_number"
        type="text"
        bind:value={candidate.cellphone_number}
        placeholder={translations[$currentLang].candidateCellphonePlaceholder}
        on:input={formatPhoneNumber}
        maxlength="11"
      />
    </div>

    <div class="form-group">
      <label for="curriculum_summary">
        <T key="candidateCurriculumSummary" />
      </label>
      <textarea
        id="curriculum_summary"
        bind:value={candidate.curriculum_summary}
        rows="5"
        placeholder={translations[$currentLang]
          .candidateCurriculumSummaryPlaceholder}
      ></textarea>
    </div>

    <div class="form-group">
      <label for="curriculum">
        <T key="candidateCurriculum" />
      </label>

      {#if candidate.curriculum_url}
        <div class="curriculum-info">
          <a
            href={candidate.curriculum_url}
            target="_blank"
            rel="noopener noreferrer"
            class="download-link"
          >
            <T key="downloadCurriculum" />
          </a>
          <p><T key="replaceCurriculum" /></p>
        </div>
      {/if}

      <input
        id="curriculum"
        type="file"
        accept=".pdf,.doc,.docx,.txt"
        on:change={handleFileChange}
        class="file-input"
      />

      {#if fileError}
        <p class="error-message">{fileError}</p>
      {/if}
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
        disabled={isSubmitting || !!fileError}
      >
        {#if isSubmitting}
          <T key="loading" />
        {:else}
          <T key={submitButtonText} />
        {/if}
      </button>
    </div>
  </form>
</div>

<style>
  .candidate-form {
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
  textarea {
    width: 100%;
    padding: 0.75rem;
    border: 1px solid #ddd;
    border-radius: 4px;
    font-size: 1rem;
    transition: border-color 0.2s;
  }

  input:focus,
  textarea:focus {
    border-color: #4a90e2;
    outline: none;
  }

  textarea {
    resize: vertical;
  }

  .file-input {
    padding: 0.5rem 0;
    border: none;
  }

  .curriculum-info {
    margin-bottom: 1rem;
    padding: 0.75rem;
    background-color: #f8f9fa;
    border-radius: 4px;
  }

  .download-link {
    display: inline-block;
    margin-bottom: 0.5rem;
    color: #4a90e2;
    text-decoration: none;
    font-weight: 500;
  }

  .download-link:hover {
    text-decoration: underline;
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

  .error-message {
    color: #e74c3c;
    font-size: 0.875rem;
    margin-top: 0.5rem;
  }

  @media (max-width: 768px) {
    .candidate-form {
      padding: 1.5rem;
    }
  }
</style>
