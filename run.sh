#!/bin/bash
set -eo pipefail

# Debug information
echo "Starting LibreTranslate..."
echo "PORT: ${PORT}"

# Start the LibreTranslate service using the Heroku-provided $PORT
./venv/bin/libretranslate --host 0.0.0.0 --port $PORT

# Check if LibreTranslate started successfully
if [ $? -ne 0 ]; then
  echo "Failed to start LibreTranslate"
  exit 1
fi

echo "LibreTranslate started successfully"