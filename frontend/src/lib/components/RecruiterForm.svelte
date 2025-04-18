<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import { goto } from '$app/navigation';
  import T from '$lib/i18n/T.svelte';
  import { translations } from '$lib/i18n/translations';
  import { currentLang } from '$lib/i18n/store';
  import type { Recruiter } from '$lib/services/recruiterService';
  import type { TranslationKey } from '$lib/i18n/translations';

  export let recruiter: Partial<Recruiter> = {
    name: '',
    prompt: '',
    telegram_token: ''
  };
  export let isSubmitting = false;
  export let submitButtonText: TranslationKey = 'saveRecruiter';
  export let formTitle: TranslationKey = 'createRecruiter';

  const dispatch = createEventDispatcher<{
    submit: { recruiter: Partial<Recruiter> };
    cancel: void;
  }>();

  function handleSubmit() {
    dispatch('submit', { recruiter });
  }

  function handleCancel() {
    dispatch('cancel');
  }
</script>

<div class="recruiter-form">
  <h1><T key={formTitle} /></h1>

  <form on:submit|preventDefault={handleSubmit}>
    <div class="form-group">
      <label for="name">
        <T key="recruiterName" />
        <span class="required">*</span>
      </label>
      <input
        id="name"
        type="text"
        bind:value={recruiter.name}
        required
        placeholder={translations[$currentLang].recruiterNamePlaceholder}
      />
    </div>

    <div class="form-group">
      <label for="prompt">
        <T key="recruiterPrompt" />
        <span class="required">*</span>
      </label>
      <textarea
        id="prompt"
        bind:value={recruiter.prompt}
        required
        rows="5"
        placeholder={translations[$currentLang].recruiterPromptPlaceholder}
      ></textarea>
    </div>

    <div class="form-group">
      <label for="telegram_token">
        <T key="recruiterTelegramToken" />
      </label>
      <input
        id="telegram_token"
        type="text"
        bind:value={recruiter.telegram_token}
        placeholder={translations[$currentLang]
          .recruiterTelegramTokenPlaceholder}
      />
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
      <button type="submit" class="submit-button" disabled={isSubmitting}>
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
  .recruiter-form {
    max-width: 600px;
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

  @media (max-width: 768px) {
    .recruiter-form {
      padding: 1.5rem;
    }
  }
</style>
