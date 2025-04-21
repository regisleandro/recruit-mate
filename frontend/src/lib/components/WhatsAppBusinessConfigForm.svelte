<script lang="ts">
  import { onMount } from 'svelte';
  import T from '$lib/i18n/T.svelte';
  import { translations } from '$lib/i18n/translations';
  import { currentLang } from '$lib/i18n/store';
  import whatsAppBusinessConfigService, {
    type WhatsAppBusinessConfig,
    type WhatsAppBusinessConfigInput,
    type TestMessageResponse,
    type ErrorDetails
  } from '$lib/services/whatsAppBusinessConfigService';

  export let selectedRecruiterId: string;

  let config: WhatsAppBusinessConfigInput = {
    access_token: '',
    phone_number_id: '',
    business_account_id: '',
    verify_token: ''
  };

  let existingConfig: WhatsAppBusinessConfig | null = null;
  let loading = true;
  let saving = false;
  let error = '';
  let success = '';
  let testMessage = { phone_number: '', message: '' };
  let testMessageResult: TestMessageResponse | null = null;
  let testMessageLoading = false;

  // Modal state for verify token
  let showTokenModal = false;
  let newToken = '';

  // Add a copied indicator state
  let copied = false;

  $: if (selectedRecruiterId) {
    loadConfig();
  }

  async function loadConfig() {
    try {
      loading = true;
      error = '';
      
      existingConfig = await whatsAppBusinessConfigService.getConfig(selectedRecruiterId);
      if (existingConfig) {
        config = {
          access_token: existingConfig.access_token,
          phone_number_id: existingConfig.phone_number_id,
          business_account_id: existingConfig.business_account_id,
          verify_token: existingConfig.verify_token
        };
      } else {
        // Reset the form if no config exists
        config = {
          access_token: '',
          phone_number_id: '',
          business_account_id: '',
          verify_token: ''
        };
      }
    } catch (err) {
      error = 'Failed to load WhatsApp Business configuration';
      console.error(err);
    } finally {
      loading = false;
    }
  }

  const handleSubmit = async () => {
    error = '';
    success = '';
    saving = true;
    
    try {
      if (existingConfig) {
        existingConfig =
          await whatsAppBusinessConfigService.updateConfig(selectedRecruiterId, config);
        // Show success message using the translation key
        success = $currentLang && translations[$currentLang].whatsAppUpdated || 
          'WhatsApp Business configuration updated successfully';
      } else {
        existingConfig =
          await whatsAppBusinessConfigService.createConfig(selectedRecruiterId, config);
        // Show success message using the translation key
        success = $currentLang && translations[$currentLang].whatsAppCreated || 
          'WhatsApp Business configuration created successfully';
      }
      
      // Update the form with the returned values
      config = {
        access_token: existingConfig.access_token,
        phone_number_id: existingConfig.phone_number_id,
        business_account_id: existingConfig.business_account_id,
        verify_token: existingConfig.verify_token
      };
      
      // Clear success message after a few seconds
      setTimeout(() => {
        success = '';
      }, 3000);
    } catch (err: unknown) {
      // Type guard for axios error with response data
      const axiosError = err as { response?: { data?: { errors?: string[], error?: string } } };
      if (axiosError?.response?.data?.errors) {
        error = axiosError.response.data.errors.join(', ');
      } else if (axiosError?.response?.data?.error) {
        error = axiosError.response.data.error;
      } else if (err instanceof Error) {
        error = err.message;
      } else {
        error = 'Failed to save WhatsApp Business configuration';
      }
      console.error(err);
    } finally {
      saving = false;
    }
  };

  const handleDelete = async () => {
    // Get translation for the confirmation message
    const confirmMessage = $currentLang && translations[$currentLang].confirmDeleteWhatsApp || 
      'Are you sure you want to delete this WhatsApp Business configuration?';
      
    if (!confirm(confirmMessage)) {
      return;
    }
    
    error = '';
    success = '';
    saving = true;
    
    try {
      await whatsAppBusinessConfigService.deleteConfig(selectedRecruiterId);
      existingConfig = null;
      config = {
        access_token: '',
        phone_number_id: '',
        business_account_id: '',
        verify_token: ''
      };
      
      // Show success message using the translation key
      success = $currentLang && translations[$currentLang].whatsAppDeleted ||
        'WhatsApp Business configuration deleted successfully';
      
      // Clear success message after a few seconds
      setTimeout(() => {
        success = '';
      }, 3000);
    } catch (err: unknown) {
      if (err instanceof Error) {
        error = err.message;
      } else {
        error = 'Failed to delete WhatsApp Business configuration';
      }
      console.error(err);
    } finally {
      saving = false;
    }
  };

  const sendTestMessage = async () => {
    testMessageLoading = true;
    testMessageResult = null;
    error = '';
    
    try {
      if (!testMessage.phone_number || !testMessage.message) {
        error = 'Phone number and message are required';
        return;
      }
      
      testMessageResult = await whatsAppBusinessConfigService.sendTestMessage(
        selectedRecruiterId,
        testMessage
      );
      
      // Reset the message input (but keep the phone number)
      testMessage.message = '';
    } catch (err: unknown) {
      // Type guard for axios error with response data
      const axiosError = err as { response?: { data?: { error?: string } } };
      if (axiosError?.response?.data?.error) {
        error = axiosError.response.data.error;
      } else if (err instanceof Error) {
        error = err.message;
      } else {
        error = 'Failed to send test message';
      }
      console.error(err);
    } finally {
      testMessageLoading = false;
    }
  };

  const generateToken = () => {
    // Generate a random verify token
    newToken = whatsAppBusinessConfigService.generateVerifyToken();
    showTokenModal = true;
    copied = false;
  };

  const useGeneratedToken = () => {
    config.verify_token = newToken;
    showTokenModal = false;
    copied = false;
  };

  const copyToClipboard = async (text: string) => {
    try {
      await navigator.clipboard.writeText(text);
      copied = true;
      
      // Reset the copied state after 2 seconds
      setTimeout(() => {
        copied = false;
      }, 2000);
    } catch (err) {
      console.error('Failed to copy text: ', err);
    }
  };

  const generateRandomString = (length: number): string => {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let result = '';
    const charactersLength = characters.length;
    
    for (let i = 0; i < length; i++) {
      result += characters.charAt(Math.floor(Math.random() * charactersLength));
    }
    
    return result;
  };
</script>

<div class="whatsapp-config-container">
  <h2 class="text-2xl font-bold mb-4"><T key="whatsapp" /></h2>

  {#if loading}
    <div class="loading-spinner"><T key="loading" /></div>
  {:else}
    {#if success}
      <div class="success-message bg-green-100 text-green-800 p-3 rounded mb-4">
        {success}
      </div>
    {/if}

    <form on:submit|preventDefault={handleSubmit} class="space-y-4">
      <div class="form-group">
        <label for="access_token" class="block font-medium text-gray-700 mb-1">
          <T key="accessToken" />
        </label>
        <input
          type="password"
          id="access_token"
          bind:value={config.access_token}
          class="w-full p-2 border border-gray-300 rounded"
          placeholder={$currentLang ? translations[$currentLang]?.whatsappConfiguration?.accessTokenPlaceholder : "Enter the WhatsApp access token"}
          required
        />
      </div>

      <div class="form-group">
        <label
          for="phone_number_id"
          class="block font-medium text-gray-700 mb-1"
        >
          <T key="phoneNumberId" />
        </label>
        <input
          type="text"
          id="phone_number_id"
          bind:value={config.phone_number_id}
          class="w-full p-2 border border-gray-300 rounded"
          required
        />
      </div>

      <div class="form-group">
        <label
          for="business_account_id"
          class="block font-medium text-gray-700 mb-1"
        >
          <T key="businessAccountId" />
        </label>
        <input
          type="text"
          id="business_account_id"
          bind:value={config.business_account_id}
          class="w-full p-2 border border-gray-300 rounded"
          required
        />
      </div>

      <div class="form-group">
        <label
          for="verify_token"
          class="block font-medium text-gray-700 mb-1"
        >
          <T key="verifyToken" />
        </label>
        <div class="flex items-center">
          {#if config.verify_token}
            <div class="flex-1 p-2 border border-gray-300 rounded-l bg-gray-50 font-mono text-sm">
              {config.verify_token.substring(0, 4)}
              {'•'.repeat(8)}
              {config.verify_token.substring(config.verify_token.length - 4)}
            </div>
          {:else}
            <input
              type="password"
              id="verify_token"
              bind:value={config.verify_token}
              class="flex-1 p-2 border border-gray-300 rounded-l"
              placeholder={$currentLang && translations[$currentLang]?.whatsappConfiguration?.verifyTokenPlaceholder || "No token set"}
              required
            />
          {/if}
          <button
            type="button"
            on:click={generateToken}
            class="bg-blue-500 text-white p-2 rounded-r hover:bg-blue-600"
          >
            <T key="generateToken" />
          </button>
        </div>
        <p class="mt-1 text-sm text-gray-500">
          <T key="whatsappConfigVerifyTokenDesc" />
        </p>
      </div>

      {#if error}
        <div class="error-message text-red-500 p-3 rounded bg-red-100 mb-4">
          {error}
        </div>
      {/if}

      <div class="flex space-x-2">
        <button
          type="submit"
          class="bg-blue-500 text-white p-2 rounded hover:bg-blue-600"
          disabled={saving}
        >
          {#if saving}
            <T key="loading" />
          {:else if existingConfig}
            <T key="saveWhatsApp" />
          {:else}
            <T key="createWhatsApp" />
          {/if}
        </button>

        {#if existingConfig}
          <button
            type="button"
            on:click={handleDelete}
            class="bg-red-500 text-white p-2 rounded hover:bg-red-600"
            disabled={saving}
          >
            {#if saving}
              <T key="loading" />
            {:else}
              <T key="deleteWhatsApp" />
            {/if}
          </button>
        {/if}
      </div>
    </form>

    {#if existingConfig}
      <div class="mt-8">
        <h3 class="text-xl font-semibold mb-2"><T key="testMessage" /></h3>
        <form on:submit|preventDefault={sendTestMessage} class="space-y-4">
          <div class="form-group">
            <label
              for="phone_number"
              class="block font-medium text-gray-700 mb-1"
            >
              <T key="phoneNumber" />
            </label>
            <input
              type="tel"
              id="phone_number"
              bind:value={testMessage.phone_number}
              placeholder={$currentLang && translations[$currentLang]?.whatsappConfiguration?.phoneNumberPlaceholder || "+1234567890"}
              class="w-full p-2 border border-gray-300 rounded"
              required
            />
          </div>

          <div class="form-group">
            <label for="message" class="block font-medium text-gray-700 mb-1">
              <T key="message" />
            </label>
            <textarea
              id="message"
              bind:value={testMessage.message}
              rows="3"
              class="w-full p-2 border border-gray-300 rounded"
              required
            ></textarea>
          </div>

          <button
            type="submit"
            class="bg-green-500 text-white p-2 rounded hover:bg-green-600"
            disabled={testMessageLoading}
          >
            {#if testMessageLoading}
              <T key="loading" />
            {:else}
              <T key="sendMessage" />
            {/if}
          </button>
        </form>

        {#if testMessageResult}
          <div class="mt-4 p-3 bg-green-100 text-green-800 rounded">
            <p class="font-medium">
              Message sent successfully! Message ID: {testMessageResult.message_id}
            </p>
          </div>
        {/if}
      </div>
    {/if}
  {/if}
</div>

{#if showTokenModal}
  <div
    class="modal-overlay fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
  >
    <div
      class="verify-token-modal bg-white p-6 rounded-lg shadow-lg max-w-lg w-full"
    >
      <h3 class="text-xl font-bold mb-4"><T key="verifyTokenGenerated" /></h3>

      <p class="mb-4"><T key="copyToken" /></p>

      <div class="flex flex-col mb-6">
        <div class="flex items-center">
          <div
            class="flex-1 p-2 border border-gray-300 rounded-l font-mono text-sm bg-gray-50 overflow-x-auto"
          >
            {newToken}
          </div>
          <button
            type="button"
            on:click={() => copyToClipboard(newToken)}
            class="{copied ? 'bg-green-500 text-white' : 'bg-gray-200'} p-2 rounded-r hover:bg-gray-300"
          >
            {#if copied}
              ✓
            {:else}
              <T key="copyToClipboard" />
            {/if}
          </button>
        </div>
        <p class="mt-2 text-xs text-gray-500">
          <T key="whatsappConfigVerifyTokenDesc" />
        </p>
      </div>

      <div class="modal-actions flex justify-end space-x-2">
        <button
          type="button"
          on:click={() => (showTokenModal = false)}
          class="bg-gray-500 text-white p-2 rounded hover:bg-gray-600"
        >
          <T key="cancel" />
        </button>
        <button
          type="button"
          on:click={useGeneratedToken}
          class="bg-blue-500 text-white p-2 rounded hover:bg-blue-600"
        >
          <T key="useToken" />
        </button>
      </div>
    </div>
  </div>
{/if}

<style>
  .whatsapp-config-container {
    max-width: 800px;
    margin: 0 auto;
    padding: 1rem;
  }

  .loading-spinner {
    display: flex;
    justify-content: center;
    align-items: center;
    height: 200px;
    color: #666;
  }

  .modal-overlay {
    background-color: rgba(0, 0, 0, 0.5);
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 1000;
  }

  .verify-token-modal {
    background-color: white;
    padding: 2rem;
    border-radius: 0.5rem;
    max-width: 32rem;
    width: 100%;
  }
</style>
