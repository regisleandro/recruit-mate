<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import { goto } from '$app/navigation';
  import T from '$lib/i18n/T.svelte';
  import { translations } from '$lib/i18n/translations';
  import { currentLang } from '$lib/i18n/store';
  import type { Company } from '$lib/services/companyService';
  import type { TranslationKey } from '$lib/i18n/translations';

  export let company: Partial<Company> = {
    name: ''
  };
  export let isSubmitting = false;
  export let submitButtonText: TranslationKey = 'saveCompany';
  export let formTitle: TranslationKey = 'createCompany';

  const dispatch = createEventDispatcher<{
    submit: { company: Partial<Company> };
    cancel: void;
  }>();

  function handleSubmit() {
    dispatch('submit', { company });
  }

  function handleCancel() {
    dispatch('cancel');
  }
</script>

<div class="company-form">
  <h1><T key={formTitle} /></h1>

  <form on:submit|preventDefault={handleSubmit}>
    <div class="form-group">
      <label for="name">
        <T key="companyName" />
        <span class="required">*</span>
      </label>
      <input
        id="name"
        type="text"
        bind:value={company.name}
        required
        placeholder={translations[$currentLang].companyNamePlaceholder}
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
  .company-form {
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

  input {
    width: 100%;
    padding: 0.75rem;
    border: 1px solid #ddd;
    border-radius: 4px;
    font-size: 1rem;
    transition: border-color 0.2s;
  }

  input:focus {
    border-color: #4a90e2;
    outline: none;
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
    .company-form {
      padding: 1.5rem;
    }
  }
</style>
