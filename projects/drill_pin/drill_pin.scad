// === PARAMETERS ===
drill_diameter = 11.1125;  // 7/16" in mm
pin_height = 8;
clearance_a = 1.3;
clearance_b = 1.4;
spacing = 5;  // Gap between pins

// === DERIVED ===
pin_diameter_a = drill_diameter - clearance_a;
pin_diameter_b = drill_diameter - clearance_b;

// === MODULES ===
module pin(d, h=pin_height) {
    cylinder(d=d, h=h, $fn=64);
}

// === RENDER ===
// Pin A: 0.3mm clearance (10.81mm diameter)
translate([-(drill_diameter/2 + spacing/2), 0, 0])
    pin(d=pin_diameter_a);

// Pin B: 0.4mm clearance (10.71mm diameter)
translate([(drill_diameter/2 + spacing/2), 0, 0])
    pin(d=pin_diameter_b);
