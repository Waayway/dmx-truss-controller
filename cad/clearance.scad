// Clearance check between parts that TURN (hub, ring) and parts that stay FIXED
// (pedestal, column, display carrier, front plate). Every pair must have an EMPTY intersection.
// Run: openscad -D 'pair="hub-pedestal"' -o /dev/null clearance.scad   (see Makefile target `check`)
include <params.scad>
use <front_plate.scad>
use <column.scad>
use <display_carrier.scad>
use <rotor_hub.scad>
use <ring.scad>
use <pedestal.scad>

pair = "hub-pedestal";

module turning(n) {
    if (n == "hub")  translate([0, 0, z_hub_bot])  rotor_hub();
    if (n == "ring") translate([0, 0, z_ring_bot]) ring();
}
module fixedp(n) {
    if (n == "pedestal") translate([0, 0, z_ped_bot]) pedestal();
    if (n == "column")   translate([0, 0, col_foot_z]) column();
    if (n == "carrier")  translate([0, 0, z_carrier_bot]) display_carrier();
    if (n == "plate")    translate([0, 0, z_plate_top - plate_t]) front_plate();
}

// pair string is "<turning>-<fixed>"
t = pair == "hub-pedestal" || pair == "hub-column" || pair == "hub-carrier" || pair == "hub-plate" ? "hub" : "ring";
f = pair == "hub-pedestal" || pair == "ring-pedestal" ? "pedestal"
  : pair == "hub-column"   || pair == "ring-column"   ? "column"
  : pair == "hub-carrier"  || pair == "ring-carrier"  ? "carrier" : "plate";

intersection() { turning(t); fixedp(f); }
