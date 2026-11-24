// MT6701 sensor holder: holds the small MT6701 breakout board under the rotor's magnet,
// centred on the motor axis, at a set air gap. The module comes with its own magnet in some listings;
// the SparkFun motor has a built-in magnet. The air gap must be measured on the real part.
//
// UNVERIFIED: where the magnet sits inside the SparkFun motor and how big the useful air gap is
// (MT6701 works best at about 1-3 mm). Print this, then adjust `gap` by shimming.
include <params.scad>

mt_w     = 23;     // module size (listing: 23 x 23 mm; the HobbyElectronica board is not measured yet)
mt_t     = 1.6;    // pcb
gap      = 2.0;    // air gap between the sensor chip and the rotor underside. PROPOSAL, measure
holder_t = 3;
post_d   = 5;

module sensor_holder() {
    difference() {
        union() {
            // a small plate that carries the sensor board, centred on the axis
            translate([-mt_w/2 - 2, -mt_w/2 - 2, 0]) cube([mt_w + 4, mt_w + 4, holder_t]);
            // two screw posts to the back plate area
            for (sx = [-1, 1]) translate([sx * (mt_w/2 + 3), 0, 0]) cylinder(d = post_d, h = holder_t + 2, $fn = 40);
        }
        // pocket for the MT6701 board
        translate([-mt_w/2, -mt_w/2, holder_t - mt_t]) cube([mt_w, mt_w, mt_t + 1]);
        // hole through the middle: the column and the wire bundle pass here
        translate([0, 0, -1]) cylinder(d = 8, h = holder_t + 2, $fn = 40);
        // screw holes M2
        for (sx = [-1, 1]) translate([sx * (mt_w/2 + 3), 0, -1]) cylinder(d = 2.4, h = holder_t + 4, $fn = 32);
    }
}

sensor_holder();
