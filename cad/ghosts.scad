// Clearance ghosts: render-only stand-ins for the parts that live INSIDE the base, so the layout can be checked
// numerically (clearance.scad) and viewed. Not printed.
//   - Neutrik USB-C jack with its fly-lead, laid as a U-turn (jack body, strain relief, cable, plug)
//   - Neutrik XLR jack
//   - Arduino Nano ESP32 with its header pins, perfboard strip A
include <params.scad>

module seg(a, b) { hull() { translate(a) sphere(r = cab_r, $fn = 16); translate(b) sphere(r = cab_r, $fn = 16); } }

module usbc_jack() {                       // jack body, strain relief, flange (outside the wall)
    translate([usbc_x, -base_flat / 2, jack_zc]) rotate([-90, 0, 0]) {
        cylinder(d = usbj_body_d, h = usbj_body_len);
        cylinder(d = usbj_relief_d, h = usbj_stiff);
    }
    translate([usbc_x - d_flange_along / 2, -base_flat / 2 - d_flange_t, jack_zc - d_flange_z / 2])
        cube([d_flange_along, d_flange_t, d_flange_z]);
}

module usbc_cable() {                      // leg a, half circle, leg b: centreline of the flexible part
    cy = usb_yb + cab_a;
    cx = usbc_x - cab_bend_r;
    seg([usbc_x, usb_yb, jack_zc], [usbc_x, cy, jack_zc]);
    for (t = [0 : 10 : 170])
        seg([cx + cab_bend_r * cos(t),      cy + cab_bend_r * sin(t),      jack_zc],
            [cx + cab_bend_r * cos(t + 10), cy + cab_bend_r * sin(t + 10), jack_zc]);
    seg([nano_x, cy, jack_zc], [nano_x, cy - cab_b, jack_zc]);
}

module usbc_plug() {                       // stiff plug end, from the cable end down to the Nano port
    translate([nano_x - plug_w / 2, nano_y_port, jack_zc - plug_h / 2]) cube([plug_w, plug_exposed, plug_h]);
}

module nano() {
    z0 = board_top_z + nano_hdr_h;
    translate([nano_x - nano_w / 2, nano_y_end, z0]) cube([nano_w, nano_l, nano_pcb_t]);                       // pcb
    translate([nano_x - 4.5, nano_y_port - 7.3, z0 + nano_pcb_t]) cube([9, 7.3, nano_usbc_h]);                 // USB-C receptacle
    for (sx = [-1, 1])                                                                                         // header rows
        translate([nano_x + sx * 7.62 - 1.3, nano_y_end + 1, board_top_z]) cube([2.6, nano_l - 2, nano_hdr_h]);
}

module boardA() { translate([boardA_cx - boardA_w / 2, boardA_y0, board_z]) cube([boardA_w, boardA_l, board_t]); }

module xlr_jack() {                        // on the RIGHT facet, body runs inward (-x)
    translate([base_flat / 2 - xlr_depth, xlr_along, jack_zc]) rotate([0, 90, 0]) cylinder(d = xlr_body_d, h = xlr_depth);
    translate([base_flat / 2, xlr_along - d_flange_along / 2, jack_zc - d_flange_z / 2])
        cube([d_flange_t, d_flange_along, d_flange_z]);
}

module ghosts() {
    usbc_jack(); usbc_cable(); usbc_plug(); nano(); boardA(); xlr_jack();
}

ghosts();
