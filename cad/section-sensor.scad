// Close-up cut-away of the sensor mount (y >= 0 half, z 22..37), for inspection only.
use <assembly.scad>
intersection() {
    difference() {
        assembly();
        translate([-200, -200, -10]) cube([400, 200, 100]);
    }
    translate([-17, 0, 22]) cube([34, 20, 15]);
}
