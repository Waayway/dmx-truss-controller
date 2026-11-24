// Shared parameters for the DMX truss controller housing.
// All sizes in mm. "VERIFIED" = read from a datasheet/drawing, "PROPOSAL" = my design choice.
// Coordinates: z is the axis through the middle of the ring, +z towards the viewer.
// z = 0 is the wall side (back of the base).

$fn = 96;

// ---------- base (octagon) ----------
base_flat      = 90;     // across flats                                   PROPOSAL
base_depth     = 22;     // z height of the base for the FIRST TEST         PROPOSAL
base_wall      = 2.5;    // wall thickness                                 PROPOSAL
back_plate     = 2.5;    // back plate thickness                           PROPOSAL
base_r_corner  = base_flat / 2 / cos(22.5);   // circumradius of the octagon

// ---------- pedestal and ring ----------
pedestal_od    = 58;     // PROPOSAL
pedestal_h     = 18;     // PROPOSAL
ring_od        = 58;     // PROPOSAL
ring_id        = 43.0;   // PROPOSAL: carrier radius 20.65 + 0.85 mm running gap (was 41.6 = only 0.15 mm)
ring_h         = 13.2;   // PROPOSAL
ring_gap       = 0.8;    // gap between pedestal top and ring                 PROPOSAL

// ---------- motor: SparkFun ROB-20441 = OT-EM3215D2450Y1R-BEZE (datasheet p8) ----------
// Sizes below are read from the drawing. UNVERIFIED (not stated on the drawing): which face is the stator
// mounting face, which part turns (rotor cup vs hollow shaft), and the gap between rotor and stator base.
// The drawing also shows 2 x dia 2.0 holes on a dia 21.0 circle (not used here). Check on the real motor first.
motor_od       = 32.0;   // VERIFIED rotor/body diameter (32.0 +0.025)
motor_h        = 15.0;   // VERIFIED overall height (15.0 +-0.2)
motor_body_h   = 12.8;   // VERIFIED height of the rotor body without the boss
motor_boss_d   = 11.5;   // VERIFIED raised boss on top of the rotor (11.5 +-0.1)
motor_boss_h   = 2.2;    // VERIFIED (15.0 - 12.8)
motor_bore     = 5.9;    // VERIFIED hollow shaft (5.9 +0.1)
motor_hole_n   = 3;      // read from drawing: three M1.6 holes (face unverified)
motor_hole_pcd = 20.5;   // VERIFIED pitch circle (20.5 +0.1)
motor_hole_thr = 1.6;    // VERIFIED thread M1.6 x 0.35, depth 6.0
motor_poles    = 8;      // VERIFIED datasheet: 8 magnetic poles (SmartKnob firmware assumed 14)

// ---------- display: Waveshare 1.28in Touch LCD ----------
disp_od        = 38.5;   // VERIFIED (Waveshare), round PCB diameter
disp_glass     = 32.4;   // VERIFIED
disp_len       = 39.89;  // VERIFIED, module length including the connector tab

// ---------- Arduino Nano ESP32 ----------
nano_l         = 43.18;  // VERIFIED (Arduino datasheet, mechanical page)
nano_w         = 17.78;  // VERIFIED
nano_hole_dx   = 40.64;  // VERIFIED
nano_hole_dy   = 15.24;  // VERIFIED
nano_hole_d    = 1.66;   // VERIFIED (take M1.6 screws)

// ---------- perfboard ----------
board_x        = 70;     // user owns a 5 x 7 cm perfboard
board_y        = 50;
board_corner   = 4;      // corner cut so it fits the octagon                PROPOSAL

// ---------- USB-C plug (first test: supply plugs straight into the Nano) ----------
usbc_slot_w    = 16;     // PROPOSAL: spec max overmold 12.35 x 6.5, real cables up to 13.0 x 7.4
usbc_slot_h    = 10;     // PROPOSAL

// ---------- Neutrik D-size panel cut-out (XLR NC3FD-LX and USB-C NAUSBC-5G-FL alike) ----------
d_hole         = 24;     // VERIFIED (Neutrik drawing)
d_screw_dx     = 19;     // VERIFIED
d_screw_dy     = 24;     // VERIFIED
d_screw_d      = 3.2;    // VERIFIED
d_flange_w     = 26;     // VERIFIED
d_flange_h     = 31;     // VERIFIED

// ---------- wall mount ----------
key_dx         = 70;     // distance between the two keyholes                PROPOSAL
key_head       = 7;      // head hole diameter                               PROPOSAL
key_slot       = 3.5;    // slot width                                       PROPOSAL
key_slot_len   = 7;      // PROPOSAL

// ---------- fits ----------
fit            = 0.2;    // printer clearance for sliding/clamped fits (PETG, 0.4 mm nozzle)

echo(str("octagon circumradius = ", base_r_corner));

// ---------- z stack of the turning side, derived once and used by every part ----------
// z = 0 is the back of the base. Base is base_depth tall; the front plate closes it at the top.
plate_t        = 2.5;                              // front plate thickness
z_plate_top    = base_depth;                       // 22
z_motor_bot    = z_plate_top;                      // the stator sits ON the plate
z_rotor_top    = z_motor_bot + motor_body_h;       // 34.8
z_boss_top     = z_motor_bot + motor_h;            // 37.0
z_ped_bot      = z_plate_top;
z_ped_top      = z_ped_bot + pedestal_h;           // 40
z_ring_bot     = z_ped_top + ring_gap;             // 40.8
z_ring_top     = z_ring_bot + ring_h;              // 54.0
// display: glass about 1.5 mm below the ring top
glass_recess   = 1.5;                              // PROPOSAL
module_t       = 3.4;                              // pcb + lcd stack. ESTIMATE, not measured on the real module
z_module_top   = z_ring_top - glass_recess;
z_module_bot   = z_module_top - module_t;
carrier_t      = 4;                                // carrier plate thickness
pocket_h       = 2.2;                              // pocket depth for the module pcb
z_carrier_bot  = z_module_bot + pocket_h - carrier_t;   // carrier underside
z_hub_bot      = z_boss_top - motor_boss_h;        // hub rests on the rotor top face (34.8)
hub_t          = 2.4;
z_hub_top      = z_hub_bot + hub_t;
// the column must reach from its foot to the carrier underside
col_foot_z     = z_plate_top - plate_t - 3;        // foot sits under the front plate, 3 mm foot
col_top_z      = z_carrier_bot + (carrier_t - pocket_h) - 0.2;   // 0.2 mm below the pocket floor
