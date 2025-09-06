# Use a recent slim base image
FROM python:3.13.7-slim-trixie

# Allow passing in host UID/GID for flexibility (can be overridden at build time)
ARG UID=1000
ARG GID=1000

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    COMFY_AUTO_INSTALL=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1

# Install system dependencies (as root)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    wget \
    curl \
    libgl1 \
    libglx-mesa0 \
    libglib2.0-0 \
    fonts-dejavu-core \
    fontconfig \
    util-linux \
 && rm -rf /var/lib/apt/lists/*

# Create non-root user/group and app directories (as root)
RUN groupadd --gid ${GID} appuser \
 && useradd --uid ${UID} --gid ${GID} --create-home --shell /bin/bash appuser \
 && mkdir -p /app/ComfyUI /app/ComfyUI/custom_nodes /app/ComfyUI/output /app/ComfyUI/models

# Set working directory
WORKDIR /app/ComfyUI

# Copy repo files into image (as root)
COPY . .

# Install Python core dependencies into global site-packages (no venv)
RUN python -m pip install --upgrade pip setuptools wheel \
 && python -m pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu129 \
 && python -m pip install -r requirements.txt \
 && python -m pip install imageio-ffmpeg

# Install ComfyUI-Manager under the canonical custom_nodes path (as root)
RUN mkdir -p custom_nodes \
 && git clone --depth 1 https://github.com/ltdrdata/ComfyUI-Manager.git custom_nodes/ComfyUI-Manager \
 && python -m pip install -r custom_nodes/ComfyUI-Manager/requirements.txt

# Copy entrypoint and fix permissions
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh \
 && chown -R appuser:appuser /app /home/appuser /entrypoint.sh

# Expose ComfyUI port
EXPOSE 8188

# Start as root so entrypoint can fix bind-mount ownership, then drop to appuser
USER root

# Entrypoint and default command (exec form)
ENTRYPOINT ["/entrypoint.sh"]
CMD ["python", "main.py", "--listen", "0.0.0.0"]
