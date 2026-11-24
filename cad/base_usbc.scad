// Base: octagonal back housing. Prints with the back plate on the bed (wall side down).
// FIRST-TEST version: the supply's USB-C plug goes straight into the Nano through a slot in the
// bottom facet, held by a printed clamp bar (clamp_bar.scad). Both D-size jacks (XLR + Neutrik USB-C)
// belong to the final housing (base_dsize.scad).
//
// Orientation in this file (looking at the OPEN side of the base, wall plate behind):
//   +x right, +y up, +z towards the viewer. The USB-C slot is in the BOTTOM facet (y = -45).
include <params.scad>

// ---------- stack-up, measured from the back of the base (z = 0) ----------
post_h        = 4;                            // perfboard standoff height            PROPOSAL
board_t       = 1.6;                          // perfboard thickness                  typical
sock_h        = 4.0;                          // LOW header/socket height under Nano  PROPOSAL, must be bought low
pin_in        = 2.0;                          // pin insertion depth into socket
nano_pcb_t    = 1.0;                          // Nano pcb thickness                   ESTIMATE
usbc_h        = 3.2;                          // USB-C receptacle height              typical
board_z       = back_plate + post_h;          // underside of the perfboard
nano_z0       = board_z + board_t + sock_h - pin_in;   // underside of the Nano pcb
plug_axis_z   = nano_z0 + nano_pcb_t + usbc_h/2;       // centreline of the USB-C plug
echo(str("perfboard underside z=", board_z, "  Nano underside z=", nano_z0, "  plug axis z=", plug_axis_z));
echo(str("slot spans z=", plug_axis_z - usbc_slot_h/2, " to ", plug_axis_z + usbc_slot_h/2,
         "  (front plate starts at z=", base_depth - 2.5, ")"));
assert(plug_axis_z + usbc_slot_h/2 < base_depth - 2.5, "USB-C slot reaches into the front plate: lower the Nano or deepen the base");

// Nano sits on the perfboard, long axis vertical, USB-C end towards the bottom facet.
nano_cx       = 0;                            // x of the Nano centre line: slot centred on the bottom facet
nano_y_bottom = -26;                          // y of the Nano's USB-C end            PROPOSAL (plug enters here)

// x position of the two keyholes: clear of the Nano line (x=-9) and the clamp posts (x=-21, +3)
key_x         = 20;                           // PROPOSAL: clear of the Nano line and the clamp posts

module octagon(across_flats, h) {
    r = across_flats / 2 / cos(22.5);
    rotate([0, 0, 22.5]) cylinder(r = r, h = h, $fn = 8);
}

module keyhole2d() {
    circle(d = key_head);                                           // head hole
    translate([-key_slot/2, -key_slot_len]) square([key_slot, key_slot_len]);   // slot points DOWN
}

module post(d, pilot, h) {
    difference() {
        cylinder(d = d, h = h);
        translate([0, 0, 1]) cylinder(d = pilot, h = h);
    }
}

// four wall bosses for the front plate, at the diagonal corners, tucked into the wall
module front_bosses() {
    for (a = [45, 135, 225, 315])
        rotate([0, 0, a]) translate([base_r_corner - 8, 0, back_plate - 0.01])
            post(7, 2.4, base_depth - back_plate - 0.01);          // M3 self-tapping pilot
}

module base_usbc() {
    inner = base_flat - 2 * base_wall;
    difference() {
        union() {
            // shell: back plate + octagon wall
            difference() {
                octagon(base_flat, base_depth);
                translate([0, 0, back_plate]) octagon(inner, base_depth);
            }

            // four perfboard posts, inset 6 mm from the board corners, M2.5 pilot
            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx * (board_x/2 - 6), sy * (board_y/2 - 6), back_plate - 0.01])
                    post(6, 2.1, post_h + 0.01);

            front_bosses();

            // two clamp-bar posts, either side of the plug, on the back plate right at the slot
            for (sx = [-1, 1])
                translate([nano_cx + sx * 12, nano_y_bottom - 10, back_plate - 0.01])
                    post(5, 1.7, plug_axis_z - 1);                   // M2 pilot, top at plug axis
        }

        // USB-C slot through the bottom facet, centred on the Nano's centre line
        translate([nano_cx - usbc_slot_w/2, -base_flat/2 - 1, plug_axis_z - usbc_slot_h/2])
            cube([usbc_slot_w, base_wall + 2.2, usbc_slot_h]);

        // two keyholes through the back plate, slot pointing down, 70 mm apart vertically
        for (sy = [-1, 1])
            translate([key_x, sy * key_dx/2, -1])
                linear_extrude(back_plate + 2) keyhole2d();

        // cable-tie notch next to the slot (PROPOSAL)
        translate([nano_cx + usbc_slot_w/2 + 3, -base_flat/2 - 1, plug_axis_z - 1.2])
            cube([3, base_wall + 2.2, 2.4]);
    }
}

base_usbc();
