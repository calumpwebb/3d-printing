// === SHALLOW CUP COASTER ===

base_diameter = 100;       // 4" opening diameter in mm
base_height = 15;          // Height from bottom to top of coaster body in mm
wall_height = 5;           // Height of wall extending up from base in mm
wall_thickness = 4;        // Thickness of walls in mm

// Weathering - random pits for concrete aesthetic
pit_count = 20;            // Number of pits scattered on surface
pit_max_radius = 1.5;      // Maximum radius of each pit in mm

// Derived parameters
outer_diameter = base_diameter + 2 * wall_thickness;
total_height = base_height + wall_height;

module pits_weathering(count, max_r, bounds_d, bounds_h) {
    // Generate random pits across the surface
    for (i = [0:count-1]) {
        // Use different seeds for x, y, z, and radius to get varied random values
        x = rands(-bounds_d/2, bounds_d/2, 1, i)[0];
        y = rands(-bounds_d/2, bounds_d/2, 1, i + 100)[0];
        z = rands(0, bounds_h, 1, i + 200)[0];
        r = rands(0.3, max_r, 1, i + 300)[0];

        translate([x, y, z])
            sphere(r = r, $fn = 16);
    }
}

module coaster(
    d_base = base_diameter,
    h_base = base_height,
    h_wall = wall_height,
    t_wall = wall_thickness,
    pits_n = pit_count,
    pits_max_r = pit_max_radius
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

        // Subtract weathering pits for concrete aesthetic
        pits_weathering(pits_n, pits_max_r, outer_d, total_h);
    }
}

coaster();
