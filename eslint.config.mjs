import tseslint from 'typescript-eslint';

export default tseslint.config(
  { ignores: ['**/node_modules/**', '**/dist/**', '**/.next/**', '**/android/**', '**/ios/**', '**/src/generated/**', '**/next-env.d.ts'] },
  ...tseslint.configs.recommended,
);
