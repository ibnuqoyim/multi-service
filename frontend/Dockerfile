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

# Expose port
EXPOSE 4135

# Start the preview server
CMD ["npm", "run", "preview", "--", "--host", "0.0.0.0", "--port", "4135"]
