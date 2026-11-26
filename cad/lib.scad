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

// the three perfboard pieces: [centre x, centre y, width, length, chamfers]
function pieceA() = [boardA_cx, boardA_y0 + boardA_l / 2, boardA_w, boardA_l, [board_chamfer, 0, 0, 0]];
function pieceB1() = [max485_cx, max485_cy, max485_w + 2 * board_pad, max485_l + 2 * board_pad, [0, 0, 0, 0]];
function pieceB2() = [tmc_cx, tmc_cy, tmc_l + 2 * board_pad, tmc_w + 2 * board_pad, [0, board_chamfer, 0, 0]];
