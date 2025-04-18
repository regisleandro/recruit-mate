<script lang="ts">
  import { translations } from './translations';
  import { currentLang } from './store';
  import type { TranslationKey } from './translations';

  export let key: TranslationKey;
</script>

{$currentLang && translations[$currentLang][key]}
