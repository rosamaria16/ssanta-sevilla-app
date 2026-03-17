#!/usr/bin/env bash
set -euo pipefail

FLUTTER_VERSION="3.24.5"
FLUTTER_TARBALL="flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${FLUTTER_TARBALL}"
INSTALL_DIR="/opt"
FLUTTER_DIR="${INSTALL_DIR}/flutter"

if [[ -x "${FLUTTER_DIR}/bin/flutter" ]]; then
  echo "Flutter already installed at ${FLUTTER_DIR}"
  exit 0
fi

sudo mkdir -p "${INSTALL_DIR}"
sudo curl -fsSL "${FLUTTER_URL}" -o "/tmp/${FLUTTER_TARBALL}"
sudo tar -xJf "/tmp/${FLUTTER_TARBALL}" -C "${INSTALL_DIR}"
sudo rm -f "/tmp/${FLUTTER_TARBALL}"

sudo chown -R vscode:vscode "${FLUTTER_DIR}"
"${FLUTTER_DIR}/bin/flutter" --version
