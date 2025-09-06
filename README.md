<div align="center">

# ComfyUI-Docker
**An automated Repo for ComfyUI Docker image builds, optimized for NVIDIA GPUs.**

[![][github-stargazers-shield]][github-stargazers-link]
[![][github-release-shield]][github-release-link]
[![][github-license-shield]][github-license-link]

[github-stargazers-shield]: https://img.shields.io/github/stars/clsferguson/ComfyUI-Docker.svg
[github-stargazers-link]: https://github.com/clsferguson/ComfyUI-Docker/stargazers
[github-release-shield]: https://img.shields.io/github/v/release/clsferguson/ComfyUI-Docker?style=flat&sort=semver
[github-release-link]: https://github.com/clsferguson/ComfyUI-Docker/releases
[github-license-shield]: https://img.shields.io/github/license/clsferguson/ComfyUI-Docker.svg
[github-license-link]: https://github.com/clsferguson/ComfyUI-Docker/blob/master/LICENSE

[About](#about) • [Features](#features) • [Getting Started](#getting-started) • [Usage](#usage) • [License](#license)

</div>

---

## About

This repository automates the creation of Docker images for [ComfyUI](https://github.com/comfyanonymous/ComfyUI), a powerful and modular stable diffusion GUI and backend. It syncs with the upstream ComfyUI repository, builds a Docker image on new releases, and pushes it to GitHub Container Registry (GHCR).

I created this repo for myself as a simple way to stay up to date with the latest ComfyUI versions while having an easy-to-use Docker image. It's particularly suited for setups with **NVIDIA GPUs**, leveraging CUDA for accelerated performance.

Why Docker? It provides a consistent, isolated environment that's easy to deploy, update, and scale, perfect for AI workflows without messing with your host system.

### Built With
- [Docker](https://www.docker.com/)
- [GitHub Actions](https://github.com/features/actions) for automation
- [PyTorch](https://pytorch.org/) with CUDA support
- Based on Python 3.13 slim image

---

## Features
- **Automated Sync & Build**: Daily checks for upstream releases, auto-merges changes, and builds/pushes Docker images.
- **NVIDIA GPU Ready**: Pre-configured with CUDA-enabled PyTorch for seamless GPU acceleration.
- **Non-Root Runtime**: Runs as a non-root user for better security.
- **Pre-Installed Manager**: Includes ComfyUI-Manager for easy node/extensions management.
- **Lightweight**: Uses a slim Python base image to keep the size down.
- **Customizable**: Pass environment varibles with `COMFYUI_` in docker-compose.

---

## Getting Started

### Prerequisites
- **Docker**: Installed on your host (e.g., Docker Desktop or Engine).
- **NVIDIA GPU**: For GPU support (ensure NVIDIA drivers and CUDA are installed on the host).
- **NVIDIA Container Toolkit**: For GPU passthrough in Docker (install via [official guide](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)).

### Pulling the Image
The latest image is available on GHCR:

```bash
docker pull ghcr.io/clsferguson/comfyui-docker:latest
```

For a specific version (synced with upstream tags, starting at 0.3.57):
```bash
docker pull ghcr.io/clsferguson/comfyui-docker:vX.Y.Z
```

### Docker Compose
For easier management, use this `docker-compose.yml`:

```yaml
services:
  comfyui:
    image: ghcr.io/clsferguson/comfyui-docker:latest
    container_name: ComfyUI
    runtime: nvidia
    restart: unless-stopped
    ports:
      - 8188:8188
    environment:
      - TZ=America/Edmonton
      #- COMFYUI_SOME_ENV_VAR=SOME_VALUE
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
    volumes:
      - comfyui_data:/app/ComfyUI/user/default
      - comfyui_nodes:/app/ComfyUI/custom_nodes
      - /mnt/comfyui/models:/app/ComfyUI/models
      - /mnt/comfyui/input:/app/ComfyUI/input
      - /mnt/comfyui/output:/app/ComfyUI/output
```

Run with `docker compose up -d`.

---

## Usage

### Basic Usage
Access ComfyUI at `http://localhost:8188` after starting the container using Docker Compose.

### Environment Variables
- Set via `.env` file or `-e` flags in `docker compose` or `docker run`.
- Examples: `COMFYUI_EXTRA_ARGS="--highvram"` to pass extra args.

---

## License
Distributed under the MIT License (same as upstream ComfyUI). See [LICENSE](LICENSE) for more information.

---

## Contact
- **Creator**: clsferguson - [GitHub](https://github.com/clsferguson)
- **Project Link**: [https://github.com/clsferguson/ComfyUI-Docker](https://github.com/clsferguson/ComfyUI-Docker)

<p align="center">
  <i>Built with ❤️ for easy AI workflows.</i>
</p>
