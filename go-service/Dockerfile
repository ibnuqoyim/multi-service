FROM golang:1.22
WORKDIR /app
COPY . .
RUN go mod init go-service && go mod tidy
EXPOSE ${PORT}
CMD ["go", "run", "main.go"]
