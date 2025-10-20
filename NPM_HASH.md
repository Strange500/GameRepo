# NPM Dependencies Hash

The Nix flake uses `buildNpmPackage` which requires a hash of the npm dependencies for reproducibility. This hash needs to be updated whenever `package-lock.json` changes.

## Why is this needed?

Nix builds are reproducible and run in a sandbox without network access. To install npm dependencies, Nix needs to know the exact hash of all dependencies beforehand. This ensures that builds are deterministic and secure.

## How to update the hash

### Automatic method (recommended):

```bash
./update-npm-hash.sh
```

This script will:
1. Attempt to build with the current hash
2. Extract the correct hash from the error message  
3. Update `flake.nix` automatically

### Manual method:

1. Run `nix build` (or `nix build .#game-catalogue`)
2. The build will fail with an error message like:
   ```
   error: hash mismatch in fixed-output derivation '/nix/store/...':
     specified: sha256-AAAA...
     got:        sha256-REAL_HASH_HERE
   ```
3. Copy the hash after `got:` (e.g., `sha256-REAL_HASH_HERE`)
4. Open `flake.nix` and find the line:
   ```nix
   npmDepsHash = pkgs.lib.fakeHash;
   ```
5. Replace it with:
   ```nix
   npmDepsHash = "sha256-REAL_HASH_HERE";
   ```
6. Run `nix build` again - it should succeed now!

## When do you need to update?

You need to update the hash whenever:
- You add, remove, or update npm dependencies in `package.json`
- `package-lock.json` changes
- You're setting up the project for the first time

## For contributors

If you modify `package.json` or `package-lock.json`, please run `./update-npm-hash.sh` and commit the updated `flake.nix` along with your changes.
