// Base: octagonal back housing, final version with TWO identical Neutrik D-size jack cutouts.
// Prints with the back plate on the bed (wall side down).
//
// Looking into the open base (wall plate behind): +x right, +y up, +z towards the viewer.
//   bottom facet : Neutrik USB-C jack (fly-lead plugs into the Nano, laid as a U-turn, see ghosts.scad)
//   right facet  : XLR jack
// The hanging direction is "down" = the bottom facet, so the USB-C cable hangs towards the floor on a wall.
include <params.scad>

module octagon(across_flats, h) {
    r = across_flats / 2 / cos(22.5);
    rotate([0, 0, 22.5]) cylinder(r = r, h = h, $fn = 8);
}

// Frame of one facet: origin on the OUTER face at position `along` and height `zc`;
// local x runs along the facet, local +y points INTO the base, local z is up.
// ang 0 = bottom facet, 90 = right facet, 180 = top, 270 = left.
module on_facet(ang, along, zc) {
    rotate([0, 0, ang]) translate([along, -base_flat / 2, zc]) children();
}

module d_pad() {                       // extra wall on the inside for the nut traps
    translate([-pad_w / 2, base_wall - 0.01, -pad_h / 2]) cube([pad_w, pad_t + 0.01, pad_h]);
}

module d_cut() {                       // hole, four screw holes (both diagonals, so either flange orientation fits), nut traps
    thick = base_wall + pad_t;
    translate([0, -1, 0]) rotate([-90, 0, 0]) cylinder(d = d_hole + 0.3, h = thick + 2);
    for (sx = [-1, 1], sz = [-1, 1])
        translate([sx * d_screw_along / 2, 0, sz * d_screw_z / 2]) {
            translate([0, -1, 0]) rotate([-90, 0, 0]) cylinder(d = d_screw_d, h = thick + 2, $fn = 32);
            translate([0, thick - nut_t, 0]) rotate([-90, 0, 0]) cylinder(d = nut_af / cos(30) + 0.2, h = nut_t + 1, $fn = 6);
        }
}

module keyhole2d() {
    circle(d = key_head);                                                     // head hole
    translate([-key_slot / 2, -key_slot_len]) square([key_slot, key_slot_len]);   // slot points DOWN
}

module post(d, pilot, h) {
    difference() {
        cylinder(d = d, h = h);
        if (pilot > 0) translate([0, 0, 1]) cylinder(d = pilot, h = h);
    }
}

module base() {
    inner = base_flat - 2 * base_wall;
    difference() {
        union() {
            // shell: back plate + octagon wall
            difference() {
                octagon(base_flat, base_depth);
                translate([0, 0, back_plate]) octagon(inner, base_depth);
            }
            on_facet(0, usbc_x, jack_zc) d_pad();
            on_facet(90, xlr_along, jack_zc) d_pad();

            // four posts that carry perfboard strip A (the Nano strip). They stand in the corners, outside the Nano's pin rows.
            // The board is held with hot glue or a drop of epoxy; there is no screw because the Nano covers the ends.
            for (sx = [-1, 1], y = [boardA_y0 + 1.5, boardA_y0 + boardA_l - 1.5])
                translate([boardA_cx + sx * (boardA_w / 2 - 1.5), y, back_plate - 0.01])
                    cylinder(d = 3, h = post_h + 0.01);

            // four corner bosses for the front plate; they stop under the plate
            for (a = boss_angles)
                rotate([0, 0, a]) translate([boss_r, 0, back_plate - 0.01])
                    post(7, 2.4, z_plate_top - plate_t - back_plate + 0.01);   // M3 self-tapping pilot
        }

        on_facet(0, usbc_x, jack_zc) d_cut();
        on_facet(90, xlr_along, jack_zc) d_cut();

        // two keyholes through the back plate, slot pointing down
        for (sy = [-1, 1])
            translate([key_x, sy * key_dx / 2, -1])
                linear_extrude(back_plate + 2) keyhole2d();
    }
}

base();
