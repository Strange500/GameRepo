#!/usr/bin/env bash
# Helper script to update the npm dependencies hash in flake.nix
#
# This script computes the correct npm dependencies hash and updates flake.nix

set -e

echo "Computing npm dependencies hash..."

# Try to build and capture the output
if build_output=$(nix-build compute-npm-hash.nix 2>&1); then
    echo "✓ Build succeeded (unexpected)"
    exit 1
fi

# Extract the hash from the error message
if echo "$build_output" | grep -q "got:.*sha256-"; then
    correct_hash=$(echo "$build_output" | grep -oP 'got:\s+\K\S+' | tail -1)
    echo "Found correct hash: $correct_hash"
    
    # Update flake.nix
    sed -i "s|npmDepsHash = .*;|npmDepsHash = \"$correct_hash\";|" flake.nix
    
    echo "✓ Updated flake.nix with correct hash"
    echo ""
    echo "You can now build with: nix build"
else
    echo "❌ Could not extract hash from build output"
    echo ""
    echo "Build output:"
    echo "$build_output"
    exit 1
fi
