// Fit-test frame (prints in minutes): the base wall at one size, the USB-C jack hole, a ridge along the cable centreline, and outlines
// for the stiff jack end, the stiff plug end and the Nano's perfboard piece. Lay the REAL jack, cable and Nano on it and see whether it fits.
// Numbers come from scripts/usbc-turn.mjs. Self-check: the asserts stop the render if any corner leaves the octagon.
//   170 mm, 90 degrees:  openscad -D size=170 -D phi=90  -D jack_x=-20   -D a_str=42 -D flex=72 -o stl/fit/fit-170-90.stl  fit-frame.scad
//   140 mm, 145 degrees: openscad -D size=140 -D phi=145 -D jack_x=-13.5 -D a_str=41 -D flex=75 -o stl/fit/fit-140-145.stl fit-frame.scad
size   = 170;     // across flats of the base being tested (mm)
phi    = 90;      // cable turn in degrees
jack_x = -20;     // jack centre along the bottom wall
a_str  = 42;      // straight run from the end of the jack's stiff strain relief to the start of the bend
flex   = 72;      // length of the flexible part used for the layout (mm); the cable you measure may differ
side   = 1;       // +1: the cable bends toward +x
r_bend = 12;      // cable centreline bend radius
wall_t = 2.5;     // base_wall
h      = 3;       // frame height
stiff  = 54;      // usbj_stiff: jack flange face to the end of the strain relief
plug_len = 30;  plug_w = 13;       // stiff plug end beyond the Nano's port edge, its width
nano_l = 43.18 + 3;  nano_w = 17.78 + 2.2;   // the Nano's perfboard piece (lib.scad pieceA)
ridge  = 1.4;     // width of the printed outlines and the cable line

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

// ---- self-check: everything inside the octagon with 2.5 mm to the wall ----
function in_oct(p, extra) = let (hh = size / 2 - wall_t - extra) abs(p[0]) <= hh && abs(p[1]) <= hh && abs(p[0]) + abs(p[1]) <= hh * sqrt(2);
assert(b >= 3, str("the cable is too short for this bend: straight run after the bend would be ", b, " mm"));
assert(len([for (p = concat(plug_pts, nano_pts)) if (!in_oct(p, 2.5)) 1]) == 0, "the plug or the Nano piece leaves the octagon");
assert(len([for (t = [0 : 5 : phi]) if (!in_oct(arc_pt(t), 5.3)) 1]) == 0, "the cable bend touches the wall");
assert(in_oct(p2, 5.3), "the cable end is too close to the wall");
echo(str("size ", size, "  turn ", phi, " deg  jack x=", jack_x, "  straight a=", a_str, "  b=", b, "  Nano port edge at (", p2[0] + hd[0] * plug_len, ", ", p2[1] + hd[1] * plug_len, ")"));

module outline(pts) { difference() { offset(delta = ridge / 2) polygon(pts); offset(delta = -ridge / 2) polygon(pts); } }

// the ring
linear_extrude(h) difference() { octagon2d(size); octagon2d(size - 2 * wall_t); }
// the jack hole: a ring round a 24.3 mm hole at the bottom wall
linear_extrude(h) translate([jack_x, -size / 2 + 2]) difference() { circle(d = 24.3 + 4, $fn = 64); circle(d = 24.3, $fn = 64); }
// the stiff jack end (14 mm strain relief) as an outline
linear_extrude(h) outline([[jack_x - 7, -size / 2 + 29.4], [jack_x + 7, -size / 2 + 29.4], [jack_x + 7, yb], [jack_x - 7, yb]]);
// cable centreline ridge
linear_extrude(h + 0.8) {
    translate([jack_x - ridge / 2, yb]) square([ridge, a_str + 0.01]);
    for (t = [0 : 3 : phi - 1]) hull() { translate(arc_pt(t)) circle(d = ridge, $fn = 10); translate(arc_pt(min(t + 3, phi))) circle(d = ridge, $fn = 10); }
    hull() { translate(p1) circle(d = ridge, $fn = 10); translate(p2) circle(d = ridge, $fn = 10); }
}
// plug and Nano piece outlines
linear_extrude(h + 0.8) { outline(plug_pts); outline(nano_pts); }
