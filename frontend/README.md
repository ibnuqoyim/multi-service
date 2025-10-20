# Frontend Application

A React-based frontend application with Tailwind CSS styling for user registration.

## Features

- Modern React with hooks
- Tailwind CSS styling
- Form validation and error handling
- Loading states and user feedback
- Environment-based API configuration
- Responsive design

## Environment Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `VITE_API_URL` | URL to PHP API service | `http://localhost:8080` | No |

## Quick Start

### Using Docker Compose (Recommended)

```bash

# Start the application
docker-compose up --build

# Application will be available at http://localhost:4135
```


## Technologies Used

- **React 18** - Frontend framework
- **Vite** - Build tool and development server
- **Tailwind CSS** - Utility-first CSS framework
- **PostCSS** - CSS processing
- **Autoprefixer** - CSS vendor prefixing

## Features

### User Registration Form
- Name and email input fields
- Client-side validation
- Real-time error clearing
- Loading states during submission
- Success and error message display
