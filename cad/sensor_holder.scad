// MT6701 board carrier (PLACEHOLDER): holds the user's 22 x 22 mm MT6701 breakout flat, chip facing up, with four M2 screws.
// The board has four holes of about 2.1 mm on a 16.5 mm square and the chip dead centre (measured from the user's photos).
//
// NOT SOLVED: where this goes. The magnet (4 mm across, 1.5 mm thick, supplied with the sensor) must sit on the motor axis
// 1-3 mm above/below the chip and turn with the rotor, but the display column and its wires occupy the axis.
// This part only exists so the board dimensions are in the repo; do not print it before the arrangement is decided.
include <params.scad>

carrier_w = mt_board + 6;     // 28 x 28
carrier_t = 3;
pocket    = mt_board + 0.4;   // 0.2 mm clearance each side
pcb_t     = 1.6;              // ESTIMATE of the MT6701 board thickness (not measured)

module sensor_holder() {
    difference() {
        translate([-carrier_w / 2, -carrier_w / 2, 0]) cube([carrier_w, carrier_w, carrier_t]);
        // pocket for the board
        translate([-pocket / 2, -pocket / 2, carrier_t - pcb_t]) cube([pocket, pocket, pcb_t + 1]);
        // four M2 pilot holes on the board's 16.5 mm square (self-tapping into PETG)
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx * mt_hole_pitch / 2, sy * mt_hole_pitch / 2, 0.8]) cylinder(d = 1.7, h = carrier_t, $fn = 32);
    }
}

sensor_holder();
