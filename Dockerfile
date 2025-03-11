# Builder Stage: Clone the repo and build the binaries
FROM debian:bullseye-slim AS builder
# Install build tools and git
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    ca-certificates \
    libssl-dev \
    libcurl4-openssl-dev \
    libusb-1.0-0-dev \
    cmake \
    protobuf-compiler \
    libprotobuf-c-dev \
    pkg-config \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /src
# Clone the repository (adjust branch/tag if necessary)
RUN git clone https://github.com/ryanbinns/ttwatch.git .

# Build the binaries using the provided Makefile (per the README instructions)
RUN cmake .
RUN make
RUN make install

# Final Stage: Create a lean runtime image
FROM debian:bullseye-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libssl1.1 \
    libcurl4 \
    libusb-1.0-0 \
    libprotobuf-c1 \
 && rm -rf /var/lib/apt/lists/*

# Copy the built binaries from the builder stage.
# This assumes that the make process produces executables named "ttwatch" and "ttbincnv" in the repo root.
COPY --from=builder /usr/local/bin/ttwatch /usr/local/bin/ttwatch
COPY --from=builder /usr/local/bin/ttbincnv /usr/local/bin/ttbincnv

# Copy a simple entrypoint script that forwards any arguments
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Set the entrypoint so that any docker run arguments are passed through.
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
