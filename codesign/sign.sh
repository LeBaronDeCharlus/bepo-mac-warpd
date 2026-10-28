#!/bin/sh

export KEYCHAIN_NAME=warpd-temp-keychain
export KEYCHAIN_PASSWORD=

cd "$(dirname "$0")"

security create-keychain -p "${KEYCHAIN_PASSWORD}" "${KEYCHAIN_NAME}"

# Add keychain to search path (keeping the existing ones, restored below)
ORIG_KEYCHAINS=$(security list-keychains -d user | tr -d '"' | xargs)
security list-keychains -d user -s ${ORIG_KEYCHAINS} "${KEYCHAIN_NAME}"

security import warpd.p12 -k "${KEYCHAIN_NAME}" -P "" -T /usr/bin/codesign
security import warpd.cer -k "${KEYCHAIN_NAME}" -T /usr/bin/codesign
security unlock-keychain -p ${KEYCHAIN_PASSWORD} ${KEYCHAIN_NAME}

# Suppress codesign modal password prompt
security set-key-partition-list -S apple-tool:,apple: -s -k "$KEYCHAIN_PASSWORD" -D "${identity}" -t private ${KEYCHAIN_NAME} > /dev/null 2>&1

codesign --force --deep --keychain "${KEYCHAIN_NAME}" -s warpd ../bin/warpd

security delete-keychain ${KEYCHAIN_NAME}
security list-keychains -d user -s ${ORIG_KEYCHAINS}
