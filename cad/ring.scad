// Ring: the part you hold and turn. 58 mm outside, 43 mm inside. This file is the ring BODY: a plain cylinder.
// It is glued/screwed to the three walls of the rotor hub (rotor_hub.scad).
//
// The knurl is a lattice of diamond bumps in a separate solid (scripts/knurl.mjs -> cad/stl/ring-ribs.stl), so it can print in a
// second colour. scripts/make-3mf.mjs packs body + bumps into cad/3mf/ring-two-colour.3mf; the bumps sit ON the cylinder surface
// (base at r = ring_od / 2) and never overlap the body. The single-colour cad/stl/ring.stl is both shells in one file.
include <params.scad>

mark_d    = 2.2;     // position marker dot

module ring_body() {
    difference() {
        cylinder(d = ring_od, h = ring_h);
        translate([0, 0, -1]) cylinder(d = ring_id, h = ring_h + 2);
        // position marker: a small round recess in the top face at 12 o'clock
        translate([0, ring_od / 2 - 4, ring_h - 0.6]) cylinder(d = mark_d, h = 1, $fn = 24);
        // three pockets on the inside for the hub walls (3 x 8 wide, 3 deep), 120 degrees apart
        for (a = [0, 120, 240])
            rotate([0, 0, a]) translate([ring_id / 2 - 0.5, -4.2, 0.4]) cube([3.8, 8.4, ring_h - 0.8]);
    }
}

module ring() { ring_body(); }     // the clearance check and the assembly use the body; the bumps stay outside r = 29

ring_body();
