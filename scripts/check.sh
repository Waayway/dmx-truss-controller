#!/usr/bin/env bash
# Clearance check: every turning part vs every fixed part must have an EMPTY intersection.
# Distinguishes a real "empty" from a compile error. Needs openscad on PATH (or: nix shell nixpkgs#openscad).
set -u
cd "$(dirname "$0")/../cad"
fail=0
for pair in hub-pedestal hub-column hub-carrier hub-plate ring-pedestal ring-column ring-carrier ring-plate; do
  out=$(openscad -D "pair=\"$pair\"" -o "${TMPDIR:-/tmp}/clearance-check.stl" clearance.scad 2>&1)
  if echo "$out" | grep -q "ERROR"; then echo "ERROR  $pair"; echo "$out" | grep ERROR; fail=1
  elif echo "$out" | grep -q "Current top level object is empty"; then echo "clear  $pair"
  else echo "HIT    $pair (parts intersect)"; fail=1; fi
done
exit $fail
