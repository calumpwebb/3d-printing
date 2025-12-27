// ========================================
// TOLERANCE TEST BLOCK - SQUARE
// Tests square shaft/hole fit across 5 tolerance levels
// Press the test peg into each hole to find your printer's limits
// ========================================

// === PARAMETERS ===
// Block dimensions (small for quick print)
block_l = 77;
block_w = 24;
block_h = 12;
corner_r = 2;             // corner radius (mm)

// Tolerance test setup
nominal_sq = 10;          // nominal square side length (mm)
test_gaps = [0.20, 0.25, 0.30, 0.35, 0.40];  // tolerance gaps (mm)
hole_spacing = 15;        // hole center-to-center spacing
hole_depth = 7;           // drilling depth from top

// === HELPERS ===
function hole_size(gap) = nominal_sq + gap;
function num_tests() = len(test_gaps);
function first_hole_offset() = -(num_tests() - 1) * hole_spacing / 2;

// === MODULES ===
module tolerance_block_square(l=block_l, w=block_w, h=block_h, r=corner_r) {
    minkowski() {
        difference() {
            // Main block (shrink by corner radius)
            cube([l-2*r, w-2*r, h-2*r], center=true);

            // Drill test holes at increasing tolerances
            for (i = [0 : num_tests() - 1]) {
                xpos = first_hole_offset() + i * hole_spacing;
                zpos = h/2 - hole_depth/2;
                translate([xpos, 0, zpos])
                    cube([hole_size(test_gaps[i]), hole_size(test_gaps[i]), hole_depth], center=true);
            }
        }
        sphere(r);
    }
}

// === RENDER ===
tolerance_block_square();
