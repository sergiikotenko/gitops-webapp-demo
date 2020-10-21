# FROM golang:1.14 as build
# WORKDIR /build
# COPY . .
# RUN CGO_ENABLED=0 go build -o hello-gitops main.go

FROM scratch
EXPOSE 8080
# WORKDIR /app
COPY ./hello-gitops .
CMD ["./hello-gitops"]