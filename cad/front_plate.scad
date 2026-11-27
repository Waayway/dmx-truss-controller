// Front plate: closes the base from the front and carries the fixed column + the motor.
// Parts that turn (ring, rotor) are separate (ring.scad, rotor_hub.scad).
//
// The plate has a central hole for the display column. The motor's stator sits UNDER the plate
// (inside the base), its 32 mm body clamped from behind by the plate and four M2 screws.
// The pedestal (58 mm) sits ON the plate and hides the motor.
include <params.scad>

plate_boss_hole = motor_boss_d + 1.0;   // opening for the motor's magnet boss (Ø11.5) and the column; the motor is located by its screws, not by this hole

module octagon(across_flats, h) {
    r = across_flats / 2 / cos(22.5);
    rotate([0, 0, 22.5]) cylinder(r = r, h = h, $fn = 8);
}

module front_plate() {
    inner = base_flat - 2 * base_wall;
    difference() {
        octagon(inner - 0.4, plate_t);                        // 0.4 mm running clearance in the base
        // central opening for the column + wires
        translate([0, 0, -1]) cylinder(d = plate_boss_hole, h = plate_t + 2);
        // four screw holes at the diagonal corners (match front_bosses in the base)
        for (a = boss_angles)
            rotate([0, 0, a]) translate([boss_r, 0, -1])
                cylinder(d = 3.4, h = plate_t + 2, $fn = 32);
        // three M2 pilot holes for the pedestal tabs (match pedestal.scad: radius 21, angles 90/210/330, so the lead slot at 30 degrees stays free)
        for (a = [90, 210, 330])
            rotate([0, 0, a]) translate([21, 0, -1]) cylinder(d = 1.7, h = plate_t + 2, $fn = 32);
        // motor lead: it leaves the stator face between two screw holes (user), at 30 degrees. A 5 mm wide, 1.2 mm deep groove in the plate TOP
        // carries it out from under the motor, then a through slot at radius 17..24 (outside the column foot, r 14.5) lets it drop into the base.
        rotate([0, 0, 30]) translate([6, -2.5, plate_t - 1.2]) cube([14, 5, 2]);
        rotate([0, 0, 30]) translate([17, -4, -1]) cube([7, 8, plate_t + 2]);
        // three M1.6 clearance holes on the 20.5 pitch circle (datasheet), 120 degrees apart
        for (i = [0 : motor_hole_n - 1])
            rotate([0, 0, i * 360 / motor_hole_n + 90]) translate([motor_hole_pcd / 2, 0, -1])
                cylinder(d = 2.4, h = plate_t + 2, $fn = 32);   // LOOSE: the foot, not the plate, locates the motor
    }
}

front_plate();
