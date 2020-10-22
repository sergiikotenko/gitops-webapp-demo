# FROM golang:1.14 as build
# WORKDIR /build
# COPY . .
# RUN CGO_ENABLED=0 go build -o hello-gitops main.go

FROM alpine:3.12.1
EXPOSE 8080
# WORKDIR /app
COPY ./hello-gitops .
CMD ["./hello-gitops"]