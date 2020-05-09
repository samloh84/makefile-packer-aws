#!/bin/bash

set -euxo pipefail

if [ ${EUID} != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

PACKER_VERSION=1.5.6
PACKER_TEMP_DIR="/tmp/packer-${PACKER_VERSION}"
PACKER_INSTALL_DIR="/opt/packer/${PACKER_VERSION}"
PACKER_ARCHIVE_URL="https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip"
PACKER_ARCHIVE_FILE="packer_${PACKER_VERSION}_linux_amd64.zip"
PACKER_ARCHIVE_PATH="${PACKER_TEMP_DIR}/${PACKER_ARCHIVE_FILE}"

mkdir -p "${PACKER_TEMP_DIR}" "${PACKER_INSTALL_DIR}"
curl -L -o "${PACKER_ARCHIVE_PATH}" "${PACKER_ARCHIVE_URL}"
unzip -o -d "${PACKER_TEMP_DIR}" "${PACKER_ARCHIVE_PATH}"
mv "${PACKER_TEMP_DIR}/packer" "${PACKER_INSTALL_DIR}/packer"
rm -rf "${PACKER_TEMP_DIR}"
update-alternatives --install "/usr/bin/packer" "packer" "${PACKER_INSTALL_DIR}/packer" 1
update-alternatives --set packer "${PACKER_INSTALL_DIR}/packer"
