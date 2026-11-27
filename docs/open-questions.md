# Open questions and unverified items

Nothing here is blocking the first test, but each item can change a number in the CAD. Sorted by how likely it is to bite.

## Mechanical (check on the real parts)

- **Motor orientation.** The OT-EM3215 drawing (datasheet p8) shows 3 x M1.6 on a 20.5 mm circle, 2 x 2.0 mm holes on a 21 mm circle, a 5.9 mm centre hole and an 11.5 mm boss, but does not say which face is the stator mount or which part turns. The hub, plate and column assume the top turns and the bottom mounts.
- **Motor leads.** A 3-pin 1.25 mm connector exits the side, 30 mm of wire. The plate slot for it is a guess.
- **Pole count.** The datasheet says 8 magnetic poles; SmartKnob firmware assumes 14. Detent tuning will differ.
- **Torque on 5 V.** The motor is rated 6 to 8 V. At about 0.55 A stall on 5 V the rim force at a 58 mm ring is roughly 0.75 N (rough estimate).
- **Cogging.** Nobody published a figure for this motor; the GM5208 and GM3506 were dropped after cogging reports.
- **Sensor.** Solved on paper, see "Sensor mount and motor orientation (2026-11-27)" below; the numbers behind it are not verified.
- **Wires through the bore.** 10 wires in a 4.0 mm column inside a 5.9 mm bore: fits on paper only.
- **Display module thickness** is now VERIFIED as 3.575 mm (Waveshare 2D drawing; the 3.4 mm estimate was too thin).
- **Nano height.** Stack-up assumes low (4 mm) sockets under the Nano; the USB-C slot is 16 x 10 and sits 7.7 to 17.7 mm above the back. If the sockets are taller the assert in `base_usbc.scad` trips.
- **USB-C plug size.** Slot is for the spec maximum plus margin; your supply's plug was not measured.
- **Antenna end** of the Nano points at the motor; Wi-Fi range untested.

## Electrical

- **Nano VBUS** has no stated rating; it feeds the TMC6300 (about 0.55 A stall) and the MAX485.
- **Touch chip.** The CST816S auto-sleep must be disabled in firmware; behaviour with RST/BL/INT open is unchecked.
- **I2C.** MT6701 (0x06) and CST816S (0x15) on one bus: assumed fine.
- **MAX485 module** may have a 120 ohm resistor already; not checked. The fixtures' own termination switches are unchecked. The terminator plug still goes in the last lamp.
- **D12 (GPIO47)** is assumed silent at boot while D1 (GPIO43) may print; untested.
- **MT6701 module pin names** (SSI) not seen.
- **Touch INT.** Plan v4.6 leaves it unwired; an earlier pin plan reserved A6.

## Shopping

- **Neutrik NAUSBC-5G-FL10** is a Conrad backorder (stock from a search snippet; Conrad blocks page reads). Only needed for the final housing; first test uses a USB-C cable straight into the Nano. FL15 gives more slack; price not read. The USB-C jack may work in one plug orientation only (not confirmed for this part).
- **BerryBase display** is "limited availability"; count unknown.
- **Re-check every price and stock level before ordering.** They were read on 2026-11-24 from product-page data, except the Conrad item.
- Shipping is not in any total (Kiwi: letterbox EUR 4.22, parcel EUR 7.20, free from EUR 150).

## Housing

- Final base with both D-size jacks (XLR on one facet, USB-C opposite) needs about 28 to 30 mm depth and a board of about 60 x 45 mm. Not modelled; waits for the Neutrik jack.
- 45 degree desk wedge not modelled yet.
- Plan v4.6 section 7 still shows the older slot-and-clamp drawing.

## Firmware

Not started. Plan: ESP32 Arduino core, SimpleFOC for detents, LVGL for the UI, `esp_dmx` for DMX out (24 slots), LittleFS for presets, web page for labels and patching.

## Header strip and Nano mounting (added after review)

- The 40-pin strip in the BOM is a male pin strip, not a socket. The CAD stack-up in `cad/base_usbc.scad` assumes the Nano sits about 2 mm above the perfboard on low sockets. If you solder the Nano's own pins straight into the board instead, it sits about 2.5 mm above the board; the slot assert still passes (plug axis about 13.2 mm, slot top about 18.2 mm, front plate at 19.5 mm), but re-run `make` after changing `sock_h`/`pin_in`.
- It is not confirmed whether the MT6701, MAX485 and TMC6300 modules ship with pins fitted.

## Arrived (2026-11-24)

- XLR jack and Neutrik USB-C jack are in. Both use the same D-size cutout (24 mm hole, 19 x 24 mm screw pattern), so the final base can take two identical holes.
- Still to measure: the USB-C fly-lead plug (fits the 16 x 10 mm slot in the first-test base?) and the flange of both jacks.

## Measurements received 2026-11-24 (see cad/params.scad)

- **Nano:** user measured about 15 mm tall with headers. Unclear if that includes the pins below the plastic spacer; asked.
- **XLR jack:** 24 mm plus about 5 mm of solder cups = about 29 mm behind the panel.
- **Neutrik USB-C jack:** the drawing gives a 29.4 mm rigid body (flange 26 x 31) and a 100 mm cable (L) between the strain reliefs. The user measures 50 mm from the flange front to where the plain cable starts (about 1-2 cm of that is strain relief). **That 50 mm is stiff and cannot bend**, so an XLR (29 mm) and this jack (50 mm) cannot face each other across the 85 mm inside of the base. They need facets about 90 degrees apart. Total jack length (flange to plug tip) still to be measured: the drawing suggests more than the "10 cm total" the user quoted.
- **Motor:** 3-wire lead leaves between two of the three screw holes (plate slot at `motor_lead_angle`, now 270 degrees).
- **TMC6300 (SparkFun drawing):** 20.3 x 15.2 mm (0.80 x 0.60 in), no mounting holes, two 8-pin columns 12.7 mm apart at 2.54 mm pitch.
- **MAX485:** 44 x 14 x 19 mm, confirmed.
- **MT6701 magnet (user supplied):** 4 mm radius (maybe diameter) x 1.5 mm. **Open design problem:** a disc magnet must sit exactly over the sensor chip on the motor axis, but the column with the display wires occupies the axis (and the 5.9 mm bore). Where the magnet and sensor go is not designed yet.

## Neutrik USB-C jack cable: photo from the user (docs/images/neutrik-usbc-cable-photo.jpg)

Scaled against the Nano (43.18 mm long = 540 px). Estimates from a hand-held photo, not caliper measurements:
- Jack body from flange front to end of the lower strain relief: about 54 mm (user: about 50).
- Flexible cable: about 75 mm (user: about 7.5 cm).
- Plug end: about 37 mm from the Nano's edge to where the plain cable starts (overmold about 20 mm, strain relief about 11 mm, metal plug about 7 mm). This is shorter than the 45 mm assumed earlier.
- Total about 166 mm; the user measured 17 cm, so the scale holds up.
- The photo shows the cable laid as a U-turn with the Nano alongside the jack body, plug pointing back at the wall. That works physically. An earlier note here claimed no layout fits; that was wrong, the cable's 75 mm lets the U sit deeper than the jack body.
- The U-turn needs about 95 to 98 mm of depth from the outer wall face (bend radius 14 to 10 mm), so a base of about 101 to 103 mm across flats. The current base is 90 mm. Not modelled yet, rough calculation only.

## Final base (decision 2026-11-24): 115 mm octagon, Neutrik USB-C jack

- The user chose the Neutrik USB-C jack in a bigger base. `cad/base.scad` is 115 x 32 mm with two D-size cutouts: USB-C on the bottom facet (jack 8 mm right of centre), XLR on the right facet.
- Layout solver (`scripts/usbc-layout.mjs`): no layout fits at 105 mm; 110 mm is the minimum (about 4 mm from cable and Nano to the inner wall); 115 mm leaves about 8 mm. My first estimate of 101 to 103 mm ignored the octagon's chamfered corners and was wrong.
- The cable is laid as a U-turn (bend radius 12 mm) with the Nano alongside the jack body; Nano antenna end 12 mm off the wall. The Nano's Wi-Fi antenna therefore sits right behind a 2.5 mm PETG wall, which should be fine but is untested.
- Not placed yet: **TMC6300, MAX485**, the display-wire routing from the column to the Nano, and the **MT6701 sensor and magnet**.
- The jack stand-in sizes (body 23 mm, strain relief 14 mm, plug 13 x 7.4 mm, flange 3 mm thick) come from a photo and are estimates. Before printing, hold the real jack against a 24.3 mm hole drawn on paper and check the flange against the 31 x 26 mm footprint.
- Fixed in this round: the front-plate bosses were at the middle of the diagonal walls (half inside the wall) and are now in four corners; the jack pads no longer poke into the plate space.

## Modules placed, MT6701 measured (2026-11-24)

- **Heights (user):** every module stands 13 mm tall once its pins are soldered into the perfboard. The TMC6300 is soldered with headers straight into the perfboard (no socket). `cad/params.scad`: `mod_h = 13`.
- **MT6701 board (from the user's two photos, scaled by the 2.54 mm header pitch, cross-checked with the SOP8 body):** 21.8 x 22.0 mm, four holes about 2.1 mm on a 16.5 mm square, chip dead centre, header pins VDD / GND / Analog/PWM / SCL / SDA. Board thickness not measured. **Magnet: 4 mm across (user), 1.5 mm thick, came with the sensor; assumed diametrically magnetised, cannot be tested.** A 4 mm magnet does fit in the 5.9 mm bore, but the display column and wires already fill it. The sensor arrangement is still not solved; `sensor_holder.scad` is a placeholder.
- **Placement (scripts/place-modules.mjs, scripts/place-all.mjs):** the MAX485 stands upright beside the cable leg, the TMC6300 sits lower right, each on its own perfboard piece (A: Nano 20 x 46.2, B1: MAX485 17.1 x 46.9, B2: TMC6300 23.3 x 18.2; all cut from the 5 x 7 cm board, saw the marked corners off) on a rim frame. The keyholes moved to a horizontal pair at y = +28 because the old vertical pair sat in the MAX485's only possible spot.
- **WARNING, cable slack:** the Neutrik fly-lead is mostly stiff (54 mm body, 37 mm plug end) with only about 75 mm flexible. The layout solver gives the following spare cable after the U-turn: 115 mm base about 1 mm, 120 mm about 3 mm, 125 mm about 4 mm. My photo estimates are good to about +-3 mm, so at 115 mm the Nano might not reach its plug, or the cable may have to be bent tighter than 12 mm. Test with the real jack and cable on a 1:1 layout before printing the base. Options: bigger base (125 mm), shorter USB-C extension instead of the Neutrik, or accept a tighter bend.
- The MAX485's actual pin layout and the TMC6300's header orientation are not known; boards B1/B2 only fix where each module stands.

## First test prints (2026-11-24, user, Bambu Lab X2D, PETG)

- **Five short tubes, OD 5.3 / 5.4 / 5.5 / 5.6 / 5.7, ID 4.0, pushed into the real motor bore:** all fit easily; the last one (read as 5.7) does not spin smoothly. The column is now `col_od = 5.5` in `cad/params.scad` (one place; `column.scad` and `display_carrier.scad` used to hardcode 5.6). Still untested: the real wires through the 4.0 mm hole, and a tall 0.75 mm wall (the user expects a 75 mm tube to snap when flexed; the real column is about 35 mm and held at both ends).
- **MT6701 brace test:** the first pocket was exactly 22.0 mm for a 21.8 x 22.0 mm board and did not fit. Two variants with pocket 22.6 mm and 23.0 mm are in `cad/stl/test/`; the result is not in yet.
- **Magnet:** SmartKnob's repo (checked 2026-11-24) uses the SparkFun motor's built-in diametric magnet, so the separate 4 mm magnet is not needed. The MT6701 is fixed on the base PCB under the motor; the display wires run down the hollow shaft inside a fixed 3D-printed column. SmartKnob's mechanical CAD is in Fusion 360 (a360.co links in its cad/README.md) and could not be downloaded, so our brace under the motor is our own design. **Not yet verified:** that our motor really has the built-in magnet (the SparkFun listing says it does; the user has not confirmed it on the part) and the sensor air gap (SmartKnob's README gives none).

## Sensor mount and motor orientation (2026-11-27)

- **The motor was drawn upside-down.** The CAD had the Ø11.5 x 2.2 mm boss on TOP of the rotor, with the hub gluing onto it. SmartKnob's photos of the same motor (SparkFun 20441, `doc/img/motors/` in github.com/scottbez1/smartknob) show the ring magnet on the SAME face as the three M1.6 holes and the lead slot; the other face is flat. Now: that face is mounted DOWN on the plate, the magnet boss sticks down into the plate hole, and the hub sits on the flat rotor top. **User to confirm on the real motor.** The old `rotor_hub.stl` (boss pocket) and `column.stl` (3 mm foot with a cone) must not be printed.
- **MT6701 limits (datasheet Rev 1.5):** air gap magnet to chip surface 0.5 min / 1.0 typical / **2.0 max** mm; sensing centre within **0.3 mm** of the magnet axis; recommended magnet Ø6 x 2.5 mm disc, field 200 to 1000 gauss at the chip. **Not tested:** the motor's Ø11.5 ring magnet with a 5.9 mm bore against these numbers. SmartKnob uses the same motor with this sensor family, which is the only evidence.
- **Stack (z, mm, base wall = 0):** plate 29.5 to 32; boss bottom 29.8 (if `boss_proud` = 2.2); chip top 28.1 (gap 1.7); board 24.75 to 26.35; foot 26.35 to 29.5 (3.15 thick). The gap is derived from `boss_proud`, so a boss that sticks out less than 2.2 mm makes the gap bigger: at `boss_proud` = 1.5 the gap is 2.4 mm, over the limit. **Measure it and tell me.**
- **Wires:** the tube ends in a Ø4 hole through the foot's 0.8 mm roof into a 6.6 mm wide, 2.35 mm high groove that runs over the chip toward -y, the Nano side (it first ran toward -x, which left only 0.2 mm of wall to a motor-screw counterbore). The wires lie flat in it (about 0.5 mm of height, 30 AWG wire-wrap) and leave the foot edge. Not tested with real wires.
- **Alignment:** the foot is located on the motor by the three M1.6 screws (tight 1.8 mm holes; the plate holes are loose, 2.4), and the board on the foot by two M2 screws, so the chip should land within about 0.2 mm of the axis. Estimate, not measured.
- **Board orientation:** header pads on the +y edge, wires soldered on the back, no header. R1, R2 and C1 (0.6 to 0.8 mm) sit under a 0.9 mm relief. Two screws on the +y side; the -y holes are within 3 mm of the motor screws. A pad on the -y edge stops the board from tilting.
- **Lead:** the motor lead leaves between two screw holes, at 270 degrees (`motor_lead_angle`; the motor is turned 240 degrees from the first drawing so the lead leaves toward the TMC6300 and does not cross the MAX485): a 5 x 1.2 mm groove in the plate top, then a through slot at r 17 to 24 (outside the foot). The pedestal tabs and their plate holes moved from 30/150/270 to 90/210/330 degrees; the old tab at 30 degrees sat right in the lead slot (existing bug).
- **No root fillet** on the column any more: the boss is right above the foot. The tube root is the weak point; it is not tested.
- `sensor_holder.scad` and the brace test plate are obsolete. Screws now: M1.6 x 8 (3), M2 x 4 self-tapping (2).

## Base depth 40 mm (2026-11-27)

- User said the 32 mm base was too low. At 32 mm the MAX485 top (z 23.9) stopped 0.85 mm under the sensor board (z 24.75), with no room for wires. \`base_depth\` is now 40: the gap is about 4.9 mm. The jack axis moves up to z = 20 (it is half the depth) and the perfboard rim frames are 10.8 mm tall; everything on the turning side shifts up by 8 mm. All 24 clearance pairs pass at 40 mm. This is my proposal, not a measured need: it is one number in \`cad/params.scad\`.
- The sensor board wire groove now leaves toward -y (the Nano side) instead of -x, because the motor-screw counterbore at 210 degrees left only 0.2 mm of wall to it.
- Wiring picture: `docs/images/base-plan.png` (drawn from the CAD by `scripts/plan-svg.mjs`; re-run it after changing params.scad).
- Assembly order matters: motor + column foot + plate first (the motor screws are under the foot), the MT6701 board last (it covers the screw heads), soldered with wires on the back.
- Open: \`boss_proud\` (2.2 from the datasheet) must be measured on the real motor. The foot is \`boss_proud + 0.95\` thick; below about 2.1 mm the roof over the chip pocket gets thinner than 0.7 mm and the build stops with an assert.

## 90 degree USB-C cable, 180 mm base (2026-11-27)

- User asked for the cable to meet the Nano at 90 degrees instead of wrapping around (less stress on the cable) and said a bigger base is fine. `scripts/usbc-90.mjs` solves it: with a quarter bend the chain jack (54 stiff) + bend + plug (37 stiff) + Nano (43) is about 85 mm long along one direction, and the octagon's diagonal walls cut the corner, so the base has to be **at least 172 mm across flats** (with the flexible part designed at 72 mm, 3 mm under the measured 75). `base_flat` is now **180**, which leaves about 11 mm between the Nano piece and the wall. The corner-to-corner size is 195 mm, so it fits the 250 mm bed.
- New layout: jack at x = -22 on the bottom wall; cable goes straight up 46 mm, one bend (radius 12), 7 mm straight, then the stiff plug into the Nano, which lies along x to the right (row y = 22). **Spare cable is no longer critical**: extra length just bows the straight runs a little; the Nano position tolerates about 3 mm either way.
- The XLR moved from the right wall to the **top wall**, the MAX485 lies along x right below it (about 22 mm), the TMC6300 stands under the motor-lead slot (the lead is about 1 mm from it horizontally, so the lead length is now mostly the vertical drop, about 15 mm plus the strip lengths). Keyholes moved to y = 52.
- Printed parts that do not change (checked: identical geometry): ring, pedestal, hub, display carrier, column. **base and front_plate both changed**; do not mix old and new ones.
- The old U-turn solver (`scripts/usbc-layout.mjs`, `place-modules.mjs`, `place-all.mjs`) is obsolete.
- **Plate posts moved:** the clearance check (`ghost-base`: HIT) showed the old bottom-left post inside the USB-C jack body at the new jack position. The four posts now stand in the corners of the left and right walls (22.5, 157.5, 202.5, 337.5 degrees), clear of both jacks. Because the plate now spans about 170 mm with posts only on two sides, the base has a **3 mm ledge all round the inside** under the plate edge (`plate_ledge_w`, `plate_ledge_h`). Not tested: how much the plate flexes when you tap the screen; the pedestal bonded to the plate stiffens the middle.

## Base size versus cable turn angle (2026-11-27)

- User found 180 mm large and asked about 130 or 140 mm. \`scripts/usbc-turn.mjs\` (cable and Nano piece only, flex designed at 72, 3 mm clearance) gives the smallest base per cable turn: 90 degrees **170 mm**, 105: 164, 120: 162, **135: 148**, 150: 152, 165: 144. A full wrap-around (180) is not solved by that script; the older U-turn solver gave 110 to 115 mm with about 1 mm of spare cable. So **130 or 140 mm cannot hold a 90 degree bend** with this cable. Picture: \`docs/images/size-compare.png\` (\`scripts/size-compare-svg.mjs\`).
- Not tried: a square or rounded-rectangle base (the octagon's diagonal walls are what cut the L-shaped cable chain short), a shorter USB-C extension instead of the Neutrik fly-lead, or a right-angle plug on the Nano.

## Fit-test frames (2026-11-27)

- \`cad/fit-frame.scad\` prints a thin octagon ring at one base size with the jack hole, a ridge along the cable centreline, and outlines for the stiff jack end, the stiff plug end and the Nano's perfboard piece. Lay the real jack, cable and Nano on it. The asserts in the file stop the build if anything leaves the octagon or the cable is too short for the bend. Picture: \`docs/images/fit-frames.png\`.
- **fit-170-90** (170 mm, 90 degree bend, flexible part 72 mm): 170 mm is the exact minimum from \`scripts/usbc-turn.mjs\`, so the Nano end is about 1 mm from the wall. The real base is 180.
- **fit-140-145** (140 mm, 145 degree bend, flexible part **75 mm**, 2 mm clearances): only fits with the measured 75 mm flexible length (about 1.3 mm of room to the wall at the Nano end). With a 72 mm design length only turns of about 170 to 175 degrees fit at 140 mm, so a 140 mm base is a **near wrap-around**, not a gentle bend.
- The frame test answers one question: does the real plug reach the Nano outline with the cable bent no tighter than radius 12 on the ridge line?
