// ============================================================================
// SHARED MODULES FOR 3D PRINTING PROJECTS
// ============================================================================
// Reusable parametric modules for common printing components
// Include this file in your project: use <lib/common.scad>
// ============================================================================

// === BASIC GEOMETRY ===

// Rectangular peg/post for fitting into holes
// diameter: peg diameter in mm
// height: peg height in mm
// center_z: if true, peg is centered at Z=0; if false, bottom at Z=0
module peg(diameter=4, height=10, center_z=true) {
    translate([0, 0, center_z ? 0 : height/2])
        cylinder(d=diameter, h=height, center=true, $fn=32);
}

// Cylindrical hole for fitting pegs
// diameter: hole diameter in mm (typically peg_diameter + clearance)
// height: hole depth in mm
// depth_from_top: if true, hole depth measured from top; if false, drilled through
module peg_hole(diameter=4.3, height=10, depth_from_top=true) {
    // Slightly larger than peg to allow fit
    translate([0, 0, depth_from_top ? -height/2 : 0])
        cylinder(d=diameter, h=height, center=false, $fn=32);
}

// Rectangular box with uniform wall thickness
// length, width, height: outer dimensions
// wall_t: wall thickness
// bottom_t: bottom thickness (defaults to wall_t if not specified)
module box_shell(length=100, width=60, height=40, wall_t=2, bottom_t=0) {
    actual_bottom = bottom_t > 0 ? bottom_t : wall_t;
    difference() {
        cube([length, width, height], center=true);
        translate([0, 0, actual_bottom - height/2])
            cube([length - 2*wall_t, width - 2*wall_t, height - actual_bottom], center=true);
    }
}

// ============================================================================
// === WALL & MOUNTING FEATURES ===

// Mounting bracket/support wall
// width: wall width (along X axis)
// depth: wall depth (along Y axis)
// height: wall height (along Z axis)
// thickness: wall thickness
module mounting_wall(width=50, depth=30, height=40, thickness=3) {
    cube([width, depth, thickness], center=true);
}

// Round edges on a rectangular shape using minkowski
// size: [length, width, height] of base shape
// radius: corner radius
module rounded_edges(size=[100, 60, 40], radius=3) {
    minkowski() {
        cube([size[0] - 2*radius, size[1] - 2*radius, size[2] - 2*radius], center=true);
        sphere(r=radius, $fn=16);
    }
}

// ============================================================================
// === FASTENERS & CONNECTIVITY ===

// Countersunk bolt hole (for flush-fit bolts)
// diameter: bolt head diameter
// depth: countersink depth
// hole_diameter: through-hole diameter
module countersink_hole(diameter=8, depth=3, hole_diameter=3.2) {
    union() {
        // Countersink recess at top
        translate([0, 0, depth/2])
            cylinder(d=diameter, h=depth, center=true, $fn=32);
        // Through hole
        cylinder(d=hole_diameter, h=100, center=true, $fn=16);
    }
}

// Snap fit clip (simplified rectangular clip)
// width: clip width
// thickness: clip material thickness
// depth: clip engagement depth
module snap_clip(width=20, thickness=1.5, depth=8) {
    cube([width, depth, thickness], center=true);
}

// ============================================================================
// === UTILITY FUNCTIONS ===

// Calculate interior dimension for hollow box
function interior_dimension(outer, wall_thickness) = outer - 2*wall_thickness;

// Calculate clearance value for fit tolerance
// base_dimension: dimension of part A
// margin: desired clearance in mm
function with_clearance(dimension, margin=0.3) = dimension + 2*margin;

// ============================================================================
// === ASSEMBLY HELPERS ===

// Transparent preview of a part (for assembly visualization)
// part_module: the module to preview
// transparency: 0-1, where 0 is invisible, 1 is opaque
module preview(part_module, transparency=0.3) {
    color([0.5, 0.5, 1, transparency])
        part_module;
}
