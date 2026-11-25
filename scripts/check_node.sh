#!/usr/bin/env bash
set -euo pipefail

# The locked legacy frontend dependencies use the Node 16 build environment.
if ! node_version=$(node --version 2>/dev/null); then
    node_version=unavailable
fi
if [[ "$node_version" != v16.* ]]; then
    echo "Frontend installation requires Node.js 16.x; found $node_version." >&2
    echo "Run make shell first to use the Docker build environment, or activate Node.js 16 for a host build." >&2
    exit 1
fi
