#!/bin/bash

# Usage: ./deploy_sandbox.sh sandbox-bob.zip

ZIP_FILE="$1"

if [[ -z "$ZIP_FILE" ]]; then
  echo "Usage: $0 <sandbox-<devname>.zip>"
  exit 1
fi

# Extract dev name from ZIP filename (e.g., sandbox-bob.zip → bob)
DEV_NAME=$(basename "$ZIP_FILE" .zip | cut -d'-' -f2)

# Get the currently active GCP project
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)

if [[ -z "$PROJECT_ID" ]]; then
  echo "No active GCP project found. Set it using: gcloud config set project <PROJECT_ID>"
  exit 1
fi

TMP_DIR="./sandbox-deploy-tmp"
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"

echo "Unzipping $ZIP_FILE to $TMP_DIR..."
unzip -q "$ZIP_FILE" -d "$TMP_DIR"

echo "Submitting build for dev: $DEV_NAME to project: $PROJECT_ID"
gcloud builds submit "$TMP_DIR" \
  --substitutions=_DEV_NAME="$DEV_NAME",_PROJECT_ID="$PROJECT_ID" \
  --config="$TMP_DIR/cloudbuild.yaml"

echo "Deployment has been submitted. Cleaning up temp dir..."
rm -rf "$TMP_DIR"
