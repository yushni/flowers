FROM golang:1.22 AS builder

WORKDIR /app

COPY ./ ./

RUN CGO_ENABLED=0 GOOS=linux go build -o flowers .

FROM scratch

WORKDIR /app

COPY ./public ./public
COPY --from=builder /app/flowers ./
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

EXPOSE 80
ENTRYPOINT ["./flowers"]



