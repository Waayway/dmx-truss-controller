// TEST PRINTS (not final parts). Fast PETG prints to check fits on the real printer, before the full parts.
// Print these three files. Each is small and quick.
include <params.scad>

// column.scad defines these; repeated here so this file stands alone
col_od = motor_bore + 0.1 - 0.4;   // 5.6
col_id = col_od - 2 * 0.8;          // 4.0

// -------- 1. Guide tube test: fits the 5.9 mm motor bore, carries display wires --------
// Outer 5.6 (bore 5.9 +0.1 minus 0.4 clearance), inner 4.0 for ~10 thin wires. 75 mm long.
module guide_tube() {
    difference() {
        cylinder(d = col_od, h = 75);
        translate([0, 0, -1]) cylinder(d = col_id, h = 77);
    }
}

// -------- 2. Clearance ring: slides over the guide tube, shows what turns easily and what binds --------
// Five bores in one ring (a row of holes, each labelled by size) so one print tests five clearances at once.
// Bores: 5.9 (tight), 6.1, 6.3, 6.5, 6.7 (loose), each 8 mm long, in a 20 x 40 x 10 block.
module clearance_ring() {
    sizes = [5.9, 6.1, 6.3, 6.5, 6.7];
    difference() {
        translate([-20, -10, 0]) cube([40, 20, 10]);
        for (i = [0 : len(sizes) - 1])
            translate([-16 + i * 8, 0, -1]) cylinder(d = sizes[i], h = 12, $fn = 48);
    }
}

// -------- 3. Brace test: MT6701 board mounting, 28 x 28 plate with the four M2 holes at 16.5 mm --------
module brace_test() {
    difference() {
        translate([-14, -14, 0]) cube([28, 28, 3]);
        translate([0, 0, -1]) cylinder(d = 8, h = 5, $fn = 40);            // centre opening for the wires
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx * mt_hole_pitch / 2, sy * mt_hole_pitch / 2, -1]) cylinder(d = 2.2, h = 5, $fn = 32);
        translate([-mt_board / 2, -mt_board / 2, 3 - 1.6]) cube([mt_board, mt_board, 2]);   // board pocket (1.6 mm pcb)
    }
}

// choose which one to export: -D part="guide"|"ring"|"brace"
part = "guide";
if (part == "guide") guide_tube();
if (part == "ring") clearance_ring();
if (part == "brace") brace_test();
