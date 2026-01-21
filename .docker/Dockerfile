# .docker/Dockerfile.local

#####################################
# Stage 1: Builder                  #
#####################################
FROM --platform=linux/arm64 golang:1.23-bullseye AS builder

# Enable CGO and modules
ENV CGO_ENABLED=1 \
    GO111MODULE=on

# Install system deps: bison for MRuby, zip (if you need it locally), git & Ruby for go-mruby
RUN apt-get update && \
    apt-get install -y \
      bison \
      zip \
      git \
      ruby2.7 \
      ruby2.7-dev \
      build-essential && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /src

# 1) Copy everything (including go.mod/go.sum)
COPY . .

# 2) Vendor all Go modules (this creates ./vendor/)
RUN go mod vendor

# 3) Build the MRuby static lib
RUN cd vendor/github.com/mitchellh/go-mruby && \
    MRUBY_CONFIG=../../../../../../etc/build_config.rb \
    make libmruby.a

# 4) Build the AnyCable‑Go executable with the 'mrb' tag
RUN go build -tags mrb \
    -ldflags "\
      -s -w \
      -X github.com/anycable/anycable-go/version.version=$(git describe --tags --always --dirty) \
      -X github.com/anycable/anycable-go/version.sha=$(git rev-parse --short HEAD)" \
    -o anycable-go-mrb \
    cmd/anycable-go/main.go

#####################################
# Stage 2: Slim Runtime             #
#####################################
FROM --platform=linux/arm64 debian:bullseye-slim

# Copy only the final binary in
COPY --from=builder /src/anycable-go-mrb /usr/local/bin/anycable-go

USER nobody

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/anycable-go"]
