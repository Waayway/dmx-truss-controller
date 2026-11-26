// Clearance check between two named parts; the intersection must be EMPTY.
// Run via scripts/check.sh:  openscad -D 'a="hub"' -D 'b="pedestal"' -o out.stl clearance.scad
include <params.scad>
use <base.scad>
use <front_plate.scad>
use <column.scad>
use <display_carrier.scad>
use <rotor_hub.scad>
use <ring.scad>
use <pedestal.scad>
use <ghosts.scad>

a = "hub";
b = "pedestal";

module part(n) {
    if (n == "hub")      translate([0, 0, z_hub_bot])  rotor_hub();
    if (n == "ring")     translate([0, 0, z_ring_bot]) ring();
    if (n == "pedestal") translate([0, 0, z_ped_bot])  pedestal();
    if (n == "column")   translate([0, 0, col_foot_z]) column();
    if (n == "carrier")  translate([0, 0, z_carrier_bot]) display_carrier();
    if (n == "plate")    translate([0, 0, z_plate_top - plate_t]) front_plate();
    if (n == "base")     base();
    if (n == "ghost")    ghosts();
    if (n == "g_jack")   usbc_jack();
    if (n == "g_cable")  usbc_cable();
    if (n == "g_plug")   usbc_plug();
    if (n == "g_nano")   nano();
    if (n == "g_board")  boardA();
    if (n == "g_xlr")    xlr_jack();
}

intersection() { part(a); part(b); }
