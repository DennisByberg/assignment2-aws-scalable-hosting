# Technology Stack for Serverless Solution

This page lists the main technologies and services used in the architecture of this project.

## Backend (Serverless)

- **AWS Lambda** – Serverless compute for backend logic
- **Amazon API Gateway** – Handles REST APIs with CORS support
- **Amazon DynamoDB** – NoSQL database for data storage with streams
- **Amazon S3** – Storage for static files and frontend assets
- **Amazon SES** – Simple Email Service for contact form notifications
- **Amazon CloudFront** – CDN for global content delivery
- **AWS IAM** – Permissions and security management

## Infrastructure

- **Terraform** – Infrastructure as Code for provisioning AWS resources
- **Bash scripting** – Deployment automation and utility scripts

## Frontend

- **React** – Modern JavaScript framework for frontend
- **TypeScript** – Typed JavaScript for better development experience
- **Mantine (MantineUI)** – React component library with modern design
- **Vite** – Fast build tool and development server for React
- **TanStack Query (React Query)** – Data fetching and caching library
- **React Router** – Client-side routing for single-page application
- **HTML/CSS** – Standard web development
- **Node.js** – JavaScript runtime for building the frontend

## Development Tools

- **ESLint** – Code linting and quality checks
- **AWS CLI** – Command-line interface for AWS services
- **Python 3.9** – Runtime for Lambda functions

## Architecture Patterns

- **Serverless Architecture** – Event-driven, pay-per-use compute model
- **Infrastructure as Code (IaC)** – Automated, version-controlled infrastructure
- **Single Page Application (SPA)** – Client-side rendered web application
- **RESTful APIs** – HTTP-based service architecture
- **Event-Driven Architecture** – DynamoDB Streams trigger email notifications

## Other

- **Git** – Version control
- **GitHub** – Code hosting and collaboration
- **WSL Ubuntu 24.04** – Development environment
