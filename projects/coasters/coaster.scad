// === SHALLOW CUP COASTER ===

base_diameter = 100;       // 4" opening diameter in mm
base_height = 15;          // Height from bottom to top of coaster body in mm
wall_height = 5;           // Height of wall extending up from base in mm
wall_thickness = 4;        // Thickness of walls in mm

// Derived parameters
outer_diameter = base_diameter + 2 * wall_thickness;
total_height = base_height + wall_height;

module coaster(
    d_base = base_diameter,
    h_base = base_height,
    h_wall = wall_height,
    t_wall = wall_thickness
) {
    outer_d = d_base + 2 * t_wall;
    total_h = h_base + h_wall;

    difference() {
        // Outer solid cylinder (full shape)
        cylinder(h = total_h, d = outer_d, center = false, $fn = 100);

        // Cut out from the top rim section only
        // Creates hollow rim walls from base_height to total_height
        translate([0, 0, h_base])
            cylinder(h = h_wall, d = d_base, center = false, $fn = 100);
    }
}

coaster();
