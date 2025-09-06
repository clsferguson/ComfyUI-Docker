#!/bin/bash
set -euo pipefail

APP_USER=appuser
BASE_DIR=/app/ComfyUI
CUSTOM_NODES_DIR="$BASE_DIR/custom_nodes"

# Ensure dirs exist
mkdir -p "$CUSTOM_NODES_DIR" "$BASE_DIR/output" "$BASE_DIR/models" "$BASE_DIR/user"

# If root: fix ownership on app paths (incl. bind mounts) and re-exec as appuser
if [ "$(id -u)" = "0" ]; then
  for d in "$BASE_DIR" "/home/$APP_USER" "$CUSTOM_NODES_DIR" "$BASE_DIR/output" "$BASE_DIR/models" "$BASE_DIR/user"; do
    [ -e "$d" ] && chown -R "$APP_USER:$APP_USER" "$d" || true
  done
  exec runuser -u "$APP_USER" -- "$0" "$@"
fi

# From here on, we run as appuser
# Ensure ComfyUI-Manager is present (if custom_nodes was mounted over the baked-in version)
if [ ! -d "$CUSTOM_NODES_DIR/ComfyUI-Manager" ]; then
  echo "[bootstrap] Installing ComfyUI-Manager into $CUSTOM_NODES_DIR/ComfyUI-Manager"
  git clone --depth 1 https://github.com/ltdrdata/ComfyUI-Manager.git "$CUSTOM_NODES_DIR/ComfyUI-Manager" || true
fi

# Add user-site bin to PATH and user-site packages to PYTHONPATH for --user installs
export PATH="$HOME/.local/bin:$PATH"
pyver="$(python -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')"
export PYTHONPATH="$HOME/.local/lib/python${pyver}/site-packages:${PYTHONPATH:-}"

# Optionally auto-install requirements for all custom nodes (installed into user site)
if [ "${COMFY_AUTO_INSTALL:-1}" = "1" ]; then
  echo "[deps] Scanning custom nodes for requirements..."
  # Install any requirements*.txt files (common pattern across node packs)
  while IFS= read -r -d '' req; do
    echo "[deps] pip install --user -r $req"
    pip install --no-cache-dir --user -r "$req" || true
  done < <(find "$CUSTOM_NODES_DIR" -maxdepth 3 -type f \( -iname 'requirements.txt' -o -iname 'requirements-*.txt' -o -path '*/requirements/*.txt' \) -print0)

  # Best-effort for pyproject.toml-based nodes (PEP 517/518)
  while IFS= read -r -d '' pjt; do
    d="$(dirname "$pjt")"
    echo "[deps] pip install --user . in $d"
    (cd "$d" && pip install --no-cache-dir --user .) || true
  done < <(find "$CUSTOM_NODES_DIR" -maxdepth 2 -type f -iname 'pyproject.toml' -print0)

  # Optional: surface dependency issues
  pip check || true
fi

# Export any COMFYUI_* env vars to the process
for var in $(compgen -e); do
  if [[ $var == COMFYUI_* ]]; then
    export "$var"
  fi
done

# Run ComfyUI
cd "$BASE_DIR"
exec "$@"
