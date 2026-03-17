#!/usr/bin/env bash
set -euo pipefail

ANDROID_SDK_ROOT="/opt/android-sdk"
CMDLINE_TOOLS_DIR="${ANDROID_SDK_ROOT}/cmdline-tools"
CMDLINE_TOOLS_VERSION="11076708"
CMDLINE_TOOLS_ZIP="commandlinetools-linux-${CMDLINE_TOOLS_VERSION}_latest.zip"
CMDLINE_TOOLS_URL="https://dl.google.com/android/repository/${CMDLINE_TOOLS_ZIP}"

if [[ -x "${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager" ]]; then
  echo "Android SDK already installed at ${ANDROID_SDK_ROOT}"
  exit 0
fi

sudo apt-get update
sudo apt-get install -y curl unzip openjdk-17-jre-headless

sudo mkdir -p "${CMDLINE_TOOLS_DIR}"
sudo curl -fsSL "${CMDLINE_TOOLS_URL}" -o "/tmp/${CMDLINE_TOOLS_ZIP}"
sudo unzip -q "/tmp/${CMDLINE_TOOLS_ZIP}" -d "/tmp"
sudo rm -f "/tmp/${CMDLINE_TOOLS_ZIP}"

# The zip contains a top-level cmdline-tools directory. Move it under latest.
sudo mkdir -p "${CMDLINE_TOOLS_DIR}/latest"
sudo rm -rf "${CMDLINE_TOOLS_DIR}/latest"
sudo mv "/tmp/cmdline-tools" "${CMDLINE_TOOLS_DIR}/latest"

sudo chown -R vscode:vscode "${ANDROID_SDK_ROOT}"

SDKMANAGER="${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager"

# Install minimal packages for Flutter Android builds.
"${SDKMANAGER}" --sdk_root="${ANDROID_SDK_ROOT}" \
  "platform-tools" \
  "platforms;android-34" \
  "build-tools;34.0.0"

# Accept licenses non-interactively. sdkmanager can exit early and break the pipe.
yes | "${SDKMANAGER}" --licenses --sdk_root="${ANDROID_SDK_ROOT}" || true
