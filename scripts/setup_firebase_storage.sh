#!/usr/bin/env bash
# Provisions Firebase Storage for transformers-builders and deploys storage.rules.
#
# Prerequisites:
#   1. firebase login (already done on this machine)
#   2. Project on Blaze plan (Storage requires billing — Spark is not enough)
#
# Usage:
#   ./scripts/setup_firebase_storage.sh

set -euo pipefail

PROJECT_ID="${FIREBASE_PROJECT:-transformers-builders}"
LOCATION="${STORAGE_LOCATION:-us-central1}"
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "==> Checking Firebase CLI login..."
firebase projects:list --project "$PROJECT_ID" >/dev/null

echo "==> Checking billing (Storage requires Blaze)..."
python3 << PY
import json, sys, urllib.request, urllib.error
from pathlib import Path

cfg = json.loads(Path.home().joinpath('.config/configstore/firebase-tools.json').read_text())
access = cfg['tokens']['access_token']
project = "$PROJECT_ID"

req = urllib.request.Request(
    f'https://cloudbilling.googleapis.com/v1/projects/{project}/billingInfo',
    headers={'Authorization': f'Bearer {access}'},
)
with urllib.request.urlopen(req) as resp:
    info = json.load(resp)

if not info.get('billingEnabled'):
    print('')
    print('ERROR: Billing is not enabled on this project (Spark plan).')
    print('Upgrade to Blaze first (free tier still applies for modest usage):')
    print(f'  https://console.firebase.google.com/project/{project}/usage/details')
    print('')
    print('After upgrading, run this script again.')
    sys.exit(1)

print('Billing enabled — OK')
PY

echo "==> Enabling Storage APIs..."
python3 << PY
import json, urllib.request
from pathlib import Path

cfg = json.loads(Path.home().joinpath('.config/configstore/firebase-tools.json').read_text())
access = cfg['tokens']['access_token']
project = "$PROJECT_ID"

for service in (
    'firebasestorage.googleapis.com',
    'storage.googleapis.com',
):
    url = f'https://serviceusage.googleapis.com/v1/projects/{project}/services/{service}:enable'
    req = urllib.request.Request(url, data=b'{}', method='POST', headers={
        'Authorization': f'Bearer {access}',
        'Content-Type': 'application/json',
    })
    with urllib.request.urlopen(req) as resp:
        resp.read()
    print(f'  enabled {service}')
PY

echo "==> Creating default Storage bucket (location: $LOCATION)..."
python3 << PY
import json, sys, urllib.request, urllib.error
from pathlib import Path

cfg = json.loads(Path.home().joinpath('.config/configstore/firebase-tools.json').read_text())
access = cfg['tokens']['access_token']
project = "$PROJECT_ID"
location = "$LOCATION"

url = f'https://firebasestorage.googleapis.com/v1alpha/projects/{project}/defaultBucket'
body = json.dumps({'location': location}).encode()
req = urllib.request.Request(url, data=body, method='POST', headers={
    'Authorization': f'Bearer {access}',
    'Content-Type': 'application/json',
})

try:
    with urllib.request.urlopen(req) as resp:
        result = json.load(resp)
        name = result.get('name') or result.get('bucket', {}).get('name', 'created')
        print(f'  default bucket ready: {name}')
except urllib.error.HTTPError as e:
    payload = e.read().decode()
    if e.code == 409 or 'already exists' in payload.lower():
        print('  default bucket already exists — continuing')
    else:
        print(f'ERROR HTTP {e.code}: {payload}', file=sys.stderr)
        sys.exit(1)
PY

echo "==> Deploying storage.rules..."
cd "$ROOT_DIR"
firebase deploy --only storage --project "$PROJECT_ID"

echo ""
echo "Done. Firebase Storage is ready for announcement attachments."
