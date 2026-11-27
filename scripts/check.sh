#!/usr/bin/env bash
# Clearance check: each pair must have an EMPTY intersection.
#   hub/ring (turn)  vs pedestal/column/carrier/plate (fixed)
#   base vs plate    (the corner bosses must stop under the plate)
#   ghost vs base/plate/column/pedestal  (USB-C cable, Nano, XLR, perfboard and the sensor board must fit inside the base)
#   motor vs column/plate/hub/pedestal/carrier, and the sensor board vs the other boards, the Nano, the cable and the base
# Tells a real "empty" apart from a compile error, and mere face contact (Volumes: 1) from a real overlap (Volumes: 2+). Needs openscad on PATH (or: nix shell nixpkgs#openscad -c ...).
set -u
cd "$(dirname "$0")/../cad"
fail=0
pairs="hub-pedestal hub-column hub-carrier hub-plate ring-pedestal ring-column ring-carrier ring-plate base-plate ghost-base ghost-plate ghost-column ghost-pedestal motor-column motor-plate motor-hub motor-pedestal motor-carrier column-plate g_sensor-g_mods g_sensor-g_board g_sensor-g_nano g_sensor-g_cable g_sensor-base"
for pair in $pairs; do
  a=${pair%-*}; b=${pair#*-}
  out=$(openscad -D "a=\"$a\"" -D "b=\"$b\"" -o "${TMPDIR:-/tmp}/clearance-check.stl" clearance.scad 2>&1)
  if echo "$out" | grep -q "ERROR"; then echo "ERROR  $pair"; echo "$out" | grep ERROR; fail=1
  elif echo "$out" | grep -q "Current top level object is empty"; then echo "clear  $pair"
  else
    vols=$(echo "$out" | sed -n "s/.*Volumes: *\([0-9]*\).*/\1/p" | tail -1)
    if [ "${vols:-0}" -ge 2 ]; then echo "HIT    $pair (parts overlap, volumes=$vols)"; fail=1
    else echo "touch  $pair (faces touch, no shared volume)"; fi
  fi
done
exit $fail
