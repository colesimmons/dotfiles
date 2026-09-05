#!/bin/bash
set -Eeuo pipefail
source "$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../lib" && pwd)/common.sh"
ui heading '30 / Get your projects speaking their languages'
require_macos

# TODO: Configure selected runtime managers using their explicit executable paths.
# Do not depend on another 30-* script having changed the shell or PATH.
# TODO: Decide any global defaults; let project configuration select project versions.
ui pending 'Your runtime setup is still an open choice.'
ui detail 'Choose which tools manage your languages; let projects select their own versions.'
ui next 'Add the selected configuration here. No runtimes have been changed.'
