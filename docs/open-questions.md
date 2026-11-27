# Open questions and unverified items

Nothing here is blocking the first test, but each item can change a number in the CAD. Sorted by how likely it is to bite.

## Mechanical (check on the real parts)

- **Motor orientation.** The OT-EM3215 drawing (datasheet p8) shows 3 x M1.6 on a 20.5 mm circle, 2 x 2.0 mm holes on a 21 mm circle, a 5.9 mm centre hole and an 11.5 mm boss, but does not say which face is the stator mount or which part turns. The hub, plate and column assume the top turns and the bottom mounts.
- **Motor leads.** A 3-pin 1.25 mm connector exits the side, 30 mm of wire. The plate slot for it is a guess.
- **Pole count.** The datasheet says 8 magnetic poles; SmartKnob firmware assumes 14. Detent tuning will differ.
- **Torque on 5 V.** The motor is rated 6 to 8 V. At about 0.55 A stall on 5 V the rim force at a 58 mm ring is roughly 0.75 N (rough estimate).
- **Cogging.** Nobody published a figure for this motor; the GM5208 and GM3506 were dropped after cogging reports.
- **Sensor.** Where the magnet sits and the useful air gap (MT6701 likes about 1 to 3 mm) are unknown. `sensor_holder.scad` is a placeholder.
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
- **Motor:** 3-wire lead leaves between two of the three screw holes (plate slot rotated to 30 degrees).
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
