// ===== PARAMETERS =====
// Hole pattern dimensions (distance between corner holes)
hole_pattern_length = 50;  // X distance between holes
hole_pattern_width = 30;   // Y distance between holes
hole_diameter = 6;         // Hole diameter at corners
nut_recess_diameter = 12;  // Diameter for nut head recess
screw_material = 5;        // Material thickness for screw threads
plate_margin = 5;          // Margin/padding around hole pattern
plate_thickness = 8;       // Thickness of plate
wall_t = 6;                // Wall thickness
length_multiplier = 2;     // Multiplier for plate length (X direction)

// Internal compartment dimensions
compartment_gap = 40;      // Gap between side walls (Y) - space for items
internal_width = compartment_gap + wall_t;   // Total internal width including middle divider
internal_height = 274;     // Internal height (Z) - 10 inches + 20mm = 274mm (vertical)

// Middle wall configuration
middle_wall_depth_pct = 0.20;  // How far the middle wall extends (20% from each end)
middle_wall_depth = internal_height * middle_wall_depth_pct;

// Wall cutout pattern (for material savings)
cutout_columns = 5;       // Number of cutouts along wall length
cutout_rows = 3;          // Number of cutouts up wall height (per wall half)
cutout_margin = 0;        // Extra margin beyond rib (0 = rib width is the edge margin)
cutout_rib = 8;           // Width of ribs between cutouts (also used as edge margin)

// Lap joint configuration
lap_overlap = 50;          // How much the lap joint overlaps (configurable)
lap_thickness = wall_t / 2; // Half the wall thickness for the lap

// Hanging bracket system (side hook rails)
hook_rail_width = 10;      // Width of rail along Y edge
hook_rail_drop = 15;       // How far rail drops below bracket
hook_lip_depth = 8;        // How far lip extends inward
hook_lip_height = 5;       // Thickness of the lip
hook_clearance = 0.4;      // Clearance for sliding fit
bracket_thickness = 8;     // Thickness of mount bracket plate

// View options
part = "hanging"; // [top:Top Half, bottom:Bottom Half, exploded:Exploded View, assembled:Assembled, bracket:Bracket Only, hanging_top:Hanging Top Half, hanging:Hanging Assembly]
explode_distance = 50;     // Gap between pieces in exploded view

// Derived dimensions
plate_length = (hole_pattern_length + 2*plate_margin) * length_multiplier;
plate_width = internal_width + 2*wall_t;  // Width based on internal space + side walls
half_height = internal_height / 2;  // Center point where joint occurs
hook_total_drop = hook_rail_drop + hook_lip_height;  // Total depth of hook system

// ===== HELPERS =====
function hole_offset_x() = hole_pattern_length / 2;
function hole_offset_y() = hole_pattern_width / 2;
function wall_y_pos() = internal_width / 2 + wall_t / 2;

// Cutout dimension calculations
// Given available space, grid count, and rib width, calculate cutout size
function cutout_width(avail_length, cols, rib) =
    (avail_length - (cols + 1) * rib) / cols;
function cutout_height(avail_height, rows, rib) =
    (avail_height - (rows + 1) * rib) / rows;

// ===== MODULES =====

// Generates a grid of rectangular cutouts for wall material savings
// wall_length: total wall length (X)
// wall_height: height of the cuttable area (Z) - excludes lap zone
// wall_thickness: wall thickness (Y) - cutouts go through
// cols/rows: number of cutouts in each direction
// margin: solid border around the pattern
// rib: width of material between cutouts
module wall_cutout_grid(
    wall_length,
    wall_height,
    wall_thickness,
    cols = cutout_columns,
    rows = cutout_rows,
    margin = cutout_margin,
    rib = cutout_rib
) {
    // Available space after margins
    avail_length = wall_length - 2 * margin;
    avail_height = wall_height - 2 * margin;

    // Calculate cutout dimensions
    cut_w = cutout_width(avail_length, cols, rib);
    cut_h = cutout_height(avail_height, rows, rib);

    // Only render if cutouts have positive size
    if (cut_w > 0 && cut_h > 0) {
        // Grid centered on wall center
        for (col = [0 : cols - 1]) {
            for (row = [0 : rows - 1]) {
                // Position: start from corner, offset by margin + rib, then by cell position
                x_pos = -wall_length/2 + margin + rib + cut_w/2 + col * (cut_w + rib);
                z_pos = -wall_height/2 + margin + rib + cut_h/2 + row * (cut_h + rib);

                translate([x_pos, 0, z_pos])
                    cube([cut_w, wall_thickness + 2, cut_h], center=true);
            }
        }
    }
}

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

// Single wall with lap joint cut and optional cutout pattern
// side: 1 = outer lap (for top piece), -1 = inner lap (for bottom piece)
module wall_with_lap(
    length = plate_length,
    height,
    thickness = wall_t,
    lap_h = lap_overlap,
    lap_t = lap_thickness,
    side = 1,  // 1 = cut inner half (top piece), -1 = cut outer half (bottom piece)
    add_cutouts = true
) {
    // Height available for cutouts: total height minus lap zone minus margin from lap edge
    cutout_zone_height = height - lap_h - cutout_margin;

    // Z offset for cutout zone center (opposite side from lap)
    // side=1 (top piece): lap at bottom, cutouts toward top (positive Z)
    // side=-1 (bottom piece): lap at top, cutouts toward bottom (negative Z)
    cutout_zone_z = side * (lap_h / 2 + cutout_margin / 2);

    difference() {
        // Full wall
        cube([length, thickness, height], center=true);

        // Cut away half the thickness at the lap zone
        // side=1: remove inner half (Y negative side of wall center)
        // side=-1: remove outer half (Y positive side of wall center)
        translate([0, -side * lap_t / 2, (height / 2 - lap_h / 2) * -sign(side)])
            cube([length + 1, lap_t, lap_h], center=true);

        // Cutout pattern (only in the non-lap zone)
        if (add_cutouts && cutout_zone_height > 2 * cutout_margin) {
            translate([0, 0, cutout_zone_z])
                wall_cutout_grid(
                    wall_length = length,
                    wall_height = cutout_zone_height,
                    wall_thickness = thickness
                );
        }
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

// Hook rail profile (2D) - L-shaped rail on bracket edge
// Extends down then inward to form a lip
module hook_rail_profile_2d(
    drop = hook_rail_drop,
    lip_d = hook_lip_depth,
    lip_h = hook_lip_height,
    rail_w = hook_rail_width
) {
    // Vertical drop
    square([rail_w, drop]);
    // Horizontal lip at bottom (pointing inward, will be mirrored for each side)
    translate([0, drop])
        square([rail_w + lip_d, lip_h]);
}

// Wall-mount bracket with screw holes and side hook rails
module mount_bracket(
    length = plate_length,
    width = plate_width,
    thickness = bracket_thickness,
    hole_d = hole_diameter,
    nut_d = nut_recess_diameter,
    screw_mat = screw_material
) {
    recess_depth = thickness - screw_mat;

    // Main bracket plate with screw holes
    difference() {
        cube([length, width, thickness], center=true);

        off_x = hole_offset_x();
        off_y = hole_offset_y();

        for (dx = [-1, 1]) {
            for (dy = [-1, 1]) {
                // Through hole for screw
                translate([dx * off_x, dy * off_y, -thickness/2 - 1])
                    cylinder(h = thickness + 2, d = hole_d, center=false, $fn=24);

                // Nut recess from bottom
                translate([dx * off_x, dy * off_y, -thickness/2 - 1])
                    cylinder(h = recess_depth + 1, d = nut_d, center=false, $fn=24);
            }
        }
    }

    // Left hook rail (+Y side) - lip points toward center (-Y)
    translate([0, width/2 - hook_rail_width, -thickness/2])
        rotate([0, -90, 0])
            linear_extrude(height = length, center = true)
                hook_rail_profile_2d();

    // Right hook rail (-Y side) - lip points toward center (+Y)
    translate([0, -width/2, -thickness/2])
        rotate([0, -90, 0])
            mirror([0, 1, 0])
                linear_extrude(height = length, center = true)
                    hook_rail_profile_2d();
}

// Hanger plate with hook lips on sides (replaces top_plate for hanging version)
module hanger_plate(
    length = plate_length,
    width = plate_width,
    thickness = plate_thickness
) {
    // Clearances for the slot
    slot_width = hook_rail_width + hook_clearance;
    slot_drop = hook_rail_drop + hook_clearance;
    lip_slot_depth = hook_lip_depth + hook_clearance;
    lip_slot_height = hook_lip_height + hook_clearance;

    // Hook height needed above the plate
    hook_height = hook_total_drop;

    difference() {
        union() {
            // Main plate
            cube([length, width, thickness], center=true);

            // Left hook (+Y side) - extends up then wraps outward
            translate([0, width/2 - slot_width - lip_slot_depth, thickness/2])
                cube([length, slot_width + lip_slot_depth, hook_height], center=false);

            // Right hook (-Y side)
            translate([0, -width/2 + lip_slot_depth, thickness/2])
                mirror([0, 1, 0])
                    cube([length, slot_width + lip_slot_depth, hook_height], center=false);
        }

        // Cut the slot for left rail (opening faces +Y)
        translate([-length/2 - 1, width/2 - slot_width, thickness/2])
            cube([length + 2, slot_width, slot_drop]);
        // Cut the lip pocket for left rail
        translate([-length/2 - 1, width/2 - slot_width - lip_slot_depth, thickness/2 + slot_drop])
            cube([length + 2, slot_width + lip_slot_depth, lip_slot_height]);

        // Cut the slot for right rail (opening faces -Y)
        translate([-length/2 - 1, -width/2, thickness/2])
            cube([length + 2, slot_width, slot_drop]);
        // Cut the lip pocket for right rail
        translate([-length/2 - 1, -width/2, thickness/2 + slot_drop])
            cube([length + 2, slot_width + lip_slot_depth, lip_slot_height]);
    }
}

// TOP HALF: top plate + upper walls with lap joint extending down + middle wall
module top_half() {
    // Top plate
    top_plate();

    // Upper portion of walls (from top plate down to center + half overlap)
    // Each wall extends by lap_overlap/2 so together they overlap by lap_overlap
    upper_wall_height = half_height + lap_overlap / 2;
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

// TOP HALF (HANGING): hanger plate + upper walls (for use with mount_bracket)
module top_half_hanging() {
    // Hanger plate with hook lips (hooks extend above plate)
    translate([0, 0, hook_total_drop / 2])
        hanger_plate();

    // Upper portion of walls
    upper_wall_height = half_height + lap_overlap / 2;
    y_pos = wall_y_pos();
    z_start = -plate_thickness / 2;

    // Left wall (positive Y)
    translate([0, y_pos, z_start - upper_wall_height / 2])
        wall_with_lap(height = upper_wall_height, side = 1);

    // Right wall (negative Y)
    translate([0, -y_pos, z_start - upper_wall_height / 2])
        mirror([0, 1, 0]) wall_with_lap(height = upper_wall_height, side = 1);

    // Middle wall extending down 20%
    translate([0, 0, z_start - middle_wall_depth / 2])
        middle_wall();
}

// BOTTOM HALF: bottom plate + lower walls with lap joint extending up + middle wall
module bottom_half() {
    // Lower portion of walls (from bottom plate up to center + half overlap)
    // Each wall extends by lap_overlap/2 so together they overlap by lap_overlap
    lower_wall_height = half_height + lap_overlap / 2;
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
} else if (part == "bracket") {
    // Mount bracket only - for printing
    rotate([180, 0, 0])
        mount_bracket();
} else if (part == "hanging_top") {
    // Hanging top half only - for printing
    rotate([180, 0, 0])
        top_half_hanging();
} else if (part == "hanging") {
    // Hanging assembly view - bracket + holder
    bracket_z = bracket_thickness/2 + hook_total_drop + explode_distance;
    translate([0, 0, bracket_z])
        mount_bracket();
    // Holder hangs below
    translate([0, 0, explode_distance / 2])
        top_half_hanging();
    translate([0, 0, -explode_distance / 2])
        bottom_half();
} else {
    // Assembled view (original screw-together version)
    top_half();
    bottom_half();
}
