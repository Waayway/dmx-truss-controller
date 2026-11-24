// Pedestal: fixed 58 mm drum that sits on the front plate and hides the motor.
// The ring turns on top of it with a 0.8 mm gap.
// It is held by three M2 self-tapping screws through tabs at its foot (pilot holes in the front plate).
// Assembly order: screw the pedestal to the plate FIRST (screwdriver goes in through the top opening),
// then drop the motor in, then the hub, ring and carrier.
include <params.scad>

ped_wall   = 2.0;
open_d     = pedestal_od - 2 * ped_wall - 4;     // top opening dia 50: hub walls (r 24.3) pass with 0.7 mm to spare
tab_r      = 21;                                 // screw circle radius, inside the opening so a driver reaches it
tab_angles = [30, 150, 270];

module pedestal() {
    difference() {
        union() {
            difference() {
                cylinder(d = pedestal_od, h = pedestal_h);
                translate([0, 0, -1]) cylinder(d = pedestal_od - 2 * ped_wall, h = pedestal_h - 2.5 + 1);   // cavity for the motor
                translate([0, 0, -1]) cylinder(d = open_d, h = pedestal_h + 2);                           // top opening
            }
            // three foot tabs inside the cavity, 2.5 mm thick, from r=17 out to the wall
            for (a = tab_angles)
                rotate([0, 0, a]) translate([17, -4.5, 0]) cube([pedestal_od / 2 - ped_wall - 16.5, 9, 2.5]);
        }
        for (a = tab_angles)
            rotate([0, 0, a]) translate([tab_r, 0, -1]) cylinder(d = 2.4, h = 5, $fn = 32);   // M2 clearance, screw heads sit on the tab
    }
}

pedestal();
