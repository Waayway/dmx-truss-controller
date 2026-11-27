// Ring: the part you hold and turn. 58 mm outside, 41.6 mm inside, with fine knurl ribs.
// It is glued/screwed to the three walls of the rotor hub (rotor_hub.scad).
//
// Two-colour print: the ribs are a SEPARATE solid from the ring body, so each can have its own filament.
// The ribs sit in 0.6 mm deep pockets in the body (they key into it) and stand 0.7 mm proud, so the two solids share faces and never overlap.
//   openscad -D 'part="all"'   ring.scad   one-colour ring (stl/ring.stl, the default)
//   openscad -D 'part="body"'  ring.scad   ring without ribs
//   openscad -D 'part="ribs"'  ring.scad   the 60 ribs only
// scripts/make-3mf.mjs packs body + ribs into cad/3mf/ring-two-colour.3mf.
include <params.scad>

rib_n     = 60;
rib_w     = 1.0;
rib_d     = 0.7;     // how far a rib stands proud of the ring surface, PROPOSAL
rib_key   = 0.6;     // how deep it sits in the body
mark_d    = 2.2;     // position marker dot

module rib_cut()  { for (i = [0 : rib_n - 1]) rotate([0, 0, i * 360 / rib_n]) translate([ring_od / 2 - rib_key, -rib_w / 2, -1]) cube([rib_key + 1, rib_w, ring_h + 2]); }
module ribs()     { for (i = [0 : rib_n - 1]) rotate([0, 0, i * 360 / rib_n]) translate([ring_od / 2 - rib_key, -rib_w / 2, 0]) cube([rib_key + rib_d, rib_w, ring_h]); }

module ring_body() {
    difference() {
        cylinder(d = ring_od, h = ring_h);
        translate([0, 0, -1]) cylinder(d = ring_id, h = ring_h + 2);
        rib_cut();
        // position marker: a small round recess in the top face at 12 o'clock
        translate([0, ring_od / 2 - 4, ring_h - 0.6]) cylinder(d = mark_d, h = 1, $fn = 24);
        // three pockets on the inside for the hub walls (3 x 8 wide, 3 deep), 120 degrees apart
        for (a = [0, 120, 240])
            rotate([0, 0, a]) translate([ring_id / 2 - 0.5, -4.2, 0.4]) cube([3.8, 8.4, ring_h - 0.8]);
    }
}

module ring() { union() { ring_body(); ribs(); } }

part = "all";
if (part == "all")  ring();
if (part == "body") ring_body();
if (part == "ribs") ribs();
