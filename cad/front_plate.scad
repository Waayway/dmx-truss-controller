// Front plate: closes the base from the front and carries the fixed column + the motor.
// Parts that turn (ring, rotor) are separate (ring.scad, rotor_hub.scad).
//
// The plate has a central hole for the display column. The motor's stator sits UNDER the plate
// (inside the base), its 32 mm body clamped from behind by the plate and four M2 screws.
// The pedestal (58 mm) sits ON the plate and hides the motor.
include <params.scad>

col_od        = 11;        // outside diameter of the column that carries the display. PROPOSAL
col_id        = 5.9 + 0.4; // inner hollow clears the 5.9 mm motor bore and the wire bundle. see column.scad

module octagon(across_flats, h) {
    r = across_flats / 2 / cos(22.5);
    rotate([0, 0, 22.5]) cylinder(r = r, h = h, $fn = 8);
}

module front_plate() {
    inner = base_flat - 2 * base_wall;
    difference() {
        octagon(inner - 0.4, plate_t);                        // 0.4 mm running clearance in the base
        // central opening for the column + wires
        translate([0, 0, -1]) cylinder(d = col_od + 2 * fit, h = plate_t + 2);
        // four screw holes at the diagonal corners (match front_bosses in the base)
        for (a = [45, 135, 225, 315])
            rotate([0, 0, a]) translate([base_r_corner - 8, 0, -1])
                cylinder(d = 3.4, h = plate_t + 2, $fn = 32);
        // three M2 pilot holes for the pedestal tabs (match pedestal.scad: radius 21, angles 30/150/270)
        for (a = [30, 150, 270])
            rotate([0, 0, a]) translate([21, 0, -1]) cylinder(d = 1.7, h = plate_t + 2, $fn = 32);
        // slot for the motor leads (3-pin 1.25 mm connector exits the side of the motor; position UNVERIFIED)
        translate([motor_od / 2 - 6, -5, -1]) cube([14, 10, plate_t + 2]);
        // three M1.6 clearance holes on the 20.5 pitch circle (datasheet), 120 degrees apart
        for (i = [0 : motor_hole_n - 1])
            rotate([0, 0, i * 360 / motor_hole_n + 90]) translate([motor_hole_pcd / 2, 0, -1])
                cylinder(d = motor_hole_thr + 0.4, h = plate_t + 2, $fn = 32);
    }
}

front_plate();
