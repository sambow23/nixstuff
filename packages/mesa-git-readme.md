update to the latest mesa git commit:

1. build with a fake hash to get the real one:

cd ~/nixstuff
Edit packages/mesa-git.nix and change hash to:
hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

run build, it will fail and show the correct hash:

nix build --impure --expr 'with import <nixpkgs> { overlays = [ (import ./packages/overlay.nix) ]; }; mesa-git' 2>&1 | grep "got:"

2. copy the correct hash (starts with `sha256-`) into `packages/mesa-git.nix`

3. update the version string to reflect the date or commit