// ===== PARAMETERS =====

// Mounting plate dimensions
plate_length = 120;        // Length of bracket plate (X)
plate_width = 58;          // Width of bracket plate (Y)
plate_thickness = 8;       // Thickness of plate (Z)

// Screw hole pattern
hole_pattern_length = 50;  // X distance between holes
hole_pattern_width = 30;   // Y distance between holes
hole_diameter = 6;         // Hole diameter
nut_recess_diameter = 12;  // Nut head recess diameter
screw_material = 5;        // Material for screw threads

// Dovetail dimensions
dovetail_length = 50;      // Length of dovetail rail - how far to slide on (along Y)
dovetail_top_width = 8;    // Width at top (narrow, attached to plate)
dovetail_bottom_width = 16; // Width at bottom (wide, the catch)
dovetail_height = 15;      // How far dovetail drops below plate

// Rendering
$fn = 32;

// ===== HELPERS =====
function hole_offset_x() = hole_pattern_length / 2;
function hole_offset_y() = hole_pattern_width / 2;

// ===== MODULES =====

// Dovetail profile (2D) - trapezoidal cross-section
// X = drop distance (becomes -Z after rotation, hanging down)
// Y = trapezoid width (narrow at top, wide at bottom)
module dovetail_profile_2d(
    top_w = dovetail_top_width,
    bottom_w = dovetail_bottom_width,
    height = dovetail_height
) {
    polygon([
        [0, -top_w/2],
        [0, top_w/2],
        [height, bottom_w/2],
        [height, -bottom_w/2]
    ]);
}

// Mount bracket with screw holes and dovetail rail
module mount_bracket() {
    recess_depth = plate_thickness - screw_material;

    // Main plate with screw holes
    difference() {
        cube([plate_length, plate_width, plate_thickness], center=true);

        off_x = hole_offset_x();
        off_y = hole_offset_y();

        for (dx = [-1, 1]) {
            for (dy = [-1, 1]) {
                // Through hole for screw
                translate([dx * off_x, dy * off_y, -plate_thickness/2 - 1])
                    cylinder(h = plate_thickness + 2, d = hole_diameter, $fn=24);

                // Nut recess from bottom
                translate([dx * off_x, dy * off_y, -plate_thickness/2 - 1])
                    cylinder(h = recess_depth + 1, d = nut_recess_diameter, $fn=24);
            }
        }
    }

    // Dovetail rail extending down from bottom of plate, running along Y
    // After rotate([-90,0,-90]): extrusion→Y, profile X→-Z (down), profile Y→X (width)
    translate([0, 0, -plate_thickness/2])
        rotate([-90, 0, -90])
            linear_extrude(height = dovetail_length, center = true)
                dovetail_profile_2d();
}

// ===== RENDER =====
mount_bracket();
