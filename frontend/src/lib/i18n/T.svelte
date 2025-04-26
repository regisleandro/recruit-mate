<script lang="ts">
  import { translations } from './translations';
  import { currentLang } from './store';
  import type { TranslationKey } from './translations';

  export let key: string;

  function getNestedTranslation(obj: any, path: string): string {
    const keys = path.split('.');
    let result = obj;

    for (const k of keys) {
      if (result && typeof result === 'object' && k in result) {
        result = result[k];
      } else {
        return path; // Return the key path if translation not found
      }
    }

    return result;
  }
</script>

{#if $currentLang}
  {getNestedTranslation(translations[$currentLang], key)}
{/if}
