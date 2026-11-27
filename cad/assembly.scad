// Assembly: all parts in place, with a clearance report. For inspection only; print the single files.
include <params.scad>
show_ghosts = false;     // true: also show the USB-C cable, Nano, XLR and perfboard stand-ins
use <base.scad>
use <ghosts.scad>
use <front_plate.scad>
use <column.scad>
use <display_carrier.scad>
use <rotor_hub.scad>
use <ring.scad>
use <pedestal.scad>

echo(str("motor: stator bottom z=", z_motor_bot, "  rotor top z=", z_rotor_top, "  boss bottom z=", z_boss_bot, "  sensor chip top z=", z_chip_top, "  board z=", z_pcb_bot, "..", z_pcb_top));
echo(str("pedestal z=", z_ped_bot, "..", z_ped_top, "   ring z=", z_ring_bot, "..", z_ring_top, "  gap ", ring_gap));
echo(str("hub z=", z_hub_bot, "..", z_hub_top));
echo(str("display module z=", z_module_bot, "..", z_module_top, "   carrier underside z=", z_carrier_bot));
echo(str("column foot z=", col_foot_z, "  top z=", col_top_z, "  length above foot=", col_top_z - col_foot_z));
echo(str("glass recess below ring top = ", z_ring_top - z_module_top));

// --- hard checks that must hold for the proposal to be physically sane ---
assert(z_hub_top   <  z_carrier_bot + 0.01 || z_hub_top <= z_carrier_bot + 8, "hub collides with the carrier");
assert(z_carrier_bot > z_hub_top - 0.01,  "carrier underside is below the hub top: they overlap");
assert(z_ring_bot  >  z_ped_top,          "ring touches the pedestal");
assert(z_hub_top   <  z_ring_top,         "hub is above the ring");
assert(z_module_top < z_ring_top,         "display glass sticks out above the ring");
assert(z_module_top > z_ring_top - 4,     "display is recessed more than 4 mm below the ring top");
assert(col_top_z > z_carrier_bot,         "column does not reach the carrier");

module assembly() {
    color("#d9dde2") base();
    if (show_ghosts) color("#e0a030", 0.6) ghosts();
    color("#c4c7cb") translate([0, 0, z_plate_top - plate_t]) front_plate();
    color("#8a8f96") translate([0, 0, col_foot_z]) column();
    color("#c46d0d") motor();
    color("#1d6b3a") sensor_board();
    color("#b8c0c8") translate([0, 0, z_ped_bot]) pedestal();
    color("#e0a030") translate([0, 0, z_hub_bot]) rotor_hub();
    color("#3a3e44") translate([0, 0, z_ring_bot]) ring();
    color("#17191c") translate([0, 0, z_carrier_bot]) display_carrier();
}

assembly();
