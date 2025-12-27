// ========================================
// TOLERANCE TEST PEG
// Test shaft to press into each hole of the tolerance block
// ========================================

// === PARAMETERS ===
nominal_d = 10;           // nominal shaft diameter (mm)
peg_h = 6.4;              // peg height (0.6mm shorter than hole depth)
grip_d = 20;              // grip base diameter (mm)
grip_h = 6;               // grip base height (mm)
corner_r = 1;             // corner radius (mm)

// === MODULES ===
module test_peg(d=nominal_d, h=peg_h, grip_d=grip_d, grip_h=grip_h, r=corner_r) {
    minkowski() {
        union() {
            // Main shaft (shrink by corner radius)
            cylinder(d=d-2*r, h=h-2*r, center=true);

            // Grip base at bottom (shrink by corner radius)
            translate([0, 0, -(h/2 + grip_h/2)])
                cylinder(d=grip_d-2*r, h=grip_h-2*r, center=true);
        }
        sphere(r);
    }
}

// === RENDER ===
test_peg();
