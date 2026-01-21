# .docker/Dockerfile

#####################################
# Stage 1: Builder                  #
#####################################
FROM golang:1.23-bullseye AS builder

# Allow Go to auto-upgrade toolchain to 1.25+
ENV CGO_ENABLED=1 \
    GO111MODULE=on \
    GOTOOLCHAIN=auto

RUN apt-get update && \
    apt-get install -y \
      bison \
      zip \
      git \
      ruby2.7 \
      ruby2.7-dev \
      build-essential \
      ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
COPY . .

# Vendor Go modules (requires Go 1.25+, auto-downloaded)
RUN go mod vendor

# Build MRuby static library
RUN cd vendor/github.com/mitchellh/go-mruby && \
    MRUBY_CONFIG=../../../../../../etc/build_config.rb \
    make libmruby.a

# 4) Build the AnyCable‑Go executable with the 'mrb' tag
RUN go build -tags mrb \
    -ldflags "\
      -s -w \
      -X github.com/anycable/anycable/version.version=$(git describe --tags --always --dirty) \
      -X github.com/anycable/anycable/version.sha=$(git rev-parse --short HEAD)" \
    -o anycable-go-mrb \
    cmd/anycable-go/main.go

#####################################
# Stage 2: Slim Runtime             #
#####################################
FROM debian:bullseye-slim

COPY --from=builder /src/anycable-go-mrb /usr/local/bin/anycable-go

USER nobody

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/anycable-go"]
