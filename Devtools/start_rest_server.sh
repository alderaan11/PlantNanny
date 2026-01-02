#!/bin/bash
# Start Python REST server
#
# Usage:
#   ./Devtools/start_rest_server.sh          d# Start with empty data
#   ./Devtools/start_rest_server.sh --seed   # Start with fake development data
#   ./Devtools/start_rest_server.sh --help   # Show all options

cd "$(dirname "$0")/.."
source .venv/bin/activate

pushd server
python3 app.py "$@"
popd