#!/bin/bash
set -Eeuo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../lib" && pwd)/common.sh"
ui heading '30 / Git, your way'
require_macos

# TODO: Choose identity, useful Git defaults, and an authentication/signing approach.
# Keep private identities, credentials, keys, and machine overrides outside Git.
# Public HTTPS cloning does not require configuring an SSH key or signing into GitHub.
ui pending 'Your Git preferences are waiting to be chosen.'
ui detail 'Decide your identity, everyday defaults, and authentication or signing approach.'
ui next 'Fill in this script when those choices are made. Your Git settings are untouched.'
