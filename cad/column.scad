// Fixed column: carries the display and lets the wires through the motor bore.
// It stays still. The rotor turns around it. It is glued/screwed to the front plate from the back.
//
//   z=0   : foot (flat disc) that sits in the base and is screwed to the front plate
//   z=foot: tube, OD 5.6 mm (bore is 5.9 +0.1), ID 4.0 mm (10 thin wires), runs up through the motor
//   top   : mounts the display carrier (display_carrier.scad) with two M1.6 screws
include <params.scad>

col_clear   = 0.4;                         // radial running clearance 0.2 per side (PROPOSAL, tune on the printer)
col_od      = motor_bore + 0.1 - col_clear; // 5.6
col_wall    = 0.8;                         // two perimeters at 0.4 mm. PROPOSAL, thin: test print first
col_id      = col_od - 2 * col_wall;       // 4.0
foot_d      = 24;
foot_t      = 3;
// length: from the foot up through the stator, rotor and boss, plus the carrier seat
col_len     = col_top_z - (col_foot_z + foot_t);   // derived from the z stack in params.scad
echo(str("column OD ", col_od, " ID ", col_id, "  free area mm2 ", PI * pow(col_id/2, 2)));

module column() {
    difference() {
        union() {
            cylinder(d = foot_d, h = foot_t);                       // foot
            cylinder(d = col_od, h = foot_t + col_len);             // tube
            // 3 mm fillet cone at the root: the weak point is layer adhesion where the tube meets the foot
            translate([0, 0, foot_t - 0.01]) cylinder(d1 = col_od + 6, d2 = col_od, h = 3);
        }
        translate([0, 0, -1]) cylinder(d = col_id, h = foot_t + col_len + 2);     // wire channel
        // three M1.6 holes in the foot, matching the motor holes (datasheet pitch circle 20.5)
        for (i = [0 : 2])
            rotate([0, 0, i * 120 + 90]) translate([motor_hole_pcd / 2, 0, -1])
                cylinder(d = motor_hole_thr + 0.4, h = foot_t + 2, $fn = 32);
        // wire exit slot in the foot, so the wire bundle can leave sideways without a hard kink
        translate([0, -foot_d/2 - 1, -1]) cube([4, foot_d/2 + 1, foot_t + 1]);
    }
}

column();
