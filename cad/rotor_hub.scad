// Rotor hub: the part that turns. It sits on top of the motor's rotor and carries the ring.
// Rotor is a 32 mm cup (outer-rotor motor): the whole 32 mm outside turns. Raised boss: dia 11.5 x 2.2 mm.
//
// Design: a flat disc that sits on the rotor top, locates on the 11.5 boss (a pocket), then three
// arms reach out past the 32 mm rotor and up to the ring's inside wall. Glue (CA/epoxy) the disc to
// the rotor top; DO NOT press it onto the shaft side. The hub never touches the column or the display carrier.
include <params.scad>

boss_pocket  = motor_boss_d + 0.2;         // locates on the 11.5 mm boss
boss_depth   = motor_boss_h;               // 2.2
clear_col    = 7.6;                        // hole in the middle: column OD 5.6 + 2 mm. The hub must NOT touch the column
arm_w        = 8;                          // PROPOSAL
arm_len_r    = ring_id / 2 + 2.8;          // walls end 0.3 mm short of the ring pocket floor (pocket runs r = ring_id/2-0.5 .. +3.3)
ring_seat_h  = ring_h - 2;                 // how far up the arms climb along the ring inside

module rotor_hub() {
    difference() {
        union() {
            // flat disc on the rotor, 32 mm wide so the whole top face is used for gluing
            cylinder(d = motor_od - 1, h = hub_t);
            // three arms from the disc out to the ring
            for (a = [0, 120, 240])
                rotate([0, 0, a]) translate([0, -arm_w / 2, 0]) cube([arm_len_r, arm_w, hub_t]);
            // vertical ring seat: three short walls, each one a segment of the ring inside wall
            for (a = [0, 120, 240])
                rotate([0, 0, a]) translate([arm_len_r - 3, -arm_w / 2, 0]) cube([3, arm_w, ring_seat_h]);
        }
        // pocket on the underside for the rotor boss
        translate([0, 0, -0.01]) cylinder(d = boss_pocket, h = boss_depth + 0.01);
        // clear hole for the column and wires
        translate([0, 0, -1]) cylinder(d = clear_col, h = hub_t + 2);
    }
}

rotor_hub();
