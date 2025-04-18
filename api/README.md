# RecruitMate API

This is the backend API for the RecruitMate application, built with Ruby on Rails in API-only mode. It provides all the necessary endpoints to support the frontend application and handles data processing, authentication, and business logic.

## Technology Stack

- Ruby 3.2.6
- Rails 7.1
- PostgreSQL
- JWT for authentication
- RSpec for testing
- AWS S3 for file storage

## Prerequisites

Before you begin, ensure you have the following installed:

- Ruby 3.2.6 (recommended to use [RVM](https://rvm.io/) or [rbenv](https://github.com/rbenv/rbenv))
- PostgreSQL
- Node.js and Yarn (for asset compilation)
- Git

## Installation

1. Clone the repository (if you haven't already):

```bash
git clone https://github.com/your-username/recruit-mate-app.git
cd recruit-mate-app/api
```

2. Install dependencies:

```bash
bundle install
```

3. Set up the database:

```bash
rails db:create
rails db:migrate
rails db:seed  # Optional: adds sample data
```

4. Set up environment variables:

Create a `.env` file in the root of the API directory and add the following (adjust values as needed):

```
DATABASE_URL=postgres://localhost/recruit_mate_development
JWT_SECRET_KEY=your_secret_key_here
AWS_ACCESS_KEY_ID=your_aws_access_key
AWS_SECRET_ACCESS_KEY=your_aws_secret_key
AWS_REGION=your_aws_region
AWS_BUCKET=your_aws_bucket
```

## Running the API

Start the Rails server:

```bash
rails server -p 3000
```

The API will be available at http://localhost:3000

## Running Tests

This project uses RSpec for testing. To run the test suite:

```bash
bundle exec rspec
```

You can also use the provided Makefile:

```bash
make test      # Run all tests
make lint      # Run Rubocop to check code quality
make lint-fix  # Auto-fix linting issues
```

## API Documentation

### Authentication

The API uses JWT for authentication. To access protected endpoints, include the JWT token in the Authorization header:

```
Authorization: Bearer your_token_here
```

### Main Endpoints

- `/signup` - Register a new user
- `/login` - Authenticate and get a JWT token
- `/companies` - CRUD operations for companies
- `/jobs` - CRUD operations for job listings
- `/candidates` - CRUD operations for candidates

For detailed API documentation, refer to the Swagger documentation available at `/api-docs` when the server is running.

## Development

### Code Style

This project follows the Ruby community style guide enforced by RuboCop. To check your code:

```bash
bundle exec rubocop
```

To automatically fix issues:

```bash
bundle exec rubocop -A
```

### Adding New Features

1. Create a new branch for your feature: `git checkout -b feature/your-feature-name`
2. Write tests for your feature
3. Implement your feature
4. Run tests to ensure everything passes: `bundle exec rspec`
5. Run linting: `bundle exec rubocop`
6. Submit a pull request

## Deployment

For production deployment, the API is designed to be hosted on platforms like Heroku, AWS Elastic Beanstalk, or similar services.

### Heroku Deployment

```bash
heroku create recruitmate-api
git push heroku main
heroku run rails db:migrate
```

## License

This project is proprietary and confidential. All rights reserved.
