FROM node:18

WORKDIR /app

# Copy package files first for better caching
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy source code
COPY . .

# Copy environment file if .env doesn't exist
RUN if [ ! -f .env ]; then cp .env.example .env; fi

# Build the application
RUN npm run build

# Use environment variable for port exposure
EXPOSE ${FRONTEND_PORT:-4135}

# Start the preview server with environment variable port
CMD ["sh", "-c", "npm run preview -- --host 0.0.0.0 --port ${FRONTEND_PORT:-4135}"]
