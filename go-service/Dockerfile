FROM golang:1.22
WORKDIR /app
COPY . .
RUN go mod init go-service && go mod tidy

# Copy environment file if .env doesn't exist
RUN if [ ! -f .env ]; then cp .env.example .env; fi

EXPOSE 8081
CMD ["go", "run", "main.go"]
