module.exports = {
  root: true,
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:svelte/recommended',
    'prettier'
  ],
  parser: '@typescript-eslint/parser',
  plugins: ['@typescript-eslint', 'prettier'],
  parserOptions: {
    sourceType: 'module',
    ecmaVersion: 2020,
    extraFileExtensions: ['.svelte']
  },
  env: {
    browser: true,
    es2017: true,
    node: true
  },
  overrides: [
    {
      files: ['*.svelte'],
      parser: 'svelte-eslint-parser',
      parserOptions: {
        parser: '@typescript-eslint/parser'
      }
    }
  ],
  rules: {
    // TypeScript specific rules
    '@typescript-eslint/explicit-function-return-type': 'off',
    '@typescript-eslint/no-explicit-any': 'warn',
    '@typescript-eslint/no-unused-vars': ['warn', { argsIgnorePattern: '^_' }],
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
        tabWidth: 2
      }
    ]
  },
  settings: {
    'svelte3/typescript': () => require('typescript')
  }
};
