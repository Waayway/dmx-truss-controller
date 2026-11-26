# CAD notes

All parts are OpenSCAD, driven by [`params.scad`](params.scad). Every number there is labelled **VERIFIED** (read from a datasheet or drawing) or **PROPOSAL / ESTIMATE** (my design choice, not measured). All heights come from one z-stack at the bottom of `params.scad`; change it there.

Coordinates: z = 0 is the wall side (back of the base), +z points to the viewer. Prints below are in PETG; none of this has been printed yet.

| File | Part | Print orientation | Notes |
|---|---|---|---|
| `base_usbc.scad` | Octagon base, 90 mm across flats, 22 deep | back plate on the bed | USB-C slot (16 x 10) in the bottom facet, perfboard posts, Nano posts, clamp-bar posts, 4 corner bosses, 2 keyholes. First-test version: supply plugs straight into the Nano |
| `clamp_bar.scad` | Bridge that holds the USB-C plug | flat | 2 x M2. Takes the cable pull off the Nano |
| `front_plate.scad` | Closes the base, carries the motor and pedestal | flat | 4 x M3 into the base bosses, 3 x M1.6 for the motor, 3 x M2 pilot holes for the pedestal, motor-lead slot |
| `pedestal.scad` | Fixed 58 mm drum that hides the motor | open side up | 3 foot tabs, M2 screws from above |
| `column.scad` | Fixed tube through the motor bore | upright | OD 5.6 / ID 4.0 for the display wires, 0.8 mm wall. Fragile: print it slow and expect to reprint |
| `display_carrier.scad` | Holds the Waveshare module | pocket up | Fixed, never turns. Socket for the column |
| `rotor_hub.scad` | The turning link: motor to ring | flat | Glued to the motor; three walls that sit in ring pockets |
| `ring.scad` | The ring you turn, 58 / 43 mm, 60 ribs | flat | 3 pockets for the hub walls, marker dot |
| `sensor_holder.scad` | Holds the MT6701 board under the motor | flat | **Placeholder**: where the magnet is and the air gap are not known |
| `assembly.scad` | All parts in place | n/a | Echoes the z-stack and asserts basic fit |
| `clearance.scad` | Turning vs fixed overlap test | n/a | Run through `make check` |

Not modelled yet: the 45 degree desk wedge, and the final base with both D-size panel jacks (XLR + Neutrik USB-C). Those wait until the Neutrik jack arrives and its real size is measured.

## What is checked

- Each part exports as one solid (`Volumes: 2` in OpenSCAD = one body).
- `assembly.scad` asserts the stack (ring clears the pedestal, display glass 1.5 mm below the ring top, column reaches the carrier).
- `make check` proves no turning part touches a fixed part. The check was tested with a deliberate collision and does report a hit.

## What is NOT checked

- Nothing is printed. Tolerances (0.2 mm running fits, 0.4 mm gaps) are guesses for a 0.4 mm nozzle.
- The motor drawing does not say which face is the stator mounting face or which part turns. The hub, plate and column assume the top turns and the bottom mounts. Check on the real motor first.
- The Waveshare module thickness is 3.575 mm from the Waveshare 2D drawing; the carrier pocket depth is still an estimate.
- The 10 display wires through the 4.0 mm column bore: free area is enough on paper (12.6 mm2 vs about 9 mm2), but it has not been tried with the real cable.
