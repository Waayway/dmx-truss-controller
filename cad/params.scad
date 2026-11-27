// Shared parameters for the DMX truss controller housing.
// All sizes in mm. "VERIFIED" = read from a datasheet/drawing, "USER" = measured by the user,
// "PHOTO" = scaled from the user's photo (about +-3 mm), "PROPOSAL"/"ESTIMATE" = my design choice, not measured.
// Coordinates: z is the axis through the middle of the ring, +z towards the viewer.
// z = 0 is the wall side (back of the base). Looking into the open base: +x right, +y up.

$fn = 96;

// ---------- base (octagon) ----------
base_flat      = 115;    // across flats. 110 is the minimum that fits the USB-C fly-lead (see usbc-layout notes); PROPOSAL
base_depth     = 32;     // z height. Neutrik D flange is 26 tall, plus room for the plate and floor   PROPOSAL
base_wall      = 2.5;    // wall thickness                                 PROPOSAL
back_plate     = 2.5;    // back plate thickness                           PROPOSAL
base_r_corner  = base_flat / 2 / cos(22.5);   // circumradius of the octagon
jack_zc        = base_depth / 2;              // height of both D-size jack axes above the wall
// front-plate bosses sit in four CORNERS (vertices) of the inner octagon, the four that stay clear of both jacks.
// The flats are on the axes, so the vertices are at 22.5 + 45k degrees; 67.5 + 90k keeps clear of the jack pads.
boss_angles    = [67.5, 157.5, 247.5, 337.5];
boss_r         = (base_flat / 2 - base_wall) / cos(22.5) - 4.5;   // centre 4.5 mm in from the inner vertex, so the boss merges with both walls

// ---------- pedestal and ring ----------
pedestal_od    = 58;     // PROPOSAL
pedestal_h     = 18;     // PROPOSAL
ring_od        = 58;     // PROPOSAL
ring_id        = 43.0;   // PROPOSAL: carrier radius 20.65 + 0.85 mm running gap
ring_h         = 13.2;   // PROPOSAL
ring_gap       = 0.8;    // gap between pedestal top and ring              PROPOSAL

// ---------- motor: SparkFun ROB-20441 = OT-EM3215D2450Y1R-BEZE (datasheet p8) ----------
// Read from the drawing. UNVERIFIED (not stated): which face is the stator mounting face, which part turns,
// and the gap between rotor and stator base. The user confirmed the sizes below and that the 3-wire lead
// leaves between two of the three screw holes.
motor_od       = 32.0;   // VERIFIED rotor/body diameter
motor_h        = 15.0;   // VERIFIED overall height
motor_body_h   = 12.8;   // VERIFIED height of the rotor body without the boss
motor_boss_d   = 11.5;   // VERIFIED raised boss = the diametric ring magnet. It is on the STATOR face (see boss_proud below), NOT on top of the rotor
motor_boss_h   = 2.2;    // VERIFIED (15.0 - 12.8)
motor_bore     = 5.9;    // VERIFIED hollow shaft
motor_hole_n   = 3;      // three M1.6 holes
motor_hole_pcd = 20.5;   // VERIFIED pitch circle
motor_hole_thr = 1.6;    // VERIFIED thread M1.6 x 0.35, depth 6.0
motor_poles    = 8;      // VERIFIED datasheet: 8 magnetic poles (SmartKnob firmware assumed 14)

// ---------- fixed column through the motor bore ----------
// USER TEST 2026-11-24 (five printed tubes OD 5.3 to 5.7 pushed into the real motor): 5.3, 5.4, 5.5 and 5.6 fit easily and spin
// smoothly, 5.7 binds. The thickest smooth one is 5.6; the column is much longer than the test tubes, so it takes 0.1 mm off that.
col_od         = 5.5;
col_wall       = 0.75;   // PROPOSAL: thin; the user expects a tall 0.8 mm tube to snap when flexed, so keep the column short and held at both ends
col_id         = col_od - 2 * col_wall;     // 4.0 for wires; NOT yet tested with the real wires

// ---------- motor orientation and the sensor under it ----------
// Orientation (2026-11-27): SmartKnob's photos of the SAME motor (SparkFun 20441, doc/img/motors in github.com/scottbez1/smartknob) show the
// Ø11.5 ring magnet on the SAME face as the three M1.6 holes and the lead slot. That face is mounted DOWN on the plate; the rotor's other
// face is flat with the bore bushing flush, and the hub goes on that one. The earlier CAD had the boss on top: that was wrong.
// USER TO CONFIRM on the real motor: boss, three screw holes and lead slot on one face, the other face flat.
boss_proud     = 2.2;    // how far the magnet boss sticks out below the screw face. DATASHEET: 15.0 total - 12.8 body. UNVERIFIED on the part: measure it.
// MT6701 datasheet (Rev 1.5, magntek): air gap magnet to chip surface 0.5 min / 1.0 typ / 2.0 MAX mm; sensing centre within 0.3 mm of the magnet axis.
sens_gap       = 1.7;    // PROPOSAL: boss bottom to chip top. Leaves 0.3 mm to the 2.0 mm maximum.
chip_h         = 1.75;   // SOP-8 height above the board, datasheet maximum
mt_pcb_t       = 1.6;    // ESTIMATE (not measured)
mt_chip_x      = 6.0;    // SOP-8 across the leads (datasheet E = 5.8..6.2)
mt_chip_y      = 4.9;    // SOP-8 body length (D = 4.7..5.1)
wire_layer     = 0.5;    // the display wires lie flat in a groove over the chip: 30 AWG wire-wrap is about 0.5 mm
hub_rim_depth  = 0.8;    // the rotor hub straddles the rotor's top edge by this much

// ---------- display: Waveshare 1.28in Touch LCD ----------
disp_od        = 38.5;   // VERIFIED (Waveshare 2D drawing: lens OD 38.51)
disp_glass     = 32.4;   // VERIFIED
disp_len       = 39.89;  // VERIFIED, module length including the connector tab
module_t       = 3.575;  // VERIFIED: Waveshare 2D drawing total thickness (+-0.15). TP 1.85 + LCM 1.55 + PCB 1.0

// ---------- Arduino Nano ESP32 ----------
nano_l         = 43.18;  // VERIFIED (Arduino datasheet)
nano_w         = 17.78;  // VERIFIED
nano_pcb_t     = 1.0;    // ESTIMATE
nano_usbc_h    = 3.2;    // ESTIMATE, USB-C receptacle height above the pcb
nano_hdr_h     = 2.5;    // ESTIMATE: header plastic spacer under the Nano. UNRESOLVED: user says the Nano is about 15 mm tall
                         // with headers, unclear whether that includes the pins below the spacer. Change here if it differs.

// ---------- perfboard (user owns one 5 x 7 cm, 1.6 mm; cut into strips) ----------
board_t        = 1.6;    // typical
nano_port_axis = nano_hdr_h + nano_pcb_t + nano_usbc_h / 2;     // plug axis above the perfboard top (5.1)

// ---------- Neutrik D-size panel jacks (XLR NC3FD-LX and USB-C NAUSBC-5G-FL10: same mounting, user confirmed) ----------
d_hole         = 24;     // VERIFIED (Neutrik drawing, +-0.1)
d_screw_along  = 24;     // VERIFIED: screw spacing along the 31 mm flange side (we run it ALONG the facet)
d_screw_z      = 19;     // VERIFIED: screw spacing across, runs UP/DOWN
d_screw_d      = 3.2;    // VERIFIED
d_flange_along = 31;     // VERIFIED flange side along the facet
d_flange_z     = 26;     // VERIFIED flange side up/down
d_flange_t     = 3;      // ESTIMATE flange thickness (outside the wall, not critical)
nut_af         = 5.7;    // M3 nut trap across flats (nut 5.5) PROPOSAL; jacks may bring their own hardware, not checked
nut_t          = 2.6;    // M3 nut thickness 2.4 + 0.2
pad_t          = 2.5;    // extra wall thickness around each jack hole, inside, for the nut traps
pad_w          = 34;
pad_h          = 26.5;   // 2.75 .. 29.25 at the jack axis: stays under the front plate (it starts at base_depth - 2.5)

xlr_depth      = 29;     // USER: 24 mm plus about 5 mm of solder cups behind the panel
xlr_body_d     = 23.5;   // ESTIMATE for the clearance ghost (hole is 24.3)
xlr_along      = 0;      // XLR sits on the right facet, centred

// ---------- Neutrik USB-C fly-lead NAUSBC-5G-FL10 (flange front face is the reference) ----------
usbj_body_len  = 29.4;   // VERIFIED drawing: rigid body behind the flange (+-0.3)
usbj_body_d    = 23;     // PHOTO: ghost diameter, must stay under the 24.3 hole
usbj_relief_d  = 14;     // PHOTO: strain relief on the jack end
usbj_stiff     = 54;     // PHOTO (user: about 50): flange front face to the end of the strain relief
cab_flex       = 75;     // PHOTO / USER: flexible cable between the two strain reliefs
cab_r          = 2.3;    // PHOTO: cable radius
cab_bend_r     = 12;     // ESTIMATE: bend radius of the cable centreline (user: it ripples if bent tighter)
plug_exposed   = 30;     // PHOTO: plug end beyond the Nano port edge (overmold + strain relief), 37 incl. 7 mm inside the port
plug_w         = 13;     // real USB-C overmolds measured up to 13.0 x 7.4
plug_h         = 7.4;
usbc_x         = 4;      // position of the USB-C jack along the BOTTOM facet (scripts/place-modules.mjs: left enough to leave a strip for the MAX485)  PROPOSAL
nano_pull_in   = 12;     // how far the Nano's antenna end is held off the wall  PROPOSAL (layout solver)
wall_margin    = 1.5;

// derived cable layout (U-turn, Nano alongside the jack body, plug pointing back at the wall)
usb_yb         = -base_flat / 2 + usbj_stiff;                          // end of the jack's strain relief
nano_y_end     = -base_flat / 2 + base_wall + wall_margin + nano_pull_in;   // Nano antenna end
nano_y_port    = nano_y_end + nano_l;                                  // edge of the Nano's USB-C port
cab_y_end      = nano_y_port + plug_exposed;                           // where plain cable meets the plug
cab_amb        = cab_y_end - usb_yb;                                   // leg a minus leg b
cab_apb        = cab_flex - PI * cab_bend_r;                           // leg a plus leg b
cab_a          = (cab_amb + cab_apb) / 2;                              // straight leg going deeper
cab_b          = (cab_apb - cab_amb) / 2;                              // straight leg coming back
nano_x         = usbc_x - 2 * cab_bend_r;                              // Nano is to the LEFT of the jack
assert(cab_b >= 0, "cable is too short for this layout: reduce nano_pull_in or the bend radius");

// perfboard pieces, all cut from the user's 5 x 7 cm board; each rests on a rim frame (no screws, hot glue)
board_rim      = 1.2;    // width of the rim frame under the board edge; pin pads stay inside it
board_pad      = 1.5;    // board outline = module outline + this on every side
board_chamfer  = 4;      // saw off the corners that point at the diagonal walls
board_top_z    = jack_zc - nano_port_axis;                             // so the Nano's port axis lines up with the jack axis
board_z        = board_top_z - board_t;                                // underside of every perfboard piece
post_h         = board_z - back_plate;                                 // rim frame height
mod_h          = 13;     // USER: height of a module with its pins soldered into the perfboard, measured from the board top
// piece A carries the Nano
boardA_w       = nano_w + 2.2;
boardA_l       = nano_l + 3;
boardA_cx      = nano_x;
boardA_y0      = nano_y_end - 1.5;
// piece B1 carries the MAX485, standing vertically beside the cable leg (scripts/place-modules.mjs)
max485_cx      = 16.5;
max485_cy      = 21.5;
// piece B2 carries the TMC6300, lower right, long side along x
tmc_cx         = 29.5;
tmc_cy         = -22.5;

// ---------- TMC6300 board (SparkFun dimensions.pdf, user confirmed): NO mounting holes; soldered with headers into the perfboard ----------
tmc_l          = 20.32;  // 0.80 in
tmc_w          = 15.24;  // 0.60 in
tmc_row_gap    = 12.7;   // 0.50 in between the two pin columns, 2.54 mm pitch, 8 pins per column

// ---------- MAX485 module (user confirmed 44 x 14; 13 mm tall with pins in the perfboard) ----------
max485_l       = 43.9;
max485_w       = 14.1;

// ---------- MT6701 breakout (measured from the user's two photos, scale = 5-pin header pitch 2.54 mm, cross-checked with the SOP8 body) ----------
mt_board       = 22;     // board is 21.8 x 22.0 mm, chip dead centre
mt_hole_pitch  = 16.5;   // four holes, about 2.1 mm, on a 16.5 mm square
mt_hole_d      = 2.1;
// pins along one edge, 2.54 pitch: VDD, GND, Analog/PWM, SCL, SDA
// magnet that came with the sensor: 4 mm across (USER), 1.5 mm thick. NOT USED: the motor has its own diametric ring magnet (boss_proud below). Spare.
mt_magnet_d    = 4;
mt_magnet_t    = 1.5;

// ---------- wall mount ----------
key_y          = 28;     // two keyholes side by side at this height, slots pointing down (hang it on two screws)  PROPOSAL
key_dx         = 70;     // distance between the two keyholes (horizontal)  PROPOSAL
key_head       = 7;      // head hole diameter                               PROPOSAL
key_slot       = 3.5;    // slot width                                       PROPOSAL
key_slot_len   = 7;      // PROPOSAL

// ---------- fits ----------
fit            = 0.2;    // printer clearance for sliding/clamped fits (PETG, 0.4 mm nozzle)

// ---------- z stack of the turning side, derived once and used by every part ----------
plate_t        = 2.5;                              // front plate thickness
z_plate_top    = base_depth;                       // the plate sits flush with the top of the wall
z_motor_bot    = z_plate_top;                      // the stator sits ON the plate
z_rotor_top    = z_motor_bot + motor_body_h;
z_boss_bot     = z_motor_bot - boss_proud;        // bottom of the magnet boss, inside the plate hole
z_ped_bot      = z_plate_top;
z_ped_top      = z_ped_bot + pedestal_h;
z_ring_bot     = z_ped_top + ring_gap;
z_ring_top     = z_ring_bot + ring_h;
glass_recess   = 1.5;                              // display glass about 1.5 mm below the ring top  PROPOSAL
z_module_top   = z_ring_top - glass_recess;
z_module_bot   = z_module_top - module_t;
carrier_t      = 4;                                // carrier plate thickness
pocket_h       = 2.2;                              // pocket depth for the module pcb
z_carrier_bot  = z_module_bot + pocket_h - carrier_t;
z_hub_bot      = z_rotor_top - hub_rim_depth;      // hub straddles the rotor top edge
hub_t          = 2.4;
z_hub_top      = z_hub_bot + hub_t;
z_chip_top     = z_boss_bot - sens_gap;            // sensor chip top face
z_pcb_top      = z_chip_top - chip_h;              // sensor board top face = underside of the column foot
z_pcb_bot      = z_pcb_top - mt_pcb_t;
col_foot_z     = z_pcb_top;                        // foot underside rests on the sensor board
foot_t         = (z_plate_top - plate_t) - col_foot_z;   // foot top is against the plate underside
assert(plate_t - boss_proud >= 0.2, "the magnet boss would reach the foot: thicken the plate or lower boss_proud");
col_top_z      = z_carrier_bot + (carrier_t - pocket_h) - 0.2;   // 0.2 mm below the pocket floor

echo(str("base ", base_flat, " x ", base_depth, "  jack axis z=", jack_zc, "  perfboard underside z=", board_z, "  post_h=", post_h));
echo(str("cable legs a=", cab_a, " b=", cab_b, "  Nano x=", nano_x, "  Nano y=", nano_y_end, "..", nano_y_port));
