// Ring: the part you hold and turn. 58 mm outside, 41.6 mm inside, with fine knurl ribs.
// It is glued/screwed to the three walls of the rotor hub (rotor_hub.scad).
include <params.scad>

rib_n     = 60;
rib_w     = 1.0;
rib_d     = 0.7;     // rib depth, PROPOSAL
mark_d    = 2.2;     // position marker dot

module ring() {
    difference() {
        union() {
            cylinder(d = ring_od, h = ring_h);
            // knurl: small vertical ribs around the outside
            for (i = [0 : rib_n - 1])
                rotate([0, 0, i * 360 / rib_n]) translate([ring_od / 2 - 0.2, -rib_w / 2, 0]) cube([rib_d + 0.2, rib_w, ring_h]);
        }
        translate([0, 0, -1]) cylinder(d = ring_id, h = ring_h + 2);
        // position marker: a small round recess in the top face at 12 o'clock
        translate([0, ring_od / 2 - 4, ring_h - 0.6]) cylinder(d = mark_d, h = 1, $fn = 24);
        // three pockets on the inside for the hub walls (3 x 8 wide, 3 deep), 120 degrees apart
        for (a = [0, 120, 240])
            rotate([0, 0, a]) translate([ring_id / 2 - 0.5, -4.2, 0.4]) cube([3.8, 8.4, ring_h - 0.8]);
    }
}

ring();
