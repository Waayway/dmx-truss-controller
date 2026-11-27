// TEST PRINTS (not final parts). Fast PETG prints to check fits on the real printer, before the full parts.
// Print these three files. Each is small and quick. (The clearance ring was dropped: test against the real motor instead.)
include <params.scad>


// -------- 1. Short shafts: five loose tubes, push each into the REAL motor bore and spin the motor by hand --------
// OD 5.3 / 5.4 / 5.5 / 5.6 / 5.7, ID 4.0, so the same print also checks the wire space.
// The height tells them apart: 10 mm = OD 5.3, 11 mm = 5.4, 12 mm = 5.5, 13 mm = 5.6, 14 mm = 5.7. Print standing up, nothing joins them.
module shafts() {
    for (i = [0 : 4])
        translate([i * 9, 0, 0]) difference() {
            cylinder(d = 5.3 + i * 0.1, h = 10 + i, $fn = 64);
            translate([0, 0, -1]) cylinder(d = 4.0, h = 20, $fn = 64);
        }
}

// -------- 2. Brace test: MT6701 board mounting, 28 x 28 plate with the four M2 holes at 16.5 mm --------
module brace_test() {
    difference() {
        translate([-14, -14, 0]) cube([28, 28, 3]);
        translate([0, 0, -1]) cylinder(d = 8, h = 5, $fn = 40);            // centre opening for the wires
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx * mt_hole_pitch / 2, sy * mt_hole_pitch / 2, -1]) cylinder(d = 2.2, h = 5, $fn = 32);
        translate([-mt_board / 2, -mt_board / 2, 3 - 1.6]) cube([mt_board, mt_board, 2]);   // board pocket (1.6 mm pcb)
    }
}

// choose which one to export: -D part="shafts"|"brace"
part = "guide";
if (part == "shafts") shafts();
if (part == "brace") brace_test();
