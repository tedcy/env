#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

"$SCRIPT_DIR/cxx14/install.sh"
"$SCRIPT_DIR/cxx17/install.sh"
"$SCRIPT_DIR/cxx20/install.sh"
