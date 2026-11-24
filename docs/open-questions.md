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
- **Display module thickness** (3.4 mm used) and carrier pocket depth are estimates.
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
- **Touch INT.** Plan v4.5 leaves it unwired; an earlier pin plan reserved A6.

## Shopping

- **Neutrik NAUSBC-5G-FL10** is a Conrad backorder (stock from a search snippet; Conrad blocks page reads). Only needed for the final housing; first test uses a USB-C cable straight into the Nano. FL15 gives more slack; price not read. The USB-C jack may work in one plug orientation only (not confirmed for this part).
- **BerryBase display** is "limited availability"; count unknown.
- **Re-check every price and stock level before ordering.** They were read on 2026-11-24 from product-page data, except the Conrad item.
- Shipping is not in any total (Kiwi: letterbox EUR 4.22, parcel EUR 7.20, free from EUR 150).

## Housing

- Final base with both D-size jacks (XLR on one facet, USB-C opposite) needs about 28 to 30 mm depth and a board of about 60 x 45 mm. Not modelled; waits for the Neutrik jack.
- 45 degree desk wedge not modelled yet.
- Plan v4.5 section 7 still shows the older slot-and-clamp drawing.

## Firmware

Not started. Plan: ESP32 Arduino core, SimpleFOC for detents, LVGL for the UI, `esp_dmx` for DMX out (24 slots), LittleFS for presets, web page for labels and patching.
