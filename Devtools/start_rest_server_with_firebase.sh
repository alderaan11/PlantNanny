#!/bin/bash
# Start Python REST server with Firebase credentials
#
# Usage:
#   ./Devtools/start_rest_server_with_firebase.sh          # Start with empty data
#   ./Devtools/start_rest_server_with_firebase.sh --seed   # Start with fake development data
#   ./Devtools/start_rest_server_with_firebase.sh --help   # Show all options

cd "$(dirname "$0")/.."

# Default path to Firebase service account
DEFAULT_CRED_PATH="$(pwd)/firebase-service-account.json"

# Check if GOOGLE_APPLICATION_CREDENTIALS is already set
if [ -z "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
    echo "Firebase service account credentials path"
    echo "Default: $DEFAULT_CRED_PATH"
    read -p "Enter path (or press Enter for default): " CRED_PATH
    
    # Use default if empty
    if [ -z "$CRED_PATH" ]; then
        CRED_PATH="$DEFAULT_CRED_PATH"
    fi
    
    # Verify file exists
    if [ ! -f "$CRED_PATH" ]; then
        echo "Error: File not found: $CRED_PATH"
        exit 1
    fi
    
    export GOOGLE_APPLICATION_CREDENTIALS="$CRED_PATH"
    echo "Using credentials: $GOOGLE_APPLICATION_CREDENTIALS"
else
    echo "Using existing GOOGLE_APPLICATION_CREDENTIALS: $GOOGLE_APPLICATION_CREDENTIALS"
fi

source .venv/bin/activate

pushd server
python3 app.py "$@"
popd
