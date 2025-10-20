FROM golang:1.22
WORKDIR /app
COPY . .
RUN go mod init go-service && go mod tidy

# Copy environment file if .env doesn't exist
RUN if [ ! -f .env ]; then cp .env.example .env; fi

# Use environment variable for port exposure
EXPOSE ${GO_SERVICE_PORT:-8081}
CMD ["go", "run", "main.go"]
