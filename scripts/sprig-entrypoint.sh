#!/bin/bash
set -euo pipefail

# corevia-talk-acp owns ephemeral Git setup for both native and MCP shells.
# The harness must receive Kubernetes' termination signal directly.
exec corevia-talk-acp "$@"
