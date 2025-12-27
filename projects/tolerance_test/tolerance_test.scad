// ========================================
// TOLERANCE TEST BLOCK
// Tests shaft/hole fit across 5 tolerance levels
// Press the test peg into each hole to find your printer's limits
// ========================================

// === PARAMETERS ===
// Block dimensions (small for quick print)
block_l = 77;
block_w = 24;
block_h = 12;
corner_r = 2;             // corner radius (mm)

// Tolerance test setup
nominal_d = 10;           // nominal shaft diameter (mm)
test_gaps = [0.20, 0.25, 0.30, 0.35, 0.40];  // tolerance gaps (mm)
hole_spacing = 15;        // hole center-to-center spacing
hole_depth = 7;           // drilling depth from top

// Test peg (separate piece to print & test)
peg_d = nominal_d;
peg_h = 10;

// === HELPERS ===
function hole_dia(gap) = nominal_d + gap;
function num_tests() = len(test_gaps);
function first_hole_offset() = -(num_tests() - 1) * hole_spacing / 2;

// === MODULES ===
module tolerance_block(l=block_l, w=block_w, h=block_h, r=corner_r) {
    minkowski() {
        difference() {
            // Main block (shrink by corner radius)
            cube([l-2*r, w-2*r, h-2*r], center=true);

            // Drill test holes at increasing tolerances
            for (i = [0 : num_tests() - 1]) {
                xpos = first_hole_offset() + i * hole_spacing;
                zpos = h/2 - hole_depth/2;
                translate([xpos, 0, zpos])
                    cylinder(d=hole_dia(test_gaps[i]), h=hole_depth, center=true);
            }
        }
        sphere(r);
    }
}

module test_peg(d=peg_d, h=peg_h) {
    cylinder(d=d, h=h, center=true);
}

// === RENDER ===
tolerance_block();

// Show peg for reference (transparent preview)
% translate([0, -16, block_h/2 + peg_h/2 + 1])
    test_peg();

// PRINTING INSTRUCTIONS:
// 1. Print tolerance_block() - has 5 holes with gaps: 0.20, 0.25, 0.30, 0.35, 0.40mm
// 2. Print test_peg() - nominal 10mm diameter shaft to test against each hole
// 3. After printing, press peg into each hole to find which tolerance fits best
// 4. Record which tolerance level works for your printer settings
