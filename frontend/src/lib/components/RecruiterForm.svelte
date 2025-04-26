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
    openai_key: ''
  };
  export let isSubmitting = false;
  export let submitButtonText: TranslationKey = 'saveRecruiter';
  export let formTitle: TranslationKey = 'createRecruiter';

  const dispatch = createEventDispatcher<{
    submit: { recruiter: Partial<Recruiter> };
    cancel: void;
  }>();

  // New state to track whether we're changing the OpenAI key
  let isChangingOpenAIKey = false;
  let newOpenAIKey = '';

  // Function to truncate the masked OpenAI key to a reasonable length
  function getTruncatedKey(key: string) {
    if (!key) return '';
    
    // If the key is over 30 characters, truncate it in the middle
    if (key.length > 30) {
      const prefix = key.substring(0, 10);
      const suffix = key.substring(key.length - 10);
      return `${prefix}...${suffix}`;
    }
    
    return key;
  }

  function handleSubmit() {
    const recruiterToSubmit = { ...recruiter };
    
    // If the user has entered a new OpenAI key, use it
    if (isChangingOpenAIKey && newOpenAIKey.trim() !== '') {
      recruiterToSubmit.openai_key = newOpenAIKey.trim();
    } else if (isChangingOpenAIKey && newOpenAIKey.trim() === '') {
      // If the user is changing the key but left it empty, don't update it
      delete recruiterToSubmit.openai_key;
    }
    
    // If not changing the key, keep the original value (which will be masked)
    // but don't actually send it to the API to avoid overwriting with the masked version
    if (!isChangingOpenAIKey) {
      delete recruiterToSubmit.openai_key;
    }
    
    dispatch('submit', { recruiter: recruiterToSubmit });
  }

  function handleCancel() {
    dispatch('cancel');
  }
  
  function toggleOpenAIKeyInput() {
    isChangingOpenAIKey = !isChangingOpenAIKey;
    if (!isChangingOpenAIKey) {
      newOpenAIKey = '';
    }
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
      <label for="openai_key">
        <T key="recruiterOpenAIKey" />
      </label>
      
      {#if recruiter.openai_key && !isChangingOpenAIKey}
        <div class="key-display">
          <span class="masked-key">{getTruncatedKey(recruiter.openai_key)}</span>
          <button 
            type="button" 
            class="change-key-button" 
            on:click={toggleOpenAIKeyInput}
          >
            <T key="recruiterAddNewKey" />
          </button>
        </div>
      {:else if isChangingOpenAIKey}
        <div class="key-input-container">
          <input
            id="openai_key"
            type="text"
            bind:value={newOpenAIKey}
            placeholder={translations[$currentLang].recruiterOpenAIKeyPlaceholder}
          />
          <button 
            type="button" 
            class="cancel-key-button" 
            on:click={toggleOpenAIKeyInput}
          >
            <T key="recruiterCancelKey" />
          </button>
        </div>
      {:else}
        <input
          id="openai_key"
          type="text"
          bind:value={recruiter.openai_key}
          placeholder={translations[$currentLang].recruiterOpenAIKeyPlaceholder}
        />
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
    max-width: 800px;
    margin: 0 auto;
    padding: 2rem;
    border-radius: 8px;
    background-color: #ffffff;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
  }

  /* Add media query for smaller screens */
  @media (max-width: 768px) {
    .recruiter-form {
      padding: 1rem;
    }
    
    .key-display {
      flex-direction: column;
      align-items: stretch;
      gap: 0.5rem;
    }
    
    .masked-key {
      max-width: 100%; /* Allow full width on mobile */
    }
    
    .change-key-button {
      align-self: flex-start;
    }
    
    .key-input-container {
      flex-direction: column;
      gap: 0.5rem;
    }
    
    .cancel-key-button {
      align-self: flex-start;
    }
    
    .form-actions {
      flex-direction: column-reverse;
    }
    
    .submit-button, .cancel-button {
      width: 100%;
      text-align: center;
    }
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
    margin-bottom: 0.5rem;
    font-weight: 500;
    color: #333;
  }

  .required {
    color: #e74c3c;
    margin-left: 4px;
  }

  input,
  textarea {
    width: 100%;
    padding: 0.75rem;
    border: 1px solid #ddd;
    border-radius: 4px;
    font-size: 1rem;
    font-family: inherit;
  }

  input:focus,
  textarea:focus {
    border-color: #4a90e2;
    outline: none;
  }

  .form-actions {
    display: flex;
    justify-content: flex-end;
    gap: 1rem;
    margin-top: 2rem;
  }

  .cancel-button {
    background-color: transparent;
    color: #666;
    border: 1px solid #ddd;
    padding: 0.5rem 1rem;
    border-radius: 4px;
    font-size: 1rem;
    cursor: pointer;
    transition: all 0.2s;
  }

  .cancel-button:hover {
    background-color: #f5f5f5;
  }

  .submit-button {
    background-color: #4a90e2;
    color: white;
    border: none;
    padding: 0.5rem 1.5rem;
    border-radius: 4px;
    font-size: 1rem;
    cursor: pointer;
    transition: background-color 0.2s;
  }

  .submit-button:hover {
    background-color: #357abd;
  }

  .submit-button:disabled,
  .cancel-button:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }
  
  /* New styles for key display and change button */
  .key-display {
    display: flex;
    align-items: center;
    gap: 1rem;
  }
  
  .masked-key {
    font-family: monospace;
    background-color: #f9f9f9;
    padding: 0.75rem;
    border-radius: 4px;
    border: 1px solid #ddd;
    flex-grow: 1;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    max-width: 300px;
  }
  
  .change-key-button, 
  .cancel-key-button {
    background-color: #f0f0f0;
    border: 1px solid #ddd;
    border-radius: 4px;
    padding: 0.5rem 1rem;
    cursor: pointer;
    font-size: 0.875rem;
    transition: all 0.2s;
    white-space: nowrap;
    flex-shrink: 0;
  }
  
  .change-key-button:hover {
    background-color: #e8e8e8;
  }
  
  .cancel-key-button {
    background-color: #f5f5f5;
    color: #666;
  }
  
  .cancel-key-button:hover {
    background-color: #e8e8e8;
  }
  
  .key-input-container {
    display: flex;
    gap: 0.5rem;
  }
  
  .key-input-container input {
    flex-grow: 1;
  }
</style>
