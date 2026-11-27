// Shared 2D/3D helpers for the perfboard pieces: outline with optional sawn-off corners, and the rim frame it rests on.
include <params.scad>

// c = chamfer size per corner [bottom-left, bottom-right, top-right, top-left]; 0 = square corner
module board2d(cx, cy, w, l, c = [0, 0, 0, 0]) {
    translate([cx - w / 2, cy - l / 2]) difference() {
        square([w, l]);
        if (c[0] > 0) polygon([[-0.01, -0.01], [c[0], -0.01], [-0.01, c[0]]]);
        if (c[1] > 0) polygon([[w + 0.01, -0.01], [w - c[1], -0.01], [w + 0.01, c[1]]]);
        if (c[2] > 0) polygon([[w + 0.01, l + 0.01], [w - c[2], l + 0.01], [w + 0.01, l - c[2]]]);
        if (c[3] > 0) polygon([[-0.01, l + 0.01], [c[3], l + 0.01], [-0.01, l - c[3]]]);
    }
}

// rim frame: a wall of width board_rim under the board edge, from the floor up to the board underside
module board_frame(cx, cy, w, l, c = [0, 0, 0, 0]) {
    translate([0, 0, back_plate - 0.01]) linear_extrude(post_h + 0.01)
        difference() {
            board2d(cx, cy, w, l, c);
            offset(delta = -board_rim) board2d(cx, cy, w, l, c);
        }
}

// Frame of one facet: origin on the OUTER face at position `along` and height `zc`;
// local x runs along the facet, local +y points INTO the base, local z is up.
// ang 0 = bottom facet, 90 = right facet, 180 = top, 270 = left.
module on_facet(ang, along, zc) {
    rotate([0, 0, ang]) translate([along, -base_flat / 2, zc]) children();
}

// the three perfboard pieces: [centre x, centre y, width (x), length (y), chamfers bl, br, tr, tl]
// A: the Nano lies along x; the two corners at its far end are sawn off
function pieceA() = [boardA_cx, boardA_cy, nano_l + 3, nano_w + 2.2, cab_dir > 0 ? [0, board_chamfer, board_chamfer, 0] : [board_chamfer, 0, 0, board_chamfer]];
function pieceB1() = max485_rot == 0 ? [max485_cx, max485_cy, max485_w + 2 * board_pad, max485_l + 2 * board_pad, [0, 0, 0, 0]]
                                     : [max485_cx, max485_cy, max485_l + 2 * board_pad, max485_w + 2 * board_pad, [0, 0, 0, 0]];
function pieceB2() = tmc_rot == 0 ? [tmc_cx, tmc_cy, tmc_l + 2 * board_pad, tmc_w + 2 * board_pad, [0, board_chamfer, 0, 0]]
                                  : [tmc_cx, tmc_cy, tmc_w + 2 * board_pad, tmc_l + 2 * board_pad, [0, 0, 0, 0]];
