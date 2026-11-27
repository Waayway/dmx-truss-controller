// Clearance ghosts: render-only stand-ins for the parts that live INSIDE the base, so the layout can be checked
// numerically (clearance.scad) and viewed. Not printed.
//   - Neutrik USB-C jack with its fly-lead, laid with one 90 degree bend (jack body, strain relief, cable, plug)
//   - Neutrik XLR jack
//   - Arduino Nano ESP32 with its header pins, perfboard strip A
include <params.scad>
include <lib.scad>

module seg(a, b) { hull() { translate(a) sphere(r = cab_r, $fn = 16); translate(b) sphere(r = cab_r, $fn = 16); } }

module usbc_jack() {                       // jack body, strain relief, flange (outside the wall)
    translate([usbc_x, -base_flat / 2, jack_zc]) rotate([-90, 0, 0]) {
        cylinder(d = usbj_body_d, h = usbj_body_len);
        cylinder(d = usbj_relief_d, h = usbj_stiff);
    }
    translate([usbc_x - d_flange_along / 2, -base_flat / 2 - d_flange_t, jack_zc - d_flange_z / 2])
        cube([d_flange_along, d_flange_t, d_flange_z]);
}

module usbc_cable() {                      // leg a, quarter circle, leg b: centreline of the flexible part
    cy = usb_yb + cab_a;
    cx = usbc_x + cab_dir * cab_bend_r;
    seg([usbc_x, usb_yb, jack_zc], [usbc_x, cy, jack_zc]);
    for (t = [0 : 10 : 80])
        seg([cx - cab_dir * cab_bend_r * cos(t),      cy + cab_bend_r * sin(t),      jack_zc],
            [cx - cab_dir * cab_bend_r * cos(t + 10), cy + cab_bend_r * sin(t + 10), jack_zc]);
    seg([cx, cab_row, jack_zc], [cx + cab_dir * cab_b, cab_row, jack_zc]);
}

module usbc_plug() {                       // stiff plug end, from the end of the plain cable to the Nano port
    x0 = min(nano_port_x, nano_port_x - cab_dir * plug_exposed);
    translate([x0, cab_row - plug_w / 2, jack_zc - plug_h / 2]) cube([plug_exposed, plug_w, plug_h]);
}

module nano() {                            // lies along x, USB-C port at nano_port_x
    z0 = board_top_z + nano_hdr_h;
    x0 = min(nano_port_x, nano_far_x);
    translate([x0, cab_row - nano_w / 2, z0]) cube([nano_l, nano_w, nano_pcb_t]);                                 // pcb
    translate([cab_dir > 0 ? nano_port_x : nano_port_x - 7.3, cab_row - 4.5, z0 + nano_pcb_t]) cube([7.3, 9, nano_usbc_h]);   // USB-C receptacle
    for (sy = [-1, 1])                                                                                            // header rows
        translate([x0 + 1, cab_row + sy * 7.62 - 1.3, board_top_z]) cube([nano_l - 2, 2.6, nano_hdr_h]);
}

module piece(p) { translate([0, 0, board_z]) linear_extrude(board_t) board2d(p[0], p[1], p[2], p[3], p[4]); }
module boardA() { piece(pieceA()); }
module boardB() { piece(pieceB1()); piece(pieceB2()); }

// modules stand mod_h (13 mm, user: with pins soldered in) above the board top
module max485() { w = max485_rot == 0 ? max485_w : max485_l; l = max485_rot == 0 ? max485_l : max485_w; translate([max485_cx - w / 2, max485_cy - l / 2, board_top_z]) cube([w, l, mod_h]); }
module tmc6300() { w = tmc_rot == 0 ? tmc_l : tmc_w; l = tmc_rot == 0 ? tmc_w : tmc_l; translate([tmc_cx - w / 2, tmc_cy - l / 2, board_top_z]) cube([w, l, mod_h]); }

module xlr_jack() {                        // on the XLR facet (xlr_angle), body runs inward
    on_facet(xlr_angle, xlr_along, jack_zc) {
        rotate([-90, 0, 0]) cylinder(d = xlr_body_d, h = xlr_depth);
        translate([-d_flange_along / 2, -d_flange_t, -d_flange_z / 2]) cube([d_flange_along, d_flange_t, d_flange_z]);
    }
}

// MT6701 board under the motor, as designed in column.scad: centred on the axis, header pads on the +y edge.
// Small parts in the design frame (the photo frame turned 90 degrees clockwise): R1, R2 on the +x side, C1 at -x. Keepouts, not exact.
module sensor_board() {
    translate([0, 0, z_pcb_bot]) {
        difference() {
            translate([-mt_board / 2, -mt_board / 2, 0]) cube([mt_board, mt_board, mt_pcb_t]);
            for (sx = [-1, 1], sy = [-1, 1]) translate([sx * mt_hole_pitch / 2, sy * mt_hole_pitch / 2, -1]) cylinder(d = mt_hole_d, h = mt_pcb_t + 2, $fn = 24);
        }
        translate([-mt_chip_x / 2, -mt_chip_y / 2, mt_pcb_t]) cube([mt_chip_x, mt_chip_y, chip_h]);
        for (c = [[6, 1.9], [6, -0.7], [-5.5, 1.8]]) translate([c[0] - 1.2, c[1] - 1.2, mt_pcb_t]) cube([2.4, 2.4, 0.8]);
    }
}

// the motor: stator face DOWN on the plate, magnet boss below it, flat rotor top above
module motor() {
    difference() {
        union() {
            translate([0, 0, z_motor_bot]) cylinder(d = motor_od, h = motor_body_h);
            translate([0, 0, z_boss_bot]) cylinder(d = motor_boss_d, h = boss_proud + 0.01);
        }
        translate([0, 0, z_boss_bot - 1]) cylinder(d = motor_bore, h = motor_h + 2);
    }
}

module ghosts() {
    usbc_jack(); usbc_cable(); usbc_plug(); nano(); boardA(); boardB(); max485(); tmc6300(); xlr_jack(); sensor_board();
}

ghosts();
