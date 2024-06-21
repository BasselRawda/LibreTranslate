#!/bin/bash
set -eo pipefail

# Default port to 5000 if not set by Heroku
PORT=${PORT:-5000}

# Start the LibreTranslate service
./venv/bin/libretranslate --host 0.0.0.0 --port $PORT
