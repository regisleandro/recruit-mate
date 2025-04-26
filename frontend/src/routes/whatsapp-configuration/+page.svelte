<script lang="ts">
  import { onMount } from 'svelte';
  import WhatsAppBusinessConfigForm from '$lib/components/WhatsAppBusinessConfigForm.svelte';
  import ProtectedRoute from '$lib/components/ProtectedRoute.svelte';
  import T from '$lib/i18n/T.svelte';
  import { translations } from '$lib/i18n/translations';
  import { currentLang } from '$lib/i18n/store';
  import { getRecruiters } from '$lib/services/recruiterService';
  import type { Recruiter } from '$lib/services/recruiterService';

  let recruiters: Recruiter[] = [];
  let selectedRecruiterId: string = '';
  let loading = true;
  let error = '';

  // Get the appropriate setup steps based on current language
  $: setupSteps =
    translations[$currentLang]?.whatsAppSetupSteps ||
    translations.en.whatsAppSetupSteps;
  $: webhookUrl =
    translations[$currentLang]?.webhookUrl || translations.en.webhookUrl;

  onMount(async () => {
    try {
      loading = true;
      recruiters = await getRecruiters();
      if (recruiters.length > 0) {
        selectedRecruiterId = recruiters[0].id;
      }
    } catch (err: any) {
      error = err.message || 'Failed to load recruiters';
      console.error(error);
    } finally {
      loading = false;
    }
  });
</script>

<ProtectedRoute>
  <div class="container mx-auto py-8">
    <div class="flex items-center justify-between mb-8">
      <h1 class="text-3xl font-bold">
        <T key="whatsappConfiguration.title" />
      </h1>
    </div>

    <p class="mb-6 text-gray-700">
      <T key="whatsappConfiguration.description" />
      <a
        href="https://developers.facebook.com/apps/"
        target="_blank"
        rel="noopener noreferrer"
        class="text-blue-600 hover:underline">Meta for Developers</a
      > portal.
    </p>

    {#if loading}
      <div class="p-4 bg-gray-100 rounded-lg text-center">
        <T key="loading" />
      </div>
    {:else if error}
      <div class="p-4 bg-red-100 text-red-800 rounded-lg">
        {error}
      </div>
    {:else if recruiters.length === 0}
      <div class="p-4 bg-yellow-100 text-yellow-800 rounded-lg">
        <p>
          <T key="whatsappConfiguration.noRecruitersMessage" />
        </p>
        <a href="/recruiters/new" class="text-blue-600 hover:underline">
          <T key="whatsappConfiguration.createRecruiterLink" />
        </a>
      </div>
    {:else}
      <div class="bg-white rounded-lg shadow p-6 mb-6">
        <div class="mb-4">
          <label
            for="recruiter"
            class="block text-sm font-medium text-gray-700 mb-1"
          >
            <T key="whatsappConfiguration.selectRecruiter" />
          </label>
          <select
            id="recruiter"
            bind:value={selectedRecruiterId}
            class="w-full p-2 border border-gray-300 rounded"
          >
            {#each recruiters as recruiter}
              <option value={recruiter.id}>{recruiter.name}</option>
            {/each}
          </select>
        </div>

        {#if selectedRecruiterId}
          <WhatsAppBusinessConfigForm {selectedRecruiterId} />
        {/if}
      </div>

      <div class="mt-8 p-4 bg-gray-100 rounded-lg">
        <h2 class="text-xl font-semibold mb-2">
          <T key="whatsAppSetupTitle" />
        </h2>
        <ol class="list-decimal ml-6 space-y-2">
          {#each setupSteps as step, i}
            <li>
              {step}
              {#if i === 7}
                <br />
                <code class="bg-gray-200 p-1 text-sm rounded">{webhookUrl}</code
                >
              {/if}
            </li>
          {/each}
        </ol>
      </div>
    {/if}
  </div>
</ProtectedRoute>
