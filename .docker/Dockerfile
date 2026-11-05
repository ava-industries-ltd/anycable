# .docker/Dockerfile

#####################################
# Stage 1: Builder                  #
#####################################
FROM golang:1.27.3-trixie AS builder

# Build with the toolchain supplied by the image.
ENV CGO_ENABLED=1 \
    GO111MODULE=on \
    GOTOOLCHAIN=local

RUN apt-get update && \
    apt-get install -y \
      bison \
      zip \
      git \
      ruby \
      ruby-dev \
      build-essential \
      ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
COPY . .

# Vendor Go modules using the local go-mruby fork.
RUN go mod vendor

# Build MRuby static library
RUN cd vendor/github.com/mitchellh/go-mruby && \
    MRUBY_CONFIG=../../../../../../etc/build_config.rb \
    make libmruby.a

# Keep the upstream version from version/version.go and append the commit SHA.
RUN go build -tags mrb \
    -ldflags "\
      -s -w \
      -X github.com/anycable/anycable-go/version.sha=$(git rev-parse --short HEAD)" \
    -o anycable-go-mrb \
    cmd/anycable-go/main.go

#####################################
# Stage 2: grpcurl                  #
#####################################
FROM golang:1.27.3-trixie AS grpcurl

ENV CGO_ENABLED=0 \
    GOTOOLCHAIN=local

RUN go install github.com/fullstorydev/grpcurl/cmd/grpcurl@v1.9.3

#####################################
# Stage 3: Slim Runtime             #
#####################################
FROM debian:trixie-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      dnsutils \
      iproute2 \
      iputils-ping \
      netcat-openbsd \
      openssl \
    && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /src/anycable-go-mrb /usr/local/bin/anycable-go
COPY --from=grpcurl /go/bin/grpcurl /usr/local/bin/grpcurl
COPY etc/rpc.proto /usr/local/share/anycable/rpc.proto

USER nobody

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/anycable-go"]
