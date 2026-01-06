/*
 * OpenSCAD Design Template (writing-scad-v2)
 *
 * Use this as a starting point for any new design.
 * Copy and adapt, don't start from scratch.
 *
 * Key rule: All dimensions are parameters. No magic numbers.
 */

// ===================================================================
// [1] PARAMETERS - Everything starts here
// ===================================================================

// [A] BASE DIMENSIONS
// These are your fundamental design inputs
base_l = 100;      // Overall length (X)
base_w = 60;       // Overall width (Y)
base_h = 40;       // Overall height (Z)

// [B] MATERIAL/PROCESS
// Affects printability and geometry
wall_t = 2;        // Wall thickness
nozzle_dia = 0.4;  // Printer nozzle diameter
layer_h = 0.2;     // Layer height (use 0.15, 0.2, 0.3)
min_feature = 0.8; // Minimum printable feature

// [C] FIT/TOLERANCE
// How parts interact with each other
fit_margin = 0.3;          // Sliding fit clearance
press_fit_margin = 0.1;    // Tight/press fit clearance
snap_fit_margin = 0.5;     // Snap clip clearance
chamfer_size = 0.5;        // Edge break for gluing

// [D] FEATURE TOGGLES
// What to include in the final render
include_lid = true;
include_posts = true;
include_features = true;
show_assembly = true;
debug_mode = false;

// [E] RENDERING
// Quality vs. speed tradeoff
preview_fn = 32;   // Fast preview
export_fn = 100;   // High-quality export
$fn = debug_mode ? export_fn : preview_fn;


// ===================================================================
// [2] INCLUDES & HELPER MODULES
// ===================================================================

// Include shared parameters (if multi-part project)
// include <../params.scad>;

// Use shared modules (library code)
// use <../lib/common.scad>;

// Example helper module (optional)
module corner_relief(x, y, z, r=1) {
    translate([x - r, y - r, z]) sphere(r=r, $fn=$fn);
}


// ===================================================================
// [3] FUNCTIONS - Computed Dimensions
// ===================================================================

// Derived dimensions from base + material params
function interior_l(l, t) = l - 2*t;
function interior_w(w, t) = w - 2*t;
function interior_h(h, t) = h - t;

// Tolerance & fit functions
function peg_hole_dia(nominal, margin=fit_margin) = nominal + margin;
function press_fit_hole_dia(nominal) = nominal - press_fit_margin;
function snap_fit_gap(nominal) = nominal + snap_fit_margin;

// Layout/positioning functions
function center_offset_x(width) = -width/2;
function center_offset_y(length) = -length/2;

// Verification (for console output)
function verify_wall_thickness() =
    wall_t < min_feature ? echo("WARNING: Wall too thin!") : echo("Wall OK");


// ===================================================================
// [4] MODULES - Design Building Blocks
// ===================================================================

/**
 * Base box with hollow interior
 */
module base_box(
    l=base_l,
    w=base_w,
    h=base_h,
    t=wall_t,
    fn=$fn
) {
    difference() {
        cube([l, w, h], center=true);
        translate([0, 0, t])
            cube([
                interior_l(l, t),
                interior_w(w, t),
                interior_h(h, t)
            ], center=true);
    }
}

/**
 * Lid with lip for fitting over box
 */
module lid(
    l=base_l,
    w=base_w,
    h=base_h,
    t=wall_t,
    margin=fit_margin,
    fn=$fn
) {
    // Lip sits on top of walls
    translate([0, 0, h/2 + t/2 + margin])
        difference() {
            // Outer dimensions
            cube([l + 2*margin, w + 2*margin, t], center=true);

            // Inner cutout for grip
            translate([0, 0, -t/2])
                cube([
                    interior_l(l, 0.5),
                    interior_w(w, 0.5),
                    t
                ], center=true);
        }
}

/**
 * Support posts (structural elements)
 */
module support_posts(
    count_x=2,
    count_y=2,
    spacing_x=base_l - 20,
    spacing_y=base_w - 20,
    dia=4,
    h=base_h - 5,
    fn=$fn
) {
    if (count_x > 0 && count_y > 0) {
        for (x_i = [0 : count_x - 1]) {
            for (y_i = [0 : count_y - 1]) {
                x_pos = (x_i - (count_x - 1)/2) * spacing_x;
                y_pos = (y_i - (count_y - 1)/2) * spacing_y;

                translate([x_pos, y_pos, -base_h/2 + h/2])
                    cylinder(d=dia, h=h, $fn=fn);
            }
        }
    }
}

/**
 * Complete assembly (for visualization)
 */
module assembly(fn=$fn) {
    // Main body
    base_box(fn=fn);

    // Optional features
    if (include_posts) {
        support_posts(count_x=2, count_y=2, fn=fn);
    }

    if (include_lid) {
        color([1, 0.5, 0, 0.8]) lid(fn=fn);
    }

    // Debug visualization
    if (debug_mode) {
        %color([0, 0, 1, 0.2]) cube([base_l, base_w, 2], center=true);
    }
}


// ===================================================================
// [5] RENDER - Single Entry Point
// ===================================================================

// Call assembly directly
assembly();

/*
VALIDATION CHECKLIST:
════════════════════════════════════════════════════════════════════
□ All dimensions in PARAMETERS section (lines 1-50)
□ No hard-coded numbers below line 50 (except 0, 1, -1)
□ Every module has defaults matching globals
□ Derived dimensions use functions, not repeated math
□ Can toggle features with booleans (include_X)
□ Changing base_l updates entire design
□ Margin/clearance params exist for all fits
□ $fn is explicit (preview_fn vs export_fn)
□ Module composition is clear (simple → complex)
□ Functions exist for repeated calculations
════════════════════════════════════════════════════════════════════

EXPORT INSTRUCTIONS:
1. Set $fn = 100 (high quality) near the top
2. Hit F6 (Render, not Preview)
3. Wait for completion
4. Export → Export as STL
5. Save to appropriate location

CUSTOMIZATION:
- Change base_l, base_w, base_h for size variants
- Adjust wall_t for strength/weight tradeoff
- Set include_lid = false to hide lid
- Set debug_mode = true to see structure
*/
