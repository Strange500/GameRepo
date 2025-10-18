#!/bin/bash

# Example install script for games
# This script demonstrates how to create a custom installation script
# that can be called from games-config.json

# Parse command line arguments
GAME_ID=""
GAME_NAME=""
VERSION=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --game-id)
      GAME_ID="$2"
      shift 2
      ;;
    --game-name)
      GAME_NAME="$2"
      shift 2
      ;;
    --version)
      VERSION="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Validate required parameters
if [ -z "$GAME_ID" ]; then
  echo "Error: --game-id is required"
  exit 1
fi

# Display installation progress
echo "Starting installation of ${GAME_NAME:-$GAME_ID}..."
echo "Game ID: $GAME_ID"
[ -n "$VERSION" ] && echo "Version: $VERSION"

# Simulate installation steps
echo "Step 1/3: Downloading game files..."
sleep 1

echo "Step 2/3: Extracting files..."
sleep 1

echo "Step 3/3: Setting up game..."
sleep 1

# Success message
echo "${GAME_NAME:-$GAME_ID} installed successfully!"
exit 0
