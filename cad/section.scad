// Cut-away of the assembly along the axis (keeps y >= 0), for inspection only.
use <assembly.scad>
difference() {
    assembly();
    translate([-200, -200, -10]) cube([400, 200, 100]);
}
