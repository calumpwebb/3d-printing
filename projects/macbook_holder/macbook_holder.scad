// ===== PARAMETERS =====
// Hole pattern dimensions (distance between corner holes)
hole_pattern_length = 50;  // X distance between holes
hole_pattern_width = 30;   // Y distance between holes
hole_diameter = 6;         // Hole diameter at corners
nut_recess_diameter = 12;  // Diameter for nut head recess
screw_material = 5;        // Material thickness for screw threads
plate_margin = 5;          // Margin/padding around hole pattern
plate_thickness = 8;       // Thickness of plate
wall_t = 8;                // Wall thickness
length_multiplier = 2;     // Multiplier for plate length (X direction)

// Internal compartment dimensions
internal_width = 40 + wall_t;   // Internal width (Y) - gap between side walls + 1 wall for middle divider
internal_height = 274;     // Internal height (Z) - 10 inches + 20mm = 274mm (vertical)

// Middle wall configuration
middle_wall_depth_pct = 0.20;  // How far the middle wall extends (20% from each end)
middle_wall_depth = internal_height * middle_wall_depth_pct;

// Lap joint configuration
lap_overlap = 20;          // How much the lap joint overlaps (configurable)
lap_thickness = wall_t / 2; // Half the wall thickness for the lap

// View options
part = "exploded"; // [top:Top Half, bottom:Bottom Half, exploded:Exploded View, assembled:Assembled]
explode_distance = 50;     // Gap between pieces in exploded view

// Derived dimensions
plate_length = (hole_pattern_length + 2*plate_margin) * length_multiplier;
plate_width = internal_width + 2*wall_t;  // Width based on internal space + side walls
half_height = internal_height / 2;  // Center point where joint occurs

// ===== HELPERS =====
function hole_offset_x() = hole_pattern_length / 2;
function hole_offset_y() = hole_pattern_width / 2;
function wall_y_pos() = internal_width / 2 + wall_t / 2;

// ===== MODULES =====

// Top plate with corner holes and nut recesses
module top_plate(
    length = plate_length,
    width = plate_width,
    thickness = plate_thickness,
    hole_d = hole_diameter,
    nut_d = nut_recess_diameter,
    screw_mat = screw_material
) {
    recess_depth = thickness - screw_mat;  // Depth of nut recess

    difference() {
        cube([length, width, thickness], center=true);

        off_x = hole_offset_x();
        off_y = hole_offset_y();

        for (dx = [-1, 1]) {
            for (dy = [-1, 1]) {
                // Through hole for screw
                translate([dx * off_x, dy * off_y, -thickness/2 - 1])
                    cylinder(h = thickness + 2, d = hole_d, center=false, $fn=24);

                // Nut recess from bottom (nuts go up)
                translate([dx * off_x, dy * off_y, -thickness/2 - 1])
                    cylinder(h = recess_depth + 1, d = nut_d, center=false, $fn=24);
            }
        }
    }
}

// Bottom plate (same as top but without holes)
module bottom_plate(
    length = plate_length,
    width = plate_width,
    thickness = plate_thickness
) {
    cube([length, width, thickness], center=true);
}

// Single wall with lap joint cut
// side: 1 = outer lap (for top piece), -1 = inner lap (for bottom piece)
module wall_with_lap(
    length = plate_length,
    height,
    thickness = wall_t,
    lap_h = lap_overlap,
    lap_t = lap_thickness,
    side = 1  // 1 = cut inner half (top piece), -1 = cut outer half (bottom piece)
) {
    difference() {
        // Full wall
        cube([length, thickness, height], center=true);

        // Cut away half the thickness at the lap zone
        // side=1: remove inner half (Y negative side of wall center)
        // side=-1: remove outer half (Y positive side of wall center)
        translate([0, -side * lap_t / 2, (height / 2 - lap_h / 2) * -sign(side)])
            cube([length + 1, lap_t, lap_h], center=true);
    }
}

// Helper to get sign
function sign(x) = x > 0 ? 1 : (x < 0 ? -1 : 0);

// Middle divider wall (partial height)
module middle_wall(
    length = plate_length,
    height = middle_wall_depth,
    thickness = wall_t
) {
    cube([length, thickness, height], center=true);
}

// TOP HALF: top plate + upper walls with lap joint extending down + middle wall
module top_half() {
    // Top plate
    top_plate();

    // Upper portion of walls (from top plate down to center + overlap)
    upper_wall_height = half_height + lap_overlap;
    y_pos = wall_y_pos();
    z_start = -plate_thickness / 2;

    // Left wall (positive Y) - lap material on outer side (+Y)
    translate([0, y_pos, z_start - upper_wall_height / 2])
        wall_with_lap(height = upper_wall_height, side = 1);

    // Right wall (negative Y) - lap material on outer side (-Y) - MIRRORED
    translate([0, -y_pos, z_start - upper_wall_height / 2])
        mirror([0, 1, 0]) wall_with_lap(height = upper_wall_height, side = 1);

    // Middle wall extending down 20%
    translate([0, 0, z_start - middle_wall_depth / 2])
        middle_wall();
}

// BOTTOM HALF: bottom plate + lower walls with lap joint extending up + middle wall
module bottom_half() {
    // Lower portion of walls (from bottom plate up to center + overlap)
    lower_wall_height = half_height + lap_overlap;
    y_pos = wall_y_pos();
    z_end = -plate_thickness / 2 - internal_height;

    // Left wall (positive Y) - lap material on inner side (-Y)
    translate([0, y_pos, z_end + lower_wall_height / 2])
        wall_with_lap(height = lower_wall_height, side = -1);

    // Right wall (negative Y) - lap material on inner side (+Y) - MIRRORED
    translate([0, -y_pos, z_end + lower_wall_height / 2])
        mirror([0, 1, 0]) wall_with_lap(height = lower_wall_height, side = -1);

    // Middle wall extending up 20%
    translate([0, 0, z_end + middle_wall_depth / 2])
        middle_wall();

    // Bottom plate
    translate([0, 0, z_end - plate_thickness / 2])
        bottom_plate();
}

// ===== RENDER =====
if (part == "top") {
    // Top half only - rotated flat for printing
    rotate([180, 0, 0])
        top_half();
} else if (part == "bottom") {
    // Bottom half only - already flat for printing
    translate([0, 0, plate_thickness / 2 + internal_height + plate_thickness / 2])
        bottom_half();
} else if (part == "exploded") {
    // Exploded/disassembled view
    translate([0, 0, explode_distance / 2])
        top_half();
    translate([0, 0, -explode_distance / 2])
        bottom_half();
} else {
    // Assembled view
    top_half();
    bottom_half();
}
