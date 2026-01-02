#!/bin/bash
# Start Python REST server

cd "$(dirname "$0")/.."
source .venv/bin/activate

cd server
python3 app.py