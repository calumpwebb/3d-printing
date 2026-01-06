---
name: writing-scad-v2
description: Use when writing any OpenSCAD code - enforces parametric patterns, single-source-of-truth dimensions, and production-ready structure so designs stay maintainable and reusable from day one
---

# Writing OpenSCAD - v2

## Overview

**Core principle:** Every design is permanent. Even "quick tests" become library code.

OpenSCAD's power comes from **parametrization**—designs adapt to parameters, not hard-coded magic numbers. Without discipline:
- Changing dimensions requires hunting through code (error-prone)
- Reuse becomes impossible (code is tangled)
- Variants explode in complexity (copy-paste hell)
- Maintenance becomes a nightmare (who changed what?)

This skill enforces the patterns that make OpenSCAD designs **truly parametric, modular, reusable, and maintainable.**

## When to Use

**Use this skill when:**
- Writing any OpenSCAD code (even "quick tests")
- Creating modules you might reuse (even "maybe later")
- Design has dimensions that vary
- Working with multi-part assemblies
- Creating library code for shared use
- Exporting STL for 3D printing

**Don't use for:**
- Understanding existing code (not a code review skill)
- Debugging syntax errors (use OpenSCAD docs)
- Explaining how OpenSCAD works (this is application, not learning)

## Structure: The 4-Layer Pattern

**All OpenSCAD files follow this exact structure:**

```
design.scad
│
├─ [1] PARAMETERS (lines 1-30)
│  ├─ Base dimensions (base_l, base_w, base_h, base_h_wall)
│  ├─ Material/process params (wall_t, nozzle_dia, min_feature)
│  ├─ Fit/tolerance params (fit_margin, clearance, chamfer)
│  ├─ Feature toggles (include_lid, rounded_corners, debug_mode)
│  └─ $fn settings (preview_fn, export_fn)
│
├─ [2] INCLUDES & MODULES (lines 31-60)
│  ├─ use <lib/common.scad>;  for shared modules only
│  ├─ include <lib/params.scad>;  for shared parameters
│  └─ Helper modules (not directly rendered)
│
├─ [3] FUNCTIONS (lines 61-100)
│  ├─ Derived dimensions (interior_l, interior_w)
│  ├─ Computed values (wall_ratio, clearance_fit)
│  └─ Reusable calculations (get_fit_tolerance, calc_margin)
│
├─ [4] MODULES (lines 101+)
│  ├─ Each module accepts only parameters it needs
│  ├─ Module defaults reference [1] globals
│  ├─ Modules compose (box() + lid() → assembly())
│  └─ No geometry below this section (except RENDER)
│
└─ [5] RENDER (last 5-10 lines)
   ├─ Single entry point: module() or assembly()
   └─ Optional: color([r,g,b,a]) for visualization
```

**CRITICAL RULES:**

1. **No hard-coded numbers below line 30** (except 0, 1, -1 for transforms, control structures)
2. **Every dimension is a named parameter** - "Why is this 100?" must have an answer at the top
3. **All modules have defaults** - Must work standalone
4. **$fn is explicit** - Different for preview vs. export
5. **Clearances are intentional** - Fit issues are parametrized, never ignored

---

## 1. Parameters: The Single Source of Truth

### 1.1 Structure - What Goes Where

```openscad
// === PARAMETERS ===

// [A] BASE DIMENSIONS - These are your design inputs
base_l = 100;      // Design length
base_w = 60;       // Design width
base_h = 40;       // Design height

// [B] MATERIAL/PROCESS - Affects geometry
wall_t = 2;        // Wall thickness
nozzle_dia = 0.4;  // Printer nozzle
layer_h = 0.2;     // Layer height (use 0.15, 0.2, 0.3 only)
min_feature = 0.8; // Minimum printable feature width

// [C] FIT/TOLERANCE - How parts interact
fit_margin = 0.3;      // Wiggle room for sliding fits
press_fit_margin = 0.1;  // Tight fits
chamfer_size = 0.5;    // Edge break for gluing

// [D] FEATURE TOGGLES - What to include
include_lid = true;
include_posts = true;
rounded_corners = true;
debug_mode = false;  // Shows interior in semi-transparent

// [E] RENDERING - Preview vs export
$fn = 32;          // Default: preview quality
preview_fn = 32;   // Fast preview
export_fn = 100;   // High-quality export (use: fn=export_fn)
```

### 1.2 Naming Conventions

| Pattern | Example | Use Case |
|---------|---------|----------|
| `base_X` | `base_l`, `base_w`, `base_h` | Fundamental design dimensions |
| `X_t` | `wall_t`, `rim_t`, `post_t` | Thicknesses |
| `inner_X` | `inner_l`, `inner_w` | Interior/hollow dimensions (computed) |
| `X_dia` | `hole_dia`, `post_dia`, `peg_dia` | Diameters |
| `X_margin` | `fit_margin`, `press_fit_margin` | Tolerance/clearance |
| `include_X` | `include_lid`, `include_posts` | Boolean toggles |
| `_fn` | `preview_fn`, `export_fn` | Rendering quality |

### 1.3 Validation Checklist

Before moving to next section:
- [ ] All base dimensions defined (length, width, height)
- [ ] All material specs defined (wall_t, nozzle, layer height)
- [ ] Fit margins defined (at least `fit_margin`)
- [ ] Feature toggles defined (at least `debug_mode`)
- [ ] $fn is explicit (not relying on OpenSCAD defaults)
- [ ] Each parameter has a comment explaining what it controls
- [ ] No computed values in [1] (those go in [3] Functions)
- [ ] Can change one parameter and see expected effect

---

## 2. Includes & Helper Modules

### 2.1 When to Use Include vs. Use

```openscad
// ✅ use <lib/modules.scad>;
//    - For reusable MODULES only
//    - Prevents code execution, just defines
//    - Safe to include multiple times
//    - Prefer this for libraries

// ✅ include <lib/params.scad>;
//    - For shared PARAMETERS only
//    - Executed once, defines globals
//    - Use in assembly.scad to share dims with parts/

// ❌ include <lib/modules.scad>;
//    - WRONG: Each include re-executes = slow + errors
//    - Use 'use' instead
```

### 2.2 Helper Modules (Optional)

Small modules that aren't exported to STL, just used internally:

```openscad
// Example: Helper to place holes in a grid
module hole_grid(x_spacing, y_spacing, x_count, y_count, hole_dia, depth) {
    for (x = [0 : x_count-1]) {
        for (y = [0 : y_count-1]) {
            translate([
                (x - x_count/2) * x_spacing,
                (y - y_count/2) * y_spacing,
                0
            ]) peg_hole(dia=hole_dia, depth=depth);
        }
    }
}
```

---

## 3. Functions: Computed Dimensions

Every repeated calculation becomes a function.

### 3.1 Pattern

```openscad
// ✅ GOOD - Single source for computed dimension
function interior_l(l, t) = l - 2*t;
function interior_w(w, t) = w - 2*t;
function interior_h(h, t) = h - t;  // Only bottom wall

// Usage in modules:
module box(l=base_l, w=base_w, h=base_h, t=wall_t) {
    difference() {
        cube([l, w, h], center=true);
        cube([interior_l(l,t), interior_w(w,t), interior_h(h,t)], center=true);
    }
}

// ❌ BAD - Magic math scattered
module box(l=base_l, w=base_w, h=base_h, t=wall_t) {
    difference() {
        cube([l, w, h], center=true);
        cube([l - 2*t, w - 2*t, h - t], center=true);  // ← Where's the logic?
    }
}
```

### 3.2 Common Functions

```openscad
// Tolerance functions
function fit_dia(nominal, margin=fit_margin) = nominal + 2*margin;
function fit_hole(nominal, margin=fit_margin) = nominal + margin;
function press_fit_dia(nominal) = nominal - press_fit_margin;

// Position functions
function center_y(width) = -width/2;
function center_x(length) = -length/2;

// Fit verification (for comments, not rendering)
function clearance_check(actual_hole, nominal_peg) =
    let(gap = actual_hole - nominal_peg)
    concat("Gap: ", str(gap, "mm (", gap < 0 ? "TIGHT" : "OK", ")"));
```

### 3.3 Validation Checklist

- [ ] No repeated math operations (e.g., `l - 2*t` appears once)
- [ ] Function names describe what they compute
- [ ] Functions are pure (no side effects)
- [ ] Complex functions have explanatory comments

---

## 4. Modules: The Design Building Blocks

### 4.1 The Module Pattern

```openscad
module my_part(
    // Pass only parameters this module uses
    l=base_l,
    w=base_w,
    h=base_h,
    t=wall_t
) {
    // Rule 1: Use function() calls, never inline math
    difference() {
        cube([l, w, h], center=true);
        cube([interior_l(l,t), interior_w(w,t), interior_h(h,t)], center=true);
    }
}
```

### 4.2 Module Defaults Pattern

**Every parameter must have a default:**

```openscad
// ✅ GOOD - Standalone (works with no parameters)
module peg(dia=4, height=10, center_z=true) {
    cylinder(d=dia, h=height, center=center_z);
}

peg();                    // Uses all defaults
peg(dia=5, height=12);    // Override some
peg(dia=5);               // Override one, rest default

// ❌ BAD - Requires context
module peg(dia, height, center_z) {
    // Breaks if called without all params
}
```

### 4.3 Intelligent Parameter Handling

Accept both scalar and vector inputs:

```openscad
// Support multiple input types
function normalize_corners(r) =
    is_num(r) ? [r, r, r, r] :
    is_list(r) && len(r) == 2 ? [r[0], r[0], r[1], r[1]] :
    r;

module rounded_box(size=[100,60,40], radius=2) {
    r = normalize_corners(radius);

    minkowski() {
        cube([
            max(0, size[0] - 2*max(r)),
            max(0, size[1] - 2*max(r)),
            max(0, size[2] - 2*max(r))
        ], center=true);
        sphere(r=max(r));
    }
}

// Works with all these:
rounded_box();                          // Default
rounded_box([150,100,50]);              // Custom size
rounded_box([150,100,50], 3);           // Single radius
rounded_box([150,100,50], [3,5]);       // [top/bottom, sides]
rounded_box([150,100,50], [3,5,2,2]);   // All 4 corners
```

### 4.4 Composition Pattern

Build complex designs by combining modules:

```openscad
// Simple modules
module base() {
    difference() { ... }
}

module columns() {
    for (i = [0 : 3])
        translate([...]) cylinder(d=10, h=30);
}

module top_plate() {
    cube([base_l, base_w, 2], center=true);
}

// Composite
module assembly() {
    base();
    columns();
    translate([0, 0, 30]) top_plate();
}

// ✅ Benefits:
// - Test base() alone
// - Test columns() alone
// - See assembly()
// - Modify one part, others inherit
```

### 4.5 Validation Checklist

- [ ] Every module has default parameters
- [ ] Modules accept only parameters they use (not everything)
- [ ] Complex modules compose from simpler ones
- [ ] No hard-coded positions or transforms
- [ ] Repeated geometry (grids, arrays) use loops

---

## 5. Render: Single Entry Point

```openscad
// === RENDER ===

// ✅ GOOD - Single call point
base();
if (include_lid) lid();
if (debug_mode) {
    %assembly();  // % = semi-transparent preview
}

// ❌ BAD - Multiple renders, unclear intent
base();
lid();
columns();
top_plate();
// Which are being exported?
```

---

## 6. The $fn Decision Tree

**This determines quality vs. speed:**

```
┌─ Are you previewing?
│  ├─ YES → Use preview_fn = 32 (fast)
│  └─ NO → Are you exporting?
│          ├─ YES → Use export_fn = 100+ (high quality)
│          └─ Not sure → Use 32 for now, change at export
```

### 6.1 Guidelines

| Scenario | $fn Value | Why |
|----------|-----------|-----|
| Preview/iteration | 16-32 | Fast feedback |
| Cylinders, holes | 32 minimum | Visible facets ≤0.5mm |
| Decorative elements | 16 | Speed, not critical |
| Export to STL | 100+ | Smooth surface, smaller file |
| Precise features | 128+ | Pegs, fits, critical surfaces |
| Organic shapes | 128+ | Spheres, splines, curves |

### 6.2 Performance Optimization

```openscad
// ✅ GOOD - Conditional $fn
$fn = debug_mode ? 100 : 32;  // High detail for debugging

// ✅ GOOD - Specific modules
module peg(dia=4, height=10, center_z=true, fn=export_fn) {
    cylinder(d=dia, h=height, center=center_z, $fn=fn);
}

// ✅ GOOD - Expensive geometry gets high fn only
module complex_part(..., fn=32) {
    // Critical surface gets export_fn
    difference() {
        sphere(r=30, $fn=export_fn);  // ← High detail for outer
        cube([..], center=true, $fn=fn);  // ← Normal detail for subtract
    }
}
```

---

## 7. Multi-Part Projects

For designs with multiple STL exports:

```
my_project/
├── assembly.scad          # Master file, imports everything
├── params.scad            # Shared parameters (included by all)
├── parts/
│   ├── body.scad          # Standalone export
│   ├── lid.scad           # Standalone export
│   └── bracket.scad       # Standalone export
└── lib/
    └── common.scad        # Shared modules (used, not included)
```

### 7.1 params.scad (Shared Parameters)

```openscad
// === SHARED PARAMETERS ===
// This file is INCLUDED by assembly.scad and parts/*.scad

base_l = 100;
base_w = 60;
base_h = 40;
wall_t = 2;
fit_margin = 0.3;

// ... all parameters
```

### 7.2 assembly.scad (The Master)

```openscad
// === ASSEMBLY ===
// Imports everything, shows how parts fit

include <params.scad>;
use <lib/common.scad>;

// Load parts for visualization
use <parts/body.scad>;
use <parts/lid.scad>;

module assembly() {
    body();
    translate([0, 0, base_h/2]) color([1, 0.5, 0, 0.7]) lid();
}

assembly();
```

### 7.3 parts/body.scad (Standalone Export)

```openscad
// === BODY PART ===
// Can be exported to STL independently

include <../params.scad>;
use <../lib/common.scad>;

module body(l=base_l, w=base_w, h=base_h, t=wall_t) {
    // ... geometry
}

body();
```

**Benefits:**
- Change `wall_t` in params.scad → all parts update
- Each part is standalone-exportable
- No copy-paste of parameters
- Version control shows parameter changes in one place

---

## 8. Tolerance & Fit Strategy

### 8.1 Decision Tree

```
What's your fit requirement?
├─ Sliding fit (peg in hole)
│  ├─ Loose → hole_dia = peg_dia + 0.5mm
│  ├─ Normal → hole_dia = peg_dia + 0.3mm (use fit_margin)
│  └─ Tight → hole_dia = peg_dia + 0.1mm (use press_fit_margin)
│
├─ Press fit (no sliding)
│  └─ hole_dia = peg_dia - 0.1mm (use press_fit_margin)
│
└─ Snap fit (flexible clip)
   └─ Requires test prints (start with 1mm gap, iterate)
```

### 8.2 Implementation

```openscad
// === PARAMETERS ===
peg_dia = 4;
fit_margin = 0.3;       // For sliding fits
press_fit_margin = 0.1; // For tight fits

// === FUNCTIONS ===
function peg_hole_dia(nominal) = nominal + fit_margin;
function press_hole_dia(nominal) = nominal - press_fit_margin;

// === MODULES ===
module peg(dia=peg_dia, height=10, center_z=true) {
    cylinder(d=dia, h=height, center=center_z, $fn=export_fn);
}

module peg_hole(dia=peg_dia, depth=10, fit=fit_margin) {
    hole_dia = peg_hole_dia(dia + fit);
    cylinder(d=hole_dia, h=depth, center=false, $fn=export_fn);
}

// === USAGE ===
peg();              // 4mm diameter
peg_hole();         // 4.3mm hole (4 + 0.3 margin)
```

### 8.3 Fit Verification (Comments)

```openscad
// Clearance check (informational, not rendered)
function verify_fit() = let(
    peg = peg_dia,
    hole = peg_hole_dia(peg),
    gap = hole - peg
)
    echo(str("Peg-hole fit: ", gap, "mm clearance"));

verify_fit();  // Prints to console: "Peg-hole fit: 0.3mm clearance"
```

---

## 9. Common Patterns

### 9.1 Grid of Holes

```openscad
module holes_grid(x_spacing, y_spacing, x_count, y_count, hole_dia, depth) {
    for (x = [0 : x_count-1]) {
        for (y = [0 : y_count-1]) {
            translate([
                (x - (x_count-1)/2) * x_spacing,
                (y - (y_count-1)/2) * y_spacing,
                0
            ]) cylinder(d=hole_dia, h=depth, $fn=export_fn);
        }
    }
}

// Usage:
difference() {
    cube([100, 100, 10], center=true);
    holes_grid(15, 15, 7, 7, 4, 10);  // 7x7 grid, 4mm holes
}
```

### 9.2 Assembly with Transparency

```openscad
module assembly_view() {
    color([0.8, 0.8, 0.8]) body();
    color([1, 0.5, 0, 0.6]) %lid();      // % = semi-transparent
    color([0.3, 0.3, 0.8]) %posts();     // Visual assembly check
}

assembly_view();
```

### 9.3 Conditional Geometry

```openscad
// === PARAMETERS ===
include_lid = true;
include_posts = true;
show_assembly = true;

module complete_assembly() {
    body();

    if (include_posts) {
        for (i = [0 : 3]) {
            translate([...]) post();
        }
    }

    if (include_lid) {
        translate([0, 0, base_h/2 + 1]) lid();
    }

    if (show_assembly) {
        %internal_structure();  // Reference only
    }
}

complete_assembly();
```

---

## 10. Migration: Converting Non-Parametric Code

### 10.1 Step 1: Extract Numbers

```openscad
// ❌ BEFORE - Numbers scattered everywhere
module box() {
    difference() {
        cube([100, 60, 40], center=true);
        cube([96, 56, 38], center=true);
    }
}

// ✅ STEP 1 - Move numbers to top
base_l = 100;
base_w = 60;
base_h = 40;
wall_t = 2;

module box() {
    difference() {
        cube([base_l, base_w, base_h], center=true);
        cube([base_l - 2*wall_t, base_w - 2*wall_t, base_h - wall_t], center=true);
    }
}
```

### 10.2 Step 2: Replace Magic Math with Functions

```openscad
// ✅ STEP 2 - Extract computed dimensions
function interior_l(l, t) = l - 2*t;
function interior_w(w, t) = w - 2*t;
function interior_h(h, t) = h - t;

module box(l=base_l, w=base_w, h=base_h, t=wall_t) {
    difference() {
        cube([l, w, h], center=true);
        cube([interior_l(l,t), interior_w(w,t), interior_h(h,t)], center=true);
    }
}
```

### 10.3 Step 3: Add Module Defaults

```openscad
// ✅ STEP 3 - Modules work standalone
module box(l=base_l, w=base_w, h=base_h, t=wall_t) {
    // ...
}

box();                  // Uses all defaults
box(150);               // Override one param
box(l=150, h=50);      // Named params
```

### 10.4 Step 4: Verify & Clean

Checklist:
- [ ] All numbers in top section
- [ ] No repeated math
- [ ] Modules have defaults
- [ ] Can toggle features with booleans
- [ ] Changing one param updates whole design

---

## 11. Validation Before Export

**Create this checklist in comments before rendering:**

```openscad
/*
VALIDATION CHECKLIST:
─────────────────────────────────────────────────────────
□ All dimensions defined in PARAMETERS (lines 1-30)
□ No hard-coded numbers below line 30 (except 0, 1, -1)
□ Every module has defaults matching globals
□ Derived dimensions use functions, not repeated math
□ Can toggle features with booleans (include_X)
□ Changing one base parameter updates whole design
□ Margin/clearance params exist for all fits
□ $fn is explicit (preview_fn=32, export_fn=100)
□ Multi-part projects use assembly.scad + parts/ + lib/
□ Functions exist for complex repeated calculations
□ Module composition is clear (base→columns→assembly)
─────────────────────────────────────────────────────────
*/
```

---

## 12. Red Flags - STOP and Apply Patterns

These thoughts mean you're about to violate this skill:

| Red Flag | Reality | Fix |
|----------|---------|-----|
| "This is just a quick test" | Tests become permanent code | Use full pattern NOW |
| "User wants to ignore best practices" | Patterns save time | Apply skill anyway |
| "This design is too simple/complex" | Structure is always needed | Use pattern for ANY size |
| "I'll refactor later" | Later never comes | Structure now |
| "It's only one-off" | Everything gets reused | Treat as permanent |
| "I'll remember why this magic number is 8" | You won't. Ever. | Name it at the top |
| "Patterns are overkill here" | Cost of patterns < cost of violations | Always use them |
| "I can just inline this calculation" | This is how unmaintainability starts | Make a function |
| "Let me copy this module for a variant" | Copy-paste is technical debt | Use parameters instead |
| "I don't need defaults" | Modules become context-dependent | Always add defaults |

**If you see ANY of these thoughts: STOP. Apply the full parametric pattern. No exceptions.**

---

## 13. Quick Checklist

Before hitting render/export:

- [ ] **Parameters** - All dimensions in lines 1-30, properly named
- [ ] **Functions** - All repeated math extracted to functions
- [ ] **Modules** - All have defaults, accept only what they use
- [ ] **Composition** - Complex designs built from simple modules
- [ ] **$fn** - Explicit: preview_fn=32, export_fn=100+
- [ ] **Features** - All toggles use boolean parameters
- [ ] **Tolerance** - Fit margins parameterized, not guessed
- [ ] **Standalone test** - Can call each module independently
- [ ] **Single change test** - Change base_l, entire design updates
- [ ] **Comments** - Why this value? Answer at parameter line

---

## 14. Real-World Complete Example

```openscad
// === PARAMETERS ===
base_l = 100;
base_w = 60;
base_h = 40;
wall_t = 2;
corner_r = 3;
peg_dia = 4;
fit_margin = 0.3;
include_lid = true;
include_posts = true;
debug_mode = false;

preview_fn = 32;
export_fn = 100;
$fn = debug_mode ? export_fn : preview_fn;

// === FUNCTIONS ===
function interior_l(l, t) = l - 2*t;
function interior_w(w, t) = w - 2*t;
function interior_h(h, t) = h - t;
function peg_hole_dia(nominal, margin=fit_margin) = nominal + margin;

// === MODULES ===
module rounded_cube(size, r) {
    minkowski() {
        cube([
            max(0, size[0] - 2*r),
            max(0, size[1] - 2*r),
            max(0, size[2] - 2*r)
        ], center=true);
        sphere(r=r, $fn=$fn);
    }
}

module body(l=base_l, w=base_w, h=base_h, t=wall_t, r=corner_r) {
    difference() {
        rounded_cube([l, w, h], r);
        translate([0, 0, t])
            rounded_cube([interior_l(l,t), interior_w(w,t), interior_h(h,t)], r-0.5);
    }
}

module lid(l=base_l, w=base_w, t=wall_t, r=corner_r) {
    translate([0, 0, base_h/2 + t/2])
        difference() {
            rounded_cube([l-0.3, w-0.3, t], r);
            translate([0, 0, -t/2])
                rounded_cube([interior_l(l,t)-2, interior_w(w,t)-2, t], r-0.5);
        }
}

module posts(l=base_l, w=base_w, h=base_h, dia=peg_dia) {
    post_h = h - 2;
    for (x = [-l/3, l/3]) {
        for (y = [-w/3, w/3]) {
            translate([x, y, -h/2 + post_h/2])
                cylinder(d=dia, h=post_h, $fn=$fn);
        }
    }
}

module assembly() {
    body();
    if (include_posts) posts();
    if (include_lid) color([1, 0.5, 0, 0.8]) lid();
    if (debug_mode) %posts();  // Show all post positions
}

// === RENDER ===
assembly();
```

**Key properties:**
- Change `base_l = 150` → entire design scales
- Change `wall_t = 3` → all walls update
- Set `include_lid = false` → lid disappears
- Set `debug_mode = true` → shows interior structure
- Export: use `$fn = 100` for high quality

---

## 15. Sources & References

- [OpenSCAD User Manual](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual)
- [OpenSCAD Cheatsheet](https://openscad.org/cheatsheet/)
- [Parametric Design Principles](https://www.prusa3d.com/en/blog/parametric-design-in-openscad/)
- [OpenSCAD Performance Tips](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Performance)
