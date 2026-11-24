# Bill of materials

Generated from `bom.csv` by `scripts/gen-bom-md.mjs`. Prices are EUR including VAT, **shipping not included**.
Stock was read from each shop's own product page on 2026-11-24 unless noted. Re-check before ordering.

| Ref | Part | Qty | Shop | EUR | Stock basis | Link |
|---|---|---|---|---|---|---|
| U1 | Arduino Nano ESP32 with headers (ABX00083) | 1 | Kiwi Electronics | 21.40 | in stock (product page JSON-LD 2026-11-24) | <https://www.kiwi-electronics.com/en/arduino-nano-esp32-with-headers-11494> |
| M1 | SparkFun gimbal motor ROB-20441 (OT-EM3215) | 1 | Kiwi Electronics | 53.23 | in stock (page JSON-LD 2026-11-24) | <https://www.kiwi-electronics.com/en/three-phase-brushless-gimbal-stabilizer-motor-11295> |
| U2 | SparkFun TMC6300 driver ROB-21867 | 1 | Kiwi Electronics | 20.80 | in stock (page JSON-LD 2026-11-24) | <https://www.kiwi-electronics.com/en/brushless-motor-driver-3-phase-11460> |
| C1 | Capacitor 470 uF 16 V radial | 1 | Kiwi Electronics | 0.96 | in stock (page JSON-LD 2026-11-24) | <https://www.kiwi-electronics.com/en/470uf-16v-radial-capacitor-20174> |
| - | 40-pin header strip 2.54 mm | 1 | Kiwi Electronics | 0.96 | in stock (page JSON-LD 2026-11-24) | <https://www.kiwi-electronics.com/en/40-pin-header-strip-2-54mm-pitch-4100> |
| U4 | Waveshare 1.28in Touch LCD module (GC9A01 + CST816S) | 1 | BerryBase | 19.90 | limited availability (page JSON-LD 2026-11-24) | <https://www.berrybase.de/en/waveshare-1.28-round-ips-display-module-capacitive-touch-lcd-240-240-ips-spi-and-i2c-io-pins> |
| U3 | MT6701 14-bit angle sensor module I2C | 1 | HobbyElectronica | 3.95 | in stock (page JSON-LD 2026-11-24) | <https://www.hobbyelectronica.nl/en/product/mt6701-14-bit-hoeksensor-i2c> |
| U5 | MAX485 TTL to RS485 module | 1 | Otronic | 1.15 | in stock (page JSON-LD 2026-11-24) | <https://www.otronic.nl/en/max485-ttl-to-rs485-converter-module> |
| J2 | Neutrik NC3FD-LX XLR 3-pin female panel jack | 1 | Thomann | 4.50 | in stock (page 2026-11-24) | <https://www.thomann.de/de/neutrik_nc3_fd_lx.htm> |
| T1 | Stairville DMX terminator plug (XLR male) | 1 | Thomann | 4.90 | in stock (page 2026-11-24) | <https://www.thomann.de/de/stairville_dmx_endstecker_xlr_3pol.htm> |
| J1 | Neutrik NAUSBC-5G-FL10 USB-C D-size panel jack with 10 cm cable | 1 | Conrad | 11.99 | backorder "Bald verfuegbar" (search snippets only; Conrad blocks page reads; a second snippet showed EUR 10.99 so 11.99 is the cautious figure) | <https://www.conrad.de/de/p/neutrik-usb-c-kabel-usb-c-buchse-usb-c-stecker-10-cm-schwarz-flammwidrig-nausbc-5g-fl10-3863079.html> |
| PS1 | USB-C supply 5 V 3 A (Raspberry Pi) | 0 | already owned | 0.00 | owned | - |
| - | Perfboard 5 x 7 cm; M1.6 / M2 / M2.5 / M3 screws; PETG; DMX cable | 0 | already owned / to find | 0.00 | you have the board and PETG; check screws | - |

## Totals

- **Everything on the list:** EUR 143.74
- **First test only** (no XLR panel jack, no USB-C panel jack, no terminator; USB-C cable straight into the Nano): EUR 122.35

### By shop

- Kiwi Electronics: EUR 97.35
- BerryBase: EUR 19.90
- HobbyElectronica: EUR 3.95
- Otronic: EUR 1.15
- Thomann: EUR 9.40
- Conrad: EUR 11.99

## Notes

- **U1** ESP32-S3; headers fitted. Tinytronics is EUR 21.00 but needs a separate shipment
- **M1** 32 mm; 5.9 mm bore; 8 magnetic poles (datasheet)
- **U2** 2-11 V; 6 PWM inputs
- **C1** 5 V rail
- **-** MALE pin strip (pins 11.6 mm long); snap off pieces. For modules that arrive without pins (check the MT6701 and MAX485 and TMC6300 listings). It is NOT a socket. The Nano with headers already has its own pins
- **U4** Comes with a 13-pin GH1.25 cable per Waveshare
- **U3** Pin names not yet seen
- **U5** Check for a built-in 120 ohm resistor
- **J2** D-size: 24 mm hole; 24.1 mm deep behind the panel. FINAL housing only
- **T1** Goes in the DMX out of the LAST lamp. Skip if you own one
- **J1** FINAL housing only. First test: USB-C cable straight into the Nano. FL15 (25 cm lead) is the slack option; price not read
- **PS1** You own one
- **-** See hardware/screws.md for the counts

## Shipping (Kiwi only, from its help page)

Letterbox EUR 4.22, parcel EUR 7.20, free from EUR 150. Other shops: not checked.
