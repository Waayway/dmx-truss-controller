// Display carrier: holds the Waveshare 1.28in module on top of the fixed column.
// Module outline: round PCB dia 38.5, with a connector tab on one side (total length 39.89, width 38.5).
// This part is FIXED (never turns). It sits inside the ring with running clearance.
//
// Print with the display pocket facing UP. Four tiny tabs hold the module; no screws on the glass.
include <params.scad>

pocket_d = disp_od + 0.4;            // PCB dia 38.5 + clearance
carrier_d = pocket_d + 2.4;          // 1.2 mm rim
boss_below = 4;                      // PROPOSAL
tab_w     = 8;                       // flat tab where the 13-pin connector/cable leaves (module length 39.89 - 38.5 = 1.4 mm of tab)

module display_carrier() {
    difference() {
        union() {
            cylinder(d = carrier_d, h = carrier_t);
            // boss BELOW the floor: gives the column a 5.6 mm deep socket instead of a 1.8 mm one
            translate([0, 0, -boss_below]) cylinder(d = col_od + 5, h = boss_below + 0.01);
        }
        // display pocket
        translate([0, 0, carrier_t - pocket_h]) cylinder(d = pocket_d, h = pocket_h + 1);
        // blind socket for the column (0.1 mm clearance, glue), stops 0.2 mm below the pocket floor
        translate([0, 0, -boss_below - 1]) cylinder(d = col_od + 0.1, h = boss_below + 1 + (carrier_t - pocket_h) - 0.2);
        // open the middle so the cable can come up from the column into the pocket
        translate([0, 0, -boss_below - 1]) cylinder(d = 4.0, h = boss_below + carrier_t + 3);
        // cable slot for the GH1.25 cable on the connector side (module tab), width tab_w
        translate([-tab_w/2, -pocket_d/2 - 1, carrier_t - pocket_h]) cube([tab_w, 6, pocket_h + 1]);
    }
}

display_carrier();
