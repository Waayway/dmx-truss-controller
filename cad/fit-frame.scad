// Fit-test frame (prints in minutes, ONE connected piece): the base wall at one size, the USB-C jack hole, a ridge along the cable centreline,
// outlines for the stiff jack end, the stiff plug end, and the three PERFBOARD pieces (Nano, MAX485, TMC6300), an XLR hole ring on the top wall.
// Thin low ribs join everything to the wall, so it is one solid. Lay the REAL jack, cable, boards and modules on it and see whether it fits.
// Numbers come from scripts/fit-frames.mjs (cable: lib-cable.mjs). The asserts stop the render if a piece leaves the octagon.
//   node scripts/fit-frames.mjs     builds both frames into cad/stl/fit/
size   = 170;     // across flats of the base being tested (mm)
phi    = 90;      // cable turn in degrees
jack_x = -20;     // jack centre along the bottom wall
a_str  = 42;      // straight run from the end of the jack's stiff strain relief to the start of the bend
flex   = 72;      // length of the flexible part used for the layout (mm); the cable you measure may differ
side   = 1;       // +1: the cable bends toward +x
r_bend = 12;      // cable centreline bend radius
// perfboard pieces (centre, rotation): MAX485 rot 0 = long side along y, 90 = along x; TMC6300 rot 0 = long side along x, 90 = along y
mx_cx = 0;  mx_cy = 48;  mx_rot = 90;
tm_cx = 0;  tm_cy = -21; tm_rot = 90;
wall_t = 2.5;     // base_wall
h      = 3;       // wall height
stiff  = 54;      // usbj_stiff: jack flange face to the end of the strain relief
plug_len = 30;  plug_w = 13;       // stiff plug end beyond the Nano's port edge, its width
nano_l = 43.18 + 3;  nano_w = 17.78 + 2.2;   // the Nano's perfboard piece (lib.scad pieceA)
mx_w = 14.1 + 3;  mx_l = 43.9 + 3;           // MAX485 piece
tm_l = 20.32 + 3; tm_w = 15.24 + 3;          // TMC6300 piece
ridge  = 1.4;     // width of the printed outlines and the cable line
ridge_h = 1.8;    // height of outlines and ridge
rib_w  = 2.4;  rib_h = 0.8;                  // connecting ribs: low and wide, so they do not read as boundaries
xlr_d  = 24.3;                               // XLR hole, centred on the top wall

function oct_r(a) = a / 2 / cos(22.5);
module octagon2d(a) { rotate(22.5) circle(r = oct_r(a), $fn = 8); }

yb  = -size / 2 + stiff;                                   // end of the stiff jack end
b   = flex - a_str - r_bend * phi * PI / 180;              // straight run after the bend
c   = [jack_x + side * r_bend, yb + a_str];                // bend centre
hd  = [side * sin(phi), cos(phi)];                         // unit direction after the bend
nrm = [-hd[1], hd[0]];
function arc_pt(t) = [c[0] - side * r_bend * cos(t), c[1] + r_bend * sin(t)];
p1 = arc_pt(phi);
p2 = [p1[0] + hd[0] * b, p1[1] + hd[1] * b];                // end of the plain cable = start of the plug
function box(p, len, w, from) = let (a0 = [p[0] + hd[0] * from, p[1] + hd[1] * from], b0 = [a0[0] + hd[0] * len, a0[1] + hd[1] * len])
    [[a0[0] + nrm[0] * w / 2, a0[1] + nrm[1] * w / 2], [b0[0] + nrm[0] * w / 2, b0[1] + nrm[1] * w / 2], [b0[0] - nrm[0] * w / 2, b0[1] - nrm[1] * w / 2], [a0[0] - nrm[0] * w / 2, a0[1] - nrm[1] * w / 2]];
plug_pts = box(p2, plug_len, plug_w, 0);
nano_pts = box(p2, nano_l, nano_w, plug_len);
function rect_pts(cx, cy, w, l) = [[cx - w / 2, cy - l / 2], [cx + w / 2, cy - l / 2], [cx + w / 2, cy + l / 2], [cx - w / 2, cy + l / 2]];
mx_pts = mx_rot == 0 ? rect_pts(mx_cx, mx_cy, mx_w, mx_l) : rect_pts(mx_cx, mx_cy, mx_l, mx_w);
tm_pts = tm_rot == 0 ? rect_pts(tm_cx, tm_cy, tm_l, tm_w) : rect_pts(tm_cx, tm_cy, tm_w, tm_l);

// ---- self-check: everything inside the octagon with 2.5 mm to the wall ----
function in_oct(p, extra) = let (hh = size / 2 - wall_t - extra) abs(p[0]) <= hh && abs(p[1]) <= hh && abs(p[0]) + abs(p[1]) <= hh * sqrt(2);
assert(b >= 3, str("the cable is too short for this bend: straight run after the bend would be ", b, " mm"));
assert(len([for (p = concat(plug_pts, nano_pts, mx_pts, tm_pts)) if (!in_oct(p, 2.4)) 1]) == 0, "a board piece, the plug or the Nano piece leaves the octagon");
assert(len([for (t = [0 : 5 : phi]) if (!in_oct(arc_pt(t), 5.3)) 1]) == 0, "the cable bend touches the wall");
assert(in_oct(p2, 5.3), "the cable end is too close to the wall");
echo(str("size ", size, "  turn ", phi, " deg  jack x=", jack_x, "  straight a=", a_str, "  b=", b, "  Nano port edge at (", p2[0] + hd[0] * plug_len, ", ", p2[1] + hd[1] * plug_len, ")"));

module outline(pts) { difference() { offset(delta = ridge / 2) polygon(pts); offset(delta = -ridge / 2) polygon(pts); } }
// a low rib from a point out through the octagon wall (away from the centre), clipped to the ring
module rib_to_wall(p) {
    d = p / norm(p);
    intersection() {
        octagon2d(size - wall_t);
        hull() { translate(p) circle(d = rib_w, $fn = 12); translate(p + d * size) circle(d = rib_w, $fn = 12); }
    }
}
function centre(pts) = [for (i = [0 : 1]) (pts[0][i] + pts[1][i] + pts[2][i] + pts[3][i]) / 4];

// ---- the ring (3 mm) ----
linear_extrude(h) difference() { octagon2d(size); octagon2d(size - 2 * wall_t); }
// the jack hole and the XLR hole: rings round a 24.3 mm hole, clipped to the octagon so nothing sticks out of the wall
linear_extrude(h) intersection() {
    octagon2d(size);
    union() {
        translate([jack_x, -size / 2 + 2]) difference() { circle(d = 24.3 + 4, $fn = 64); circle(d = 24.3, $fn = 64); }
        translate([0, size / 2 - 2]) difference() { circle(d = xlr_d + 4, $fn = 64); circle(d = xlr_d, $fn = 64); }
    }
}
// the jack axis: a rib from the wall up to the end of the strain relief, so the cable ridge is joined to the wall
linear_extrude(rib_h) translate([jack_x - rib_w / 2, -size / 2]) square([rib_w, stiff]);
// the stiff jack end (14 mm strain relief) as an outline
linear_extrude(ridge_h) outline([[jack_x - 7, -size / 2 + 29.4], [jack_x + 7, -size / 2 + 29.4], [jack_x + 7, yb], [jack_x - 7, yb]]);
// cable centreline ridge
linear_extrude(ridge_h) {
    translate([jack_x - ridge / 2, yb]) square([ridge, a_str + 0.01]);
    for (t = [0 : 3 : phi - 1]) hull() { translate(arc_pt(t)) circle(d = ridge, $fn = 10); translate(arc_pt(min(t + 3, phi))) circle(d = ridge, $fn = 10); }
    hull() { translate(p1) circle(d = ridge, $fn = 10); translate(p2) circle(d = ridge, $fn = 10); }
}
// plug and the three perfboard pieces
linear_extrude(ridge_h) { outline(plug_pts); outline(nano_pts); outline(mx_pts); outline(tm_pts); }
// low ribs: each perfboard piece to the wall (the Nano piece is joined to the cable ridge already)
linear_extrude(rib_h) { rib_to_wall(centre(mx_pts)); rib_to_wall(centre(tm_pts)); }
