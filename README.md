# RecruitMate

RecruitMate is an AI-powered platform designed to help HR recruiters interact with candidates more efficiently. The application streamlines the recruitment process by providing intelligent tools for candidate management, job posting, and interview scheduling.

## Key Features

- AI-powered candidate matching with job requirements
- Automated communication with candidates
- Intelligent resume parsing and analysis
- Interview scheduling and management
- Customizable recruitment workflows
- Performance analytics and reporting

## Project Structure

This project consists of two main components:

1. **Frontend** - A modern Svelte application that provides a user-friendly interface for recruiters
2. **API** - A Ruby on Rails backend that handles data processing, AI operations, and business logic

## Docker Setup

This project uses Docker to simplify development setup. Make sure you have Docker and Docker Compose installed on your system.

### Running with Docker

1. Build all containers:
   ```
   make build
   ```

2. Start all containers:
   ```
   make up
   ```

3. The application will be available at:
   - Frontend: http://localhost:5173
   - API: http://localhost:3000

### Useful Commands

- View logs: `make logs`
- Stop all containers: `make down`
- Access API shell: `make shell-api`
- Access frontend shell: `make shell-frontend`
- Run migrations: `make db-migrate`
- Run API tests: `make tests`
- Run linting: `make lint`

## Manual Setup

For detailed setup and usage instructions without Docker, please refer to the specific README files for each component:

- [Frontend README](./frontend/README.md)
- [API README](./api/README.md)

## License

This project is proprietary and confidential. All rights reserved.

## Support

If you encounter any issues or have questions, please contact the development team at support@recruitmate.app 