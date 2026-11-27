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

// -------- 2. Brace test: MT6701 board mounting, 30 x 30 plate with the four M2 holes at 16.5 mm --------
// The first version cut the pocket at exactly 22.0 mm for a 21.8 x 22.0 mm board and did not fit.
// Two variants: pocket = board + 0.6 (brace) and board + 1.0 (brace_wide). Use the tighter one that drops in without force.
module brace_test(clr) {
    pocket = mt_board + clr;
    difference() {
        translate([-15, -15, 0]) cube([30, 30, 3.2]);
        translate([0, 0, -1]) cylinder(d = 8, h = 6, $fn = 40);            // centre opening for the wires
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx * mt_hole_pitch / 2, sy * mt_hole_pitch / 2, -1]) cylinder(d = 2.2, h = 6, $fn = 32);
        translate([-pocket / 2, -pocket / 2, 3.2 - 1.6]) cube([pocket, pocket, 2]);   // board pocket, 1.6 mm deep
    }
}

// choose which one to export: -D part="shafts"|"brace"|"brace_wide"
part = "shafts";
if (part == "shafts") shafts();
if (part == "brace") brace_test(0.6);
if (part == "brace_wide") brace_test(1.0);
