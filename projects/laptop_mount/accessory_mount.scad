// Accessory Mount Base Plate - 3-PIECE VERSION
// Top plate + full-height walls + bottom plate (no dovetails)
// 50x88mm plate with 30x50mm bolt pattern (centered)

/* [Display] */
display_mode = "separated"; // [assembled, separated, print_top, print_walls, print_bottom]
separation = 150;       // mm - gap between pieces when separated

/* [Plate Dimensions] */
plate_width = 78;       // mm (X direction) - walls width
plate_height = 64;      // mm (Y direction) - gives ~20mm gap per side (just over 3/4")
plate_thickness = 8;    // mm

/* [Bolt Pattern] */
bolt_pattern_x = 50;    // mm between holes (width) - rotated 90°
bolt_pattern_y = 30;    // mm between holes (height) - rotated 90°
bolt_hole_dia = 6;      // mm - clearance for bolts
bolt_head_dia = 12;     // mm - recess for bolt heads
bolt_recess_depth = 3;  // mm - countersink depth

/* [Walls] */
wall_height = 254;      // mm (10 inches internal)
wall_thickness = 8;     // mm
wall_sections = 3;      // number of wall sections (fence panels)
wall_section_width = 20; // mm - width of each wall section
wall_gap_width = 2;     // mm - gap between wall sections

/* [Bottom Plate] */
bottom_width = 363;     // mm (X direction) - full width of bottom plate
bumper_height = 25.4;   // mm - height of guide bumpers (1 inch)
bumper_thickness = 8;   // mm - thickness of bumpers (same as walls)

/* [Bumper Configuration] */
bumper_clearance = 6.35;     // mm - distance from wall to end of bumper (0.25")
bumper_divider_ratio = 0.75; // ratio - middle divider height as fraction of bumper_height

/* [Hidden] */

// Derived dimensions
plastic_behind_bolt = plate_thickness - bolt_recess_depth;
top_plate_width = bottom_width/2 + plate_width/2;
side_bumper_length = (bottom_width/2 - wall_thickness) - (plate_width/2 + bumper_clearance);
wall_total_width = wall_sections * wall_section_width + (wall_sections - 1) * wall_gap_width;
wall_start_x = -wall_total_width / 2;  // center the fence horizontally

module bolt_hole() {
    // Through hole
    cylinder(h = plate_thickness + 1, d = bolt_hole_dia, center = false, $fn = 32);

    // Counterbore recess for bolt head
    cylinder(h = bolt_recess_depth, d = bolt_head_dia, center = false, $fn = 32);
}

// Top plate (not used in final assembly, for reference)
module mount_plate() {
    difference() {
        // Extended plate - back to front of walls only
        translate([-bottom_width/2, -plate_height/2, 0])
            cube([top_plate_width, plate_height, plate_thickness]);

        // Bolt holes in 50x30mm pattern, centered
        for (x = [-bolt_pattern_x/2, bolt_pattern_x/2]) {
            for (y = [-bolt_pattern_y/2, bolt_pattern_y/2]) {
                translate([x, y, -0.5])
                    bolt_hole();
            }
        }
    }

    // Back bumper - runs along the back edge (-X side), pointing DOWN
    translate([-bottom_width/2, -plate_height/2, -bumper_height])
        cube([wall_thickness, plate_height, bumper_height]);

    // Left side bumper - runs along -Y edge (back section only), pointing DOWN
    translate([-bottom_width/2 + wall_thickness, -plate_height/2, -bumper_height])
        cube([side_bumper_length, wall_thickness, bumper_height]);

    // Right side bumper - runs along +Y edge (back section only), pointing DOWN
    translate([-bottom_width/2 + wall_thickness, plate_height/2 - wall_thickness, -bumper_height])
        cube([side_bumper_length, wall_thickness, bumper_height]);

    // Middle divider bumper - separates the two sides, pointing DOWN
    translate([-bottom_width/2 + wall_thickness, -wall_thickness/2, -bumper_height])
        cube([side_bumper_length, wall_thickness, bumper_height]);
}


// ============ TOP PLATE ============
module top_plate() {
    difference() {
        // Top plate - from back to front of walls
        translate([-bottom_width/2, -plate_height/2, 0])
            cube([top_plate_width, plate_height, plate_thickness]);

        // Bolt holes in 50x30mm pattern, centered
        for (x = [-bolt_pattern_x/2, bolt_pattern_x/2]) {
            for (y = [-bolt_pattern_y/2, bolt_pattern_y/2]) {
                translate([x, y, -0.5])
                    bolt_hole();
            }
        }
    }

    // Bumpers on top plate
    // Back bumper - runs along the back edge (-X side), pointing DOWN
    translate([-bottom_width/2, -plate_height/2, -bumper_height])
        cube([wall_thickness, plate_height, bumper_height]);

    // Left side bumper - runs along -Y edge (back section only), pointing DOWN
    translate([-bottom_width/2 + wall_thickness, -plate_height/2, -bumper_height])
        cube([side_bumper_length, wall_thickness, bumper_height]);

    // Right side bumper - runs along +Y edge (back section only), pointing DOWN
    translate([-bottom_width/2 + wall_thickness, plate_height/2 - wall_thickness, -bumper_height])
        cube([side_bumper_length, wall_thickness, bumper_height]);

    // Middle divider bumper - separates the two sides, pointing DOWN
    translate([-bottom_width/2 + wall_thickness, -wall_thickness/2, -bumper_height])
        cube([side_bumper_length, wall_thickness, bumper_height]);
}

// ============ BOTTOM PLATE ============
module bottom_plate() {
    // Full width bottom plate
    translate([-bottom_width/2, -plate_height/2, -wall_thickness])
        cube([bottom_width, plate_height, wall_thickness]);

    // Integrated bumpers pointing UP
    // Back bumper - runs along the back edge (-X side), pointing UP
    translate([-bottom_width/2, -plate_height/2, 0])
        cube([wall_thickness, plate_height, bumper_height]);

    // Left side bumper - runs along -Y edge
    translate([-bottom_width/2 + wall_thickness, -plate_height/2, 0])
        cube([side_bumper_length, wall_thickness, bumper_height]);

    // Right side bumper - runs along +Y edge
    translate([-bottom_width/2 + wall_thickness, plate_height/2 - wall_thickness, 0])
        cube([side_bumper_length, wall_thickness, bumper_height]);

    // Middle divider bumper - separates the two sides
    translate([-bottom_width/2 + wall_thickness, -wall_thickness/2, 0])
        cube([side_bumper_length, wall_thickness, bumper_height * bumper_divider_ratio]);
}

// ============ FULL-HEIGHT WALLS (3 walls with fence-style sections) ============
module walls() {
    // Three full height walls (left, right, middle), each made of fence sections
    wall_z_start = -wall_height;
    wall_z_height = wall_height;

    // Left wall - full height, fence-style
    for (i = [0 : wall_sections - 1]) {
        section_x = wall_start_x + i * (wall_section_width + wall_gap_width);
        translate([section_x, -plate_height/2, wall_z_start])
            cube([wall_section_width, wall_thickness, wall_z_height]);
    }

    // Right wall - full height, fence-style
    for (i = [0 : wall_sections - 1]) {
        section_x = wall_start_x + i * (wall_section_width + wall_gap_width);
        translate([section_x, plate_height/2 - wall_thickness, wall_z_start])
            cube([wall_section_width, wall_thickness, wall_z_height]);
    }

    // Middle wall - full height, fence-style
    for (i = [0 : wall_sections - 1]) {
        section_x = wall_start_x + i * (wall_section_width + wall_gap_width);
        translate([section_x, -wall_thickness/2, wall_z_start])
            cube([wall_section_width, wall_thickness, wall_z_height]);
    }
}

// ============ SINGLE WALL (fence-style sections) ============
module single_wall() {
    // Full height wall made of configurable sections with gaps (fence style)
    wall_z_start = -wall_height;
    wall_z_height = wall_height;

    for (i = [0 : wall_sections - 1]) {
        // Position each section: start at wall_start_x, then offset by section width + gap
        section_x = wall_start_x + i * (wall_section_width + wall_gap_width);

        translate([section_x, -plate_height/2, wall_z_start])
            cube([wall_section_width, wall_thickness, wall_z_height]);
    }
}

// ============ RENDER ============
if (display_mode == "assembled") {
    // Assembled view
    top_plate();
    walls();
    translate([0, 0, -wall_height])
        bottom_plate();
} else if (display_mode == "separated") {
    // Separated for printing
    // Top plate - print flat, bolt side down
    translate([0, -separation, plate_thickness])
        rotate([180, 0, 0])
            top_plate();

    // Single wall - full height (print 3 of these)
    translate([0, 0, wall_height/2])
        rotate([180, 0, 0])
            single_wall();

    // Bottom plate - print flat
    translate([0, separation, wall_thickness])
        rotate([180, 0, 0])
            bottom_plate();
} else if (display_mode == "print_top") {
    // Top plate - print flat with bolt side down
    rotate([180, 0, 0])
        top_plate();
} else if (display_mode == "print_walls") {
    // Single wall - print 3 of these
    rotate([180, 0, 0])
        single_wall();
} else if (display_mode == "print_bottom") {
    // Bottom plate - print flat
    rotate([180, 0, 0])
        bottom_plate();
}

// Info
gap_size = (plate_height - 3 * wall_thickness) / 2;
echo("Plate size:", plate_width, "x", plate_height, "x", plate_thickness, "mm");
echo("Plastic behind bolts:", plastic_behind_bolt, "mm");
echo("Wall height:", wall_height, "mm (", wall_height/25.4, "in)");
echo("Gap per side:", gap_size, "mm (", gap_size/25.4, "in)");
