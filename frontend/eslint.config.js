import eslint from '@eslint/js';
import tseslint from '@typescript-eslint/eslint-plugin';
import tseslintParser from '@typescript-eslint/parser';
import sveltePlugin from 'eslint-plugin-svelte';
import prettierPlugin from 'eslint-plugin-prettier';
import svelteParser from 'svelte-eslint-parser';

export default [
  {
    files: ['**/*.{js,ts}'],
    ignores: ['node_modules/**', 'build/**', '.svelte-kit/**'],
    languageOptions: {
      parser: tseslintParser,
      parserOptions: {
        ecmaVersion: 2020,
        sourceType: 'module'
      },
      globals: {
        ...eslint.configs.recommended.globals,
        browser: true,
        node: true
      }
    },
    plugins: {
      '@typescript-eslint': tseslint,
      prettier: prettierPlugin
    },
    rules: {
      // TypeScript specific rules
      '@typescript-eslint/explicit-function-return-type': 'off',
      '@typescript-eslint/no-explicit-any': 'warn',
      '@typescript-eslint/no-unused-vars': [
        'warn',
        { argsIgnorePattern: '^_' }
      ],
      '@typescript-eslint/consistent-type-imports': [
        'warn',
        { prefer: 'type-imports' }
      ],

      // General rules
      'no-console': ['warn', { allow: ['warn', 'error'] }],
      'no-debugger': 'warn',
      'no-duplicate-imports': 'error',
      'no-unused-private-class-members': 'warn',
      'no-var': 'error',
      'prefer-const': 'warn',
      'prefer-rest-params': 'warn',
      'prefer-spread': 'warn',

      // Prettier integration
      'prettier/prettier': [
        'warn',
        {
          singleQuote: true,
          semi: true,
          trailingComma: 'none',
          printWidth: 80,
          tabWidth: 2
        }
      ]
    }
  },
  {
    files: ['**/*.svelte'],
    languageOptions: {
      parser: svelteParser,
      parserOptions: {
        parser: tseslintParser,
        sourceType: 'module',
        ecmaVersion: 2020
      }
    },
    plugins: {
      svelte: sveltePlugin,
      prettier: prettierPlugin
    },
    rules: {
      // Svelte specific rules
      'svelte/no-at-html-tags': 'warn',
      'svelte/require-store-callbacks-use-set-param': 'error',
      'svelte/require-store-reactive-access': 'error',
      'svelte/valid-prop-names-in-kit-pages': 'error',
      'svelte/button-has-type': 'error',
      'svelte/no-dom-manipulating': 'warn',
      'svelte/no-dupe-on-directives': 'error',
      'svelte/no-dupe-use-directives': 'error',
      'svelte/no-export-load-in-svelte-module-in-kit-pages': 'error',
      'svelte/no-store-async': 'error',
      'svelte/require-optimized-style-attribute': 'warn',
      'svelte/valid-each-key': 'error',

      // Prettier integration
      'prettier/prettier': [
        'warn',
        {
          singleQuote: true,
          semi: true,
          trailingComma: 'none',
          printWidth: 80,
          tabWidth: 2,
          plugins: ['prettier-plugin-svelte'],
          parser: 'svelte'
        }
      ]
    }
  }
];
