FROM ubuntu:22.04 AS builder

# Install Ollama
RUN apt-get update && apt-get install -y curl ca-certificates
RUN curl -fsSL https://ollama.com/install.sh | sh

# Create a minimal runtime image
FROM ubuntu:22.04

ENV OLLAMA_HOST=0.0.0.0

# Copy Ollama binary from builder
COPY --from=builder /usr/local/bin/ollama /usr/local/bin/ollama

# Create directory for storing models
RUN mkdir -p /root/.ollama

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 11434

# Create setup script
RUN echo '#!/bin/bash\n\
ollama pull deepseek-r1:7b\n\
echo "Starting Ollama server..."\n\
ollama serve\n\
' > /start.sh && chmod +x /start.sh

# Set entrypoint
ENTRYPOINT ["/start.sh"]