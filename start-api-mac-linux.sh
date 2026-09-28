#!/usr/bin/env bash
# NCR Quick Stock Finder — local API starter (MOCK MODE, demo data)
set -e
cd "$(dirname "$0")"

echo "============================================================"
echo " NCR QUICK STOCK FINDER — Local API (MOCK MODE, demo data)"
echo "============================================================"

if ! command -v node >/dev/null 2>&1; then
  echo "[ERROR] Node.js nahi mila. Pehle install karein: https://nodejs.org"
  exit 1
fi

echo "[1/3] Dependencies install ho rahi hain..."
npm install --no-audit --no-fund

echo "[2/3] API build ho rahi hai..."
npm run build:api

echo "[3/3] API start: http://localhost:8787  (Ctrl+C = band)"
MOCK_MODE=true PORT=8787 ALLOW_CHROME_EXTENSIONS=true node apps/api/dist/server.js
