// Fixed column + sensor mount. It stays still; the rotor turns around the tube.
//
// What it does (z = 0 is the foot underside, which rests on the MT6701 board's top face):
//   - the tube (OD 5.5, ID 4.0) goes up through the plate hole and the motor bore to the display carrier
//   - the foot is a disc under the front plate, clamped to the motor by three M1.6 screws (heads in counterbores)
//   - the MT6701 board is screwed to the underside, chip on the axis, sens_gap below the magnet boss (see params.scad)
//   - the display wires come down the tube and leave sideways in a groove over the chip, toward -x
//
// Board orientation (design frame): board centred on the axis, header pads on the +y edge, solder the wires on the BACK, no header.
// Print: foot on the bed, tube upright. The groove and reliefs are open to the bed, so no supports.
include <params.scad>

foot_d      = 29;
col_len     = col_top_z - (col_foot_z + foot_t);       // derived from the z stack in params.scad
groove_h    = chip_h + wire_layer + 0.1;               // height of the wire groove / chip pocket above the board
groove_w    = 6.2;
relief_d    = 0.9;                                     // board components (R1, R2, C1 are about 0.6-0.8 mm) stay under this
boss_sens_d = 4.6;                                     // contact bosses around the two M2 screws
cb_d        = 3.6;                                     // counterbore for the M1.6 screw heads
cb_h        = 1.3;
echo(str("column OD ", col_od, " ID ", col_id, "  foot ", foot_t, " thick, roof over the groove ", foot_t - groove_h, "  sensor gap ", sens_gap));
assert(foot_t - groove_h >= 0.7, "the roof over the wire groove is too thin");

module column() {
    difference() {
        union() {
            cylinder(d = foot_d, h = foot_t);                       // foot
            cylinder(d = col_od, h = foot_t + col_len);             // tube (no root fillet: the magnet boss sits right above the foot)
        }
        // wire channel through the whole column, into the groove
        translate([0, 0, -1]) cylinder(d = col_id, h = foot_t + col_len + 2);
        // groove + chip pocket on the underside: from past the chip (+x) out through the foot edge (-x)
        translate([-foot_d / 2 - 1, -groove_w / 2, -1]) cube([foot_d / 2 + 1 + mt_chip_x / 2 + 0.6, groove_w, groove_h + 1]);
        // shallow relief over the board, leaving three contact points: two screw bosses (+y side) and one pad (-y edge)
        difference() {
            translate([-(mt_board + 0.4) / 2, -(mt_board + 0.4) / 2, -1]) cube([mt_board + 0.4, mt_board + 0.4, relief_d + 1]);
            for (sx = [-1, 1]) translate([sx * mt_hole_pitch / 2, mt_hole_pitch / 2, -2]) cylinder(d = boss_sens_d, h = relief_d + 2);
            translate([0, -(mt_board / 2 - 1.5), -2]) cylinder(d = 4, h = relief_d + 2);
        }
        // two M2 self-tapping pilot holes at the +y board holes (the -y holes are too close to the motor screws)
        for (sx = [-1, 1]) translate([sx * mt_hole_pitch / 2, mt_hole_pitch / 2, -1]) cylinder(d = 1.7, h = 1 + 2.7, $fn = 32);
        // motor screws: TIGHT hole (1.8 for M1.6) so the foot locates on the motor, plus a counterbore for the head
        for (i = [0 : 2])
            rotate([0, 0, i * 120 + 90]) translate([motor_hole_pcd / 2, 0, 0]) {
                translate([0, 0, -1]) cylinder(d = 1.8, h = foot_t + 2, $fn = 32);
                translate([0, 0, -1]) cylinder(d = cb_d, h = cb_h + 1, $fn = 32);
            }
    }
}

column();
