// Base: octagonal back housing, final version with TWO identical Neutrik D-size jack cutouts.
// Prints with the back plate on the bed (wall side down).
//
// Looking into the open base (wall plate behind): +x right, +y up, +z towards the viewer.
//   bottom facet : Neutrik USB-C jack (fly-lead plugs into the Nano, laid as a U-turn, see ghosts.scad)
//   XLR facet    : see xlr_angle in params.scad (top, so the XLR sits next to the MAX485)
// The hanging direction is "down" = the bottom facet, so the USB-C cable hangs towards the floor on a wall.
include <params.scad>
include <lib.scad>

module octagon(across_flats, h) {
    r = across_flats / 2 / cos(22.5);
    rotate([0, 0, 22.5]) cylinder(r = r, h = h, $fn = 8);
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
            // ledge under the plate edge, all round
            translate([0, 0, z_plate_top - plate_t - plate_ledge_h])
                difference() {
                    octagon(inner + 0.2, plate_ledge_h);
                    translate([0, 0, -1]) octagon(inner - 2 * plate_ledge_w, plate_ledge_h + 2);
                }
            on_facet(0, usbc_x, jack_zc) d_pad();
            on_facet(xlr_angle, xlr_along, jack_zc) d_pad();

            // rim frames under the three perfboard pieces (A: Nano, B1: MAX485, B2: TMC6300). The board edge rests on a 1.2 mm wall,
            // so the solder pads and pin tips in the middle stay free. The boards are held with hot glue or a drop of epoxy.
            p = pieceA();  board_frame(p[0], p[1], p[2], p[3], p[4]);
            p1 = pieceB1(); board_frame(p1[0], p1[1], p1[2], p1[3], p1[4]);
            p2 = pieceB2(); board_frame(p2[0], p2[1], p2[2], p2[3], p2[4]);

            // four corner bosses for the front plate; they stop under the plate
            for (a = boss_angles)
                rotate([0, 0, a]) translate([boss_r, 0, back_plate - 0.01])
                    post(7, 2.4, z_plate_top - plate_t - back_plate + 0.01);   // M3 self-tapping pilot
        }

        on_facet(0, usbc_x, jack_zc) d_cut();
        on_facet(xlr_angle, xlr_along, jack_zc) d_cut();

        // two keyholes through the back plate, side by side, slots pointing down
        for (sx = [-1, 1])
            translate([sx * key_dx / 2, key_y, -1])
                linear_extrude(back_plate + 2) keyhole2d();
    }
}

base();
