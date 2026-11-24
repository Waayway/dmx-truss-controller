# Pinout and wiring

Single board: **Arduino Nano ESP32** (ABX00083). One firmware. Pin names are the ones printed on the board; GPIO numbers are from the arduino-esp32 variant `arduino_nano_nora` (`pins_arduino.h`).
The schematic image is in [`docs/images/schematic.png`](../docs/images/schematic.png), its source is [`hardware/schematic-src/schematic.html`](schematic-src/schematic.html).

## Display module (Waveshare 1.28" Touch LCD, fixed, wires run through the motor bore)

| Display pin | Nano pin (GPIO) |
|---|---|
| SCLK | D13 (48) |
| MOSI | D11 (38) |
| LCD_CS | D10 (21) |
| LCD_DC | D9 (18) |
| LCD_RST | D8 (17) |
| LCD_BL | D7 (10) |
| TP_SDA | A4 (11) |
| TP_SCL | A5 (12) |
| VCC | 3V3 (must be 3.3 V: the module's level shifter follows its supply) |
| GND | GND |
| MISO, TP_INT, TP_RST | not connected in plans v4.4 and v4.5 (an earlier pin plan reserved A6 for TP_INT) |

## MT6701 angle sensor (I2C)

SDA to A4, SCL to A5 (same bus as the touch chip), VCC to 3V3, GND to GND. I2C address 0x06 per the plan; touch chip 0x15.

## TMC6300 motor driver

| TMC6300 pin | Connects to |
|---|---|
| UH | D2 (5) |
| UL | D3 (6) |
| VH | D4 (7) |
| VL | D5 (8) |
| WH | D6 (9) |
| WL | A0 (1) |
| VIO | A1 (2), so the driver is off at boot |
| VIN | VBUS pin of the Nano (5 V) |
| GND | GND |
| U, V, W | the three motor wires |

470 uF across VIN and GND right at the driver. 100 nF in parallel is optional.

## MAX485 and XLR

| MAX485 pin | Connects to |
|---|---|
| DI | D12 (47) |
| DE and RE | tied together, to +5 V (always sending) |
| RO | not used |
| VCC | +5 V (VBUS) |
| GND | GND |
| A | XLR pin 3 (DATA +) |
| B | XLR pin 2 (DATA -) |
| XLR pin 1 | GND |

Terminator: a 120 ohm XLR plug goes in the DMX out of the **last** lamp, not in this box.

## Power

The 5 V USB-C supply plugs into the Nano's USB-C port; VBUS feeds the TMC6300 and the MAX485. To program, unplug the supply and plug the PC into the same port. **Never both at once.**

## Pins used

16 of 22 are used. Free: D0, A2, A3, A7 (and A6 if TP_INT stays unwired). D1 (GPIO43) is the hardware UART TX and may print at boot, which is why DMX TX is on D12.

## Fixtures (21 channels)

| Fixture | Start address | Channels |
|---|---|---|
| Wild Wash 6Ch | A001 | Dimmer, Strobe, R, G, B, Sound |
| Root Par TW 7Ch | A007 | dimmer, fine dimmer, strobe, cold white, warm white, colour temperature, sound |
| Vintage Bowl 30 RGBA 8Ch | A014 | R, G, B, amber, macro, strobe, mode, dimmer |

Firmware tips: send only 24 slots; run the DMX task on its own core; `esp_dmx` library; LVGL for the UI; LittleFS for presets; SimpleFOC for the detents. Firmware is **not started**.
