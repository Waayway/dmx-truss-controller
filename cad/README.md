# CAD notes

All parts are OpenSCAD, driven by [`params.scad`](params.scad). Every number there is labelled **VERIFIED** (datasheet or drawing), **USER** (measured by the user), **PHOTO** (scaled from the user's photo, about +-3 mm) or **PROPOSAL / ESTIMATE** (my design choice, not measured). All heights come from one z-stack in `params.scad`; change it there.

Coordinates: z = 0 is the wall side (back of the base), +z points to the viewer. Looking into the open base, +x is right and +y is up. Prints are PETG; **none of this has been printed yet.**

| File | Part | Print orientation | Notes |
|---|---|---|---|
| `base.scad` | Octagon base, **115 mm across flats, 32 deep** | back plate on the bed | Two identical Neutrik D-size cutouts: **USB-C jack on the bottom facet, XLR on the right facet**. Four screw holes each (both diagonals, so either flange orientation fits) with M3 nut traps, four posts for perfboard strip A, four corner bosses, two keyholes |
| `front_plate.scad` | Closes the base, carries the motor and pedestal | flat | 4 x M3 into the corner bosses, 3 x M1.6 for the motor, 3 x M2 pilot holes for the pedestal, motor-lead slot at 30 degrees |
| `pedestal.scad` | Fixed 58 mm drum that hides the motor | open side up | 3 foot tabs, M2 screws from above |
| `column.scad` | Fixed tube through the motor bore | upright | OD 5.6 / ID 4.0 for the display wires, 0.8 mm wall. Fragile: print it slow and expect to reprint |
| `display_carrier.scad` | Holds the Waveshare module | pocket up | Fixed, never turns. Socket for the column |
| `rotor_hub.scad` | The turning link: motor to ring | flat | Glued to the motor; three walls that sit in ring pockets |
| `ring.scad` | The ring you turn, 58 / 43 mm, 60 ribs | flat | 3 pockets for the hub walls, marker dot |
| `sensor_holder.scad` | Carrier for the 22 x 22 mm MT6701 board (4 x M2) | flat | **Placeholder, do not print**: where the magnet goes is not solved (see `docs/open-questions.md`) |
| `lib.scad` | Helpers: perfboard outlines with sawn corners and their rim frames | n/a | Used by `base.scad` and `ghosts.scad` |
| `ghosts.scad` | Render-only stand-ins: USB-C jack + fly-lead, Nano, XLR, MAX485, TMC6300, three perfboard pieces | not printed | Used by the clearance check and `layout-ghosts.stl` |
| `assembly.scad` | All parts in place | n/a | Echoes the z-stack and asserts basic fit. `show_ghosts = true` adds the stand-ins |
| `clearance.scad` | Overlap test between two named parts | n/a | Run through `make check` |
| `preview/view.html` | Quick STL viewer (three.js) | n/a | `node ../scripts/serve.cjs`, then open `/preview/view.html?f=base,layout-ghosts&v=top` |

## Why the base is 115 mm

The Neutrik USB-C jack has a 54 mm rigid body and a 17 cm fly-lead (about 75 mm flexible, about 37 mm stiff plug end). The only way to lay it in is a U-turn with the Nano alongside the jack body, plug pointing back at the wall. A solver (see `docs/open-questions.md`) found no layout in a 105 mm octagon because the chamfered corners clip the Nano's far end; 110 mm is the minimum (about 4 mm from the cable and Nano to the inner wall) and 115 mm leaves about 8 mm. Set `base_flat` in `params.scad` to try 110. The jack sits 4 mm right of centre, the Nano at x = -20 with its antenna end 12 mm off the wall, on perfboard piece A (20 x 46 mm, cut from the 5 x 7 cm board), so its USB-C axis lines up with the jack axis at z = 16. Cable slack at this size is only about 1 mm (see below).

## What is checked (`make check`)

- Each printed part exports as one solid (`Volumes: 2` in OpenSCAD = one body).
- `assembly.scad` asserts the stack (ring clears the pedestal, display glass 1.5 mm below the ring top, column reaches the carrier). `params.scad` asserts the cable is long enough for the U-turn.
- No turning part (hub, ring) touches a fixed part (pedestal, column, carrier, plate).
- The base does not collide with the front plate, and the USB-C cable, plug, Nano, XLR and perfboard stand-ins do not share volume with the base, plate, column or pedestal. Face contact (the board resting on its posts, a flange sitting on the wall) is reported as "touch", not as a hit.
- The check was tested with a deliberate collision and does report a hit. It has already found two real faults: jack pads poking into the front-plate space, and (by eye, in a render) the plate bosses sitting in the middle of the diagonal walls instead of the corners.

## What is NOT checked

- Nothing is printed. Tolerances (0.2 mm running fits, 0.4 mm gaps) are guesses for a 0.4 mm nozzle.
- The cable stand-in is a centreline with a fixed radius; the real cable ripples when bent and its bend radius is an estimate (12 mm). The jack body, strain relief and plug sizes come from a photo.
- The motor drawing does not say which face is the stator mounting face or which part turns. The hub, plate and column assume the top turns and the bottom mounts. Check on the real motor first.
- The Nano's height above the perfboard (2.5 mm header spacer) is an estimate; the user's 15 mm measurement is ambiguous. Change `nano_hdr_h`.
- The TMC6300 and MAX485 are placed (13 mm tall modules, user), each on its own perfboard piece with a rim frame; their pin layouts are not known.
- **Cable slack is about 1 mm at 115 mm.** The USB-C fly-lead leaves almost no spare length in this base; see `docs/open-questions.md`. Check with the real jack on a 1:1 layout before printing.
- The MT6701 sensor and its 4 mm magnet are **not solved**: the display column and wires occupy the motor axis where the magnet must sit. `sensor_holder.scad` only records the board dimensions.
- The 10 display wires through the 4.0 mm column bore: free area is enough on paper (12.6 mm2 vs about 9 mm2), but it has not been tried with the real cable.
