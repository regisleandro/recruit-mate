# RecruitMate Frontend

This is the frontend application for RecruitMate, built with Svelte and SvelteKit. It provides a modern, responsive user interface for HR recruiters to manage candidates, job postings, and the recruitment process.

## Technology Stack

- Svelte/SvelteKit
- TypeScript
- Tailwind CSS
- i18n internationalization
- JWT authentication

## Prerequisites

Before you begin, ensure you have the following installed:

- Node.js (v16 or newer)
- npm or pnpm (pnpm is recommended)
- Git

## Installation

1. Clone the repository (if you haven't already):

```bash
git clone https://github.com/your-username/recruit-mate-app.git
cd recruit-mate-app/frontend
```

2. Install dependencies:

```bash
# Using npm
npm install

# OR using pnpm
pnpm install
```

3. Set up environment variables:

Create a `.env` file in the root of the frontend directory and add:

```
PUBLIC_API_URL=http://localhost:3000
```

## Running the Application

### Development Mode

To start the development server with hot reloading:

```bash
# Using npm
npm run dev

# OR using pnpm
pnpm dev
```

The application will be available at http://localhost:5173

### Building for Production

To create a production build:

```bash
# Using npm
npm run build

# OR using pnpm
pnpm build
```

### Previewing the Production Build

To preview the production build locally:

```bash
# Using npm
npm run preview

# OR using pnpm
pnpm preview
```

## Application Structure

The frontend application follows the SvelteKit file-based routing structure:

- `src/routes/` - Application routes
- `src/lib/components/` - Reusable UI components
- `src/lib/stores/` - Svelte stores for state management
- `src/lib/utils/` - Utility functions
- `src/lib/i18n/` - Internationalization files
- `src/lib/services/` - API service functions

## Features

### Authentication

The application uses JWT for authentication. The authentication state is managed using Svelte stores.

### Internationalization

The application supports multiple languages. The translation files are located in `src/lib/i18n/`.

### Responsive Design

The UI is fully responsive and works well on desktop, tablet, and mobile devices.

## Development

### Adding New Routes

To add a new route, create a directory or file in the `src/routes/` directory. SvelteKit uses file-based routing.

### Adding New Components

When creating a new component:

1. Create a new file in `src/lib/components/`
2. Follow the existing component patterns
3. Use TypeScript for type safety
4. Include appropriate documentation

### Working with API

All API interactions should go through the service functions in `src/lib/services/`. This keeps API logic centralized and consistent.

## Deployment

The frontend is designed to be deployed to platforms like Vercel, Netlify, or similar static site hosting services.

### Vercel Deployment

```bash
vercel
```

### Netlify Deployment

```bash
netlify deploy
```

## License

This project is proprietary and confidential. All rights reserved.
