// Fit-test frame (prints in minutes): the base wall at one size, the USB-C jack position, and a guide for the cable.
// The octagon, jack and cable run use the same formulas as cad/base.scad and cad/params.scad.
//   openscad -D 'size=140' -D 'bend=135' -o stl/fit/fit-140-135.stl fit-frame.scad
//   openscad -D 'size=115' -D 'bend=180' -o stl/fit/fit-115-180.stl fit-frame.scad
size   = 140;     // across flats of the base being tested (mm)
bend   = 135;     // cable turn in degrees (90, 135, 180)
wall_t = 2.5;     // base_wall in params.scad
h      = 3;       // frame height (thin)
jack_x = -22 * size / 115 * 0 + -22;   // jack centre on the bottom wall; kept at the solver's value
cab_r  = 2.3;     // cable radius
r_bend = 12;      // cable_bend_r
stiff  = 54;      // usbj_stiff: flange face to the end of the strain relief
flex   = 72;      // cab_flex_design
guide  = 2.4;     // width of the guide ridge (a bit wider than the 4.6 mm cable would need, so it reads on the plate)

function oct_r(a) = a / 2 / cos(22.5);
module octagon2d(a) { rotate(22.5) circle(r = oct_r(a), $fn = 8); }

// Numbers the frame prints as a check
yb   = -size / 2 + stiff;                 // end of the stiff jack end
a    = 46;                                // straight run before the bend (cab_a)
phi  = bend;                              // degrees
b    = flex - a - r_bend * phi * PI / 180;  // straight run after the bend
echo(str("size ", size, " bend ", bend, " deg:  jack x=", jack_x, "  straight a=", a, "  bend r=", r_bend, "  straight b=", b, " (needs >= 3)"));

// centreline points: straight up, then the bend, then straight on
n = 90;
c   = [jack_x + r_bend, yb + a];
arc = [for (i = [0 : n]) let (t = 180 - phi * i / n) [c[0] + r_bend * cos(t), c[1] + r_bend * sin(t)]];
p1  = arc[n];
dir = [cos(180 - phi) * 0 + sin(phi), cos(phi)];        // unit direction after the bend (plate frame)
straight_end = [p1[0] + dir[0] * b, p1[1] + dir[1] * b];

module guide2d() {
    translate([jack_x - guide / 2, yb]) square([guide, a + 0.01]);
    for (i = [0 : n - 1]) hull() { translate(arc[i]) circle(d = guide, $fn = 12); translate(arc[i + 1]) circle(d = guide, $fn = 12); }
    hull() { translate(p1) circle(d = guide, $fn = 12); translate(straight_end) circle(d = guide, $fn = 12); }
}

// the ring
linear_extrude(h) difference() { octagon2d(size); octagon2d(size - 2 * wall_t); }
// the jack hole: 24.3 mm for the 23 mm body (a ring round it so the frame stays one piece)
linear_extrude(h) translate([jack_x, -size / 2 + 2]) difference() { circle(d = 24.3 + 4, $fn = 64); circle(d = 24.3, $fn = 64); }
// the guide
linear_extrude(h + 1) guide2d();
