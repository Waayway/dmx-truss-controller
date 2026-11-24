// Clamp bar: a printed bridge over the USB-C plug body, held by two M2 screws.
// A pull on the supply cable then goes into the housing, not into the Nano's USB-C solder joints.
include <params.scad>

bar_len   = 30;     // PROPOSAL, spans the two M2 posts (24 apart)
bar_w     = 7;
bar_t     = 3;
plug_w    = 13.0;   // widest real plug seen (EE.SE), spec 12.35
plug_h    = 7.4;    // tallest real plug seen, spec 6.5

module clamp_bar() {
    post_dx = 24;
    difference() {
        union() {
            // flat bar
            translate([-bar_len/2, -bar_w/2, 0]) cube([bar_len, bar_w, bar_t]);
            // saddle that presses on the plug: a rounded pad
            translate([0, 0, -1.2]) cube([plug_w - 1, bar_w, 2.4], center = true);
        }
        // M2 clearance holes
        for (sx = [-1, 1]) translate([sx * post_dx/2, 0, -2]) cylinder(d = 2.4, h = 10, $fn = 32);
        // soft landing: cut the underside slightly concave so the plug body is held by two lines
        translate([0, 0, -plug_h/2 - 1.5]) rotate([90, 0, 0]) cylinder(d = plug_w + 1, h = bar_w + 2, center = true, $fn = 64);
    }
}

clamp_bar();
