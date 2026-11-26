# Screws and hardware

Counts come from the CAD pilot and clearance holes. Lengths are my estimate (plate or part thickness plus engagement), not tested. PETG self-tapping into printed pilot holes; buy a small assorted kit and a few spares.

| Where | Screw | Qty | Hole in CAD |
|---|---|---|---|
| Front plate to the 4 corner bosses of the base | M3 x 10, self-tapping | 4 | 3.4 clearance in plate, 2.4 pilot in boss |
| XLR jack and Neutrik USB-C jack to the base wall | M3 x 8 plus M3 nut (the jacks may bring their own hardware; **not checked**) | 2 per jack | 3.2 holes on all four corners of the 19 x 24 pattern (only the two on one diagonal are used), hex nut traps on the inside |
| Pedestal tabs into the front plate | M2 x 6, self-tapping | 3 | 2.4 clearance in tab, 1.7 pilot in plate (plate is only 2.5 mm: add a drop of glue, or use an M2 nut) |
| Motor onto the front plate | M1.6 x 8 (length **unverified**) | 3 | 2.0 clearance in plate; the motor's own threads are M1.6 x 0.35 |
| Sensor holder | M2 x 8 | 2 | 2.4 clearance |
| Wall mount (two keyholes side by side, 70 mm apart, 28 mm above centre) | pan-head screw, head under 7 mm, shank under 3.5 mm | 2 | keyhole 7 / 3.5 mm |

Not screws:
- The display carrier, hub and ring are glued (CA or epoxy).
- Three perfboard pieces (A: Nano 20 x 46 mm, B1: MAX485 17 x 47 mm, B2: TMC6300 23 x 18 mm; all from the 5 x 7 cm board, saw the marked corners off) rest on 1.2 mm rim frames printed into the base and are held with hot glue or a drop of epoxy. No screws. The Nano, MAX485 and TMC6300 are soldered into their pieces with pin headers.
- The USB-C cable has no clamp bar any more: the Neutrik jack's strain relief takes the pull at the wall. Give the cable's plug end a dab of hot glue on the Nano's port if it feels loose (not tested).

Wire: 10 thin wires from the display module go up the column. Use soft, thin wire (about 30 AWG or thinner). The Waveshare module ships with a 13-pin GH1.25 cable, but whether it fits the 4.0 mm bore with its connector is not tested.
