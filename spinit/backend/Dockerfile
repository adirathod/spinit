FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o spinit-backend main.go

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/spinit-backend .
COPY --from=builder /app/.env.example .env
EXPOSE 8080
CMD ["./spinit-backend"]
