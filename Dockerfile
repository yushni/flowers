FROM golang:1.22 AS builder

WORKDIR /app

COPY ./ ./

RUN CGO_ENABLED=0 GOOS=linux go build -o flowers .

FROM scratch

WORKDIR /app

COPY ./.env ./
COPY ./public ./public
COPY --from=builder /app/flowers ./

EXPOSE 80
ENTRYPOINT ["./flowers"]



