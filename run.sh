#!/bin/bash
set -eo pipefail

# Debug information
echo "Starting LibreTranslate..."
echo "PORT: ${PORT}"

# Default port to 5000 if not set by Heroku
PORT=${PORT:-5000}

# More debug information
echo "Using port: ${PORT}"
echo "Using host: ${HOST}"

# Start the LibreTranslate service and redirect output to a log file
./venv/bin/libretranslate --host 0.0.0.0 --port $PORT &> /app/libretranslate.log

# Check if LibreTranslate started successfully
if [ $? -ne 0 ]; then
  echo "Failed to start LibreTranslate"
  cat /app/libretranslate.log
  exit 1
fi

echo "LibreTranslate started successfully"
cat /app/libretranslate.log