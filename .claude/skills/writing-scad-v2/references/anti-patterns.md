# Anti-Patterns in OpenSCAD

Common mistakes and how to fix them.

## 1. Magic Numbers Scattered Throughout Code

### ❌ Bad

```openscad
module box() {
    difference() {
        cube([100, 60, 40], center=true);
        cube([96, 56, 38], center=true);  // Where do these come from?
    }
}

module mounting_post() {
    cylinder(d=5, h=15);  // Why 5? Why 15?
}

module lid() {
    cube([100.5, 60.5, 2], center=true);  // Why 100.5?
}
```

**Problems:**
- Changing one dimension requires finding all related numbers
- No way to know if values are intentional or bugs
- Reuse is impossible (what do these numbers mean?)
- Future you won't remember the relationships

### ✅ Good

```openscad
// === PARAMETERS ===
base_l = 100;
base_w = 60;
base_h = 40;
wall_t = 2;
lid_margin = 0.25;
post_dia = 5;
post_h = 15;

// === MODULES ===
module box(l=base_l, w=base_w, h=base_h, t=wall_t) {
    difference() {
        cube([l, w, h], center=true);
        cube([l - 2*t, w - 2*t, h - t], center=true);
    }
}

module mounting_post(dia=post_dia, height=post_h) {
    cylinder(d=dia, h=height);
}

module lid(l=base_l, w=base_w, margin=lid_margin, t=wall_t) {
    cube([l + 2*margin, w + 2*margin, t], center=true);
}
```

**Benefits:**
- Single source of truth for each dimension
- Easy to create variants
- Clear intent
- Reusable code

---

## 2. Hard-Coded Computations (Repeated Math)

### ❌ Bad

```openscad
wall_t = 2;
base_l = 100;
base_w = 60;

module box() {
    difference() {
        cube([base_l, base_w, 40], center=true);
        cube([base_l - 2*wall_t, base_w - 2*wall_t, 38], center=true);
    }
}

module lid() {
    cube([base_l - 2*wall_t, base_w - 2*wall_t, 2], center=true);
}

module posts() {
    for (i = [-base_l/2 + 10 : 20 : base_l/2 - 10]) {
        translate([i, 0, 0]) cylinder(d=4, h=30);
    }
}
```

**Problems:**
- Same calculation (`base_l - 2*wall_t`) appears twice
- If you change it once, you have to find and change it elsewhere
- Updates become error-prone
- Introduces bugs

### ✅ Good

```openscad
wall_t = 2;
base_l = 100;
base_w = 60;

// === FUNCTIONS ===
function interior_l(l, t) = l - 2*t;
function interior_w(w, t) = w - 2*t;
function post_spacing(len) = len - 20;  // Start/end inset

module box(l=base_l, w=base_w, h=40, t=wall_t) {
    difference() {
        cube([l, w, h], center=true);
        cube([interior_l(l,t), interior_w(w,t), h-t], center=true);
    }
}

module lid(l=base_l, w=base_w, t=wall_t) {
    cube([interior_l(l,t), interior_w(w,t), 2], center=true);
}

module posts(l=base_l, spacing=20) {
    for (i = [-post_spacing(l)/2 : spacing : post_spacing(l)/2]) {
        translate([i, 0, 0]) cylinder(d=4, h=30);
    }
}
```

**Benefits:**
- Change computation once, everywhere updates
- Clear what each calculation represents
- Easy to test individual functions
- Reusable across modules

---

## 3. Missing Module Defaults

### ❌ Bad

```openscad
module box(l, w, h, t) {
    difference() {
        cube([l, w, h], center=true);
        cube([l - 2*t, w - 2*t, h - t], center=true);
    }
}

// Must always provide all parameters
box(100, 60, 40, 2);  // Works
box(100, 60, 40);     // ERROR: missing 4th parameter
```

**Problems:**
- Can't test module standalone
- Each call requires all parameters
- Adding new parameters breaks all existing calls
- Code becomes brittle

### ✅ Good

```openscad
base_l = 100;
base_w = 60;
base_h = 40;
wall_t = 2;

module box(l=base_l, w=base_w, h=base_h, t=wall_t) {
    difference() {
        cube([l, w, h], center=true);
        cube([l - 2*t, w - 2*t, h - t], center=true);
    }
}

// All of these work:
box();                      // Uses all defaults
box(150);                   // Override length only
box(150, 80);               // Override length & width
box(l=200, h=50);           // Named params, skip width
box(l=200, w=100, h=50);    // Named params, skip thickness
```

**Benefits:**
- Backwards compatible
- Can test module independently
- Graceful parameter addition
- Flexible usage patterns

---

## 4. No Tolerance/Clearance Planning

### ❌ Bad

```openscad
peg_dia = 4;

module peg() {
    cylinder(d=peg_dia, h=10);
}

module peg_hole() {
    cylinder(d=peg_dia, h=10);  // EXACT same size - won't fit!
}
```

**Problems:**
- Parts fit too tight (won't assemble)
- Causes print failures and waste
- Trial-and-error iterations needed
- No systematic approach

### ✅ Good

```openscad
peg_dia = 4;
fit_margin = 0.3;  // Sliding fit clearance
press_fit_margin = 0.1;  // Tight fit clearance

function peg_hole_dia(nominal, margin=fit_margin) = nominal + margin;
function peg_hole_dia_press(nominal) = nominal - press_fit_margin;

module peg(dia=peg_dia, height=10) {
    cylinder(d=dia, h=height, $fn=100);
}

module peg_hole_sliding(dia=peg_dia, depth=10) {
    cylinder(d=peg_hole_dia(dia), h=depth, $fn=100);
}

module peg_hole_press(dia=peg_dia, depth=10) {
    cylinder(d=peg_hole_dia_press(dia), h=depth, $fn=100);
}
```

**Benefits:**
- Fit works first time
- Scalable to different sizes
- Easy to adjust for tolerance issues
- Less waste, fewer iterations

---

## 5. Mixing `include` and `use` Incorrectly

### ❌ Bad

```openscad
// main.scad
include <lib/modules.scad>;
include <lib/modules.scad>;  // Oops, included twice
include <lib/modules.scad>;  // Each runs again → slow + errors
```

**Problems:**
- Code executes multiple times
- Slow renders
- Variables overwrite each other
- Confusing behavior

### ✅ Good

```openscad
// lib/modules.scad - contains MODULES only
module my_module() { ... }
module another_module() { ... }

// lib/params.scad - contains PARAMETERS only
base_l = 100;
wall_t = 2;

// main.scad - orchestrates assembly
include <lib/params.scad>;    // Include params once
use <lib/modules.scad>;        // Use modules (no execution)
use <lib/common.scad>;         // Use other module libraries

module assembly() {
    my_module();
    another_module();
}

assembly();
```

**Rules:**
- `use` for modules: Safe to include multiple times, just defines
- `include` for parameters: Defines globals, executes once
- Never `include` the same file twice

---

## 6. Parameters Scattered Across Multiple Places

### ❌ Bad

```openscad
// main.scad
base_l = 100;

// parts/body.scad
base_l = 100;      // Duplicate!
wall_t = 2;

// parts/lid.scad
base_l = 100;      // Duplicate again!
wall_t = 2;        // Duplicate again!
lid_t = 1;

// assembly.scad
base_l = 100;      // EVERYWHERE!
```

**Problems:**
- Change in one place, others are wrong
- No single source of truth
- Easy to introduce inconsistencies
- Maintenance nightmare

### ✅ Good

```
project/
├── params.scad           # ONE place for all parameters
├── assembly.scad         # include <params.scad>
└── parts/
    ├── body.scad         # include <../params.scad>
    └── lid.scad          # include <../params.scad>
```

```openscad
// params.scad
base_l = 100;
base_w = 60;
base_h = 40;
wall_t = 2;
lid_t = 1;

// assembly.scad
include <params.scad>;
use <parts/body.scad>;
use <parts/lid.scad>;
body();
lid();

// parts/body.scad
include <../params.scad>;
module body(l=base_l, w=base_w, h=base_h, t=wall_t) { ... }
body();

// parts/lid.scad
include <../params.scad>;
module lid(l=base_l, w=base_w, h=base_h, t=wall_t, lid_t=lid_t) { ... }
lid();
```

**Benefits:**
- Single source of truth
- Change params once, all files see update
- Easy version control (one changeset)
- Clear what's configurable

---

## 7. Copy-Paste Code for Variants

### ❌ Bad

```openscad
// SMALL version
module small_box() {
    difference() {
        cube([50, 30, 20], center=true);
        cube([46, 26, 18], center=true);
    }
}

// MEDIUM version (copied from small, changed numbers)
module medium_box() {
    difference() {
        cube([100, 60, 40], center=true);
        cube([96, 56, 38], center=true);
    }
}

// LARGE version (copied from medium, changed numbers)
module large_box() {
    difference() {
        cube([150, 90, 60], center=true);
        cube([146, 86, 58], center=true);
    }
}
```

**Problems:**
- Code tripled/quadrupled for variants
- Bug fixes have to be applied in 3 places
- Easy to make mistakes (miss one variant)
- Unmaintainable

### ✅ Good

```openscad
// === PARAMETERS ===
SMALL  = [50, 30, 20];
MEDIUM = [100, 60, 40];
LARGE  = [150, 90, 60];

variant = MEDIUM;  // Change this line
[base_l, base_w, base_h] = variant;

wall_t = 2;

// === MODULES ===
module box(l=base_l, w=base_w, h=base_h, t=wall_t) {
    difference() {
        cube([l, w, h], center=true);
        cube([l - 2*t, w - 2*t, h - t], center=true);
    }
}

box();
```

**Or with dictionary (OpenSCAD 2021.01+):**

```openscad
SIZES = [
    ["small", [50, 30, 20]],
    ["medium", [100, 60, 40]],
    ["large", [150, 90, 60]]
];

size_name = "large";
[base_l, base_w, base_h] = SIZES[search([size_name], SIZES)[0]][1];

module box(l=base_l, w=base_w, h=base_h, t=wall_t) {
    difference() {
        cube([l, w, h], center=true);
        cube([l - 2*t, w - 2*t, h - t], center=true);
    }
}

box();
```

**Benefits:**
- Single module, multiple sizes
- Bug fix applies to all variants
- Add new variant by adding one line
- Clean, maintainable code

---

## 8. Complex Geometry Without Structure

### ❌ Bad

```openscad
// 300 lines of cube, difference, translate, etc
// No modules
// No functions
// No organization
```

**Problems:**
- Can't find anything
- Hard to debug
- Impossible to reuse
- Testing is impossible

### ✅ Good

```openscad
// Decompose into meaningful modules
module base() { ... }
module columns() { ... }
module top_plate() { ... }
module assembly() {
    base();
    columns();
    top_plate();
}
```

**Benefits:**
- Test each part independently
- Modify one part in isolation
- Reuse modules in other designs
- Debug is straightforward

---

## 9. No $fn Management

### ❌ Bad

```openscad
// No $fn specified - uses OpenSCAD defaults (unpredictable)
cylinder(d=10, h=20);
sphere(r=5);
cube([10, 20, 30]);
```

**Problems:**
- Preview is slow or rough
- Export produces unexpected quality
- Inconsistent results
- Hard to control output

### ✅ Good

```openscad
// Explicit $fn for preview vs. export
preview_fn = 32;
export_fn = 100;
$fn = preview_fn;

module peg(dia=4, height=10) {
    cylinder(d=dia, h=height, $fn=$fn);
}

// Override when needed
sphere(r=5, $fn=export_fn);  // Extra detail for sphere
```

**Benefits:**
- Fast preview (preview_fn=32)
- High-quality export (export_fn=100)
- Consistent results
- Easy to adjust globally

---

## 10. Hard-Coded Positions

### ❌ Bad

```openscad
module assembly() {
    cube([100, 100, 10], center=true);
    translate([0, 0, 15]) cube([100, 100, 10], center=true);
    translate([40, 40, 0]) cylinder(d=5, h=100);
    translate([-40, 40, 0]) cylinder(d=5, h=100);
    translate([40, -40, 0]) cylinder(d=5, h=100);
    translate([-40, -40, 0]) cylinder(d=5, h=100);
}
```

**Problems:**
- Positions are magic numbers
- Hard to understand layout
- Changing spacing requires finding all translate commands
- Not parametric

### ✅ Good

```openscad
base_l = 100;
base_w = 100;
layer_spacing = 5;
post_spacing_x = 80;
post_spacing_y = 80;

module assembly() {
    translate([0, 0, 0]) cube([base_l, base_w, 10], center=true);
    translate([0, 0, layer_spacing/2 + 5]) cube([base_l, base_w, 10], center=true);

    for (x = [-post_spacing_x/2, post_spacing_x/2]) {
        for (y = [-post_spacing_y/2, post_spacing_y/2]) {
            translate([x, y, 0]) cylinder(d=5, h=100);
        }
    }
}
```

**Benefits:**
- Clear layout logic
- Easy to adjust spacing
- Automatic with parameter changes
- Reusable positioning logic

---

## Summary: The Anti-Pattern Detector

If you see any of these, REFACTOR:

1. ✗ Numbers not at top of file
2. ✗ Same calculation repeated
3. ✗ Module without defaults
4. ✗ Hardcoded tolerances (no margins)
5. ✗ Mixed `include`/`use` usage
6. ✗ Parameters in multiple files
7. ✗ Copy-pasted modules for variants
8. ✗ 50+ lines without modules
9. ✗ No $fn specification
10. ✗ Positions as magic numbers

Fix them FIRST before rendering.
