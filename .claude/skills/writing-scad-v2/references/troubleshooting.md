# Troubleshooting Common OpenSCAD Issues

## Problem: Parts Don't Fit Together

### Symptom
Peg won't slide into hole, parts jam when assembled

### Causes

**1. Hole too small (no clearance)**
```openscad
// ❌ WRONG
peg_dia = 4;
function hole_dia(d) = d;  // No margin!

// ✅ CORRECT
peg_dia = 4;
fit_margin = 0.3;
function hole_dia(d) = d + fit_margin;  // 4.3mm
```

**2. Tolerance mismatch between parts**
```openscad
// ❌ Inconsistent
module peg() { cylinder(d=4, h=10); }
module hole() { cylinder(d=4.2, h=10); }  // Manual calculation

// ✅ Consistent
fit_margin = 0.3;
module peg(dia=4) { cylinder(d=dia, h=10); }
module hole(dia=4, margin=fit_margin) {
    cylinder(d=dia + margin, h=10);
}
```

**3. Multi-part project has inconsistent parameters**

Use shared parameters file:
```
project/
├── params.scad        # ONE source of truth
├── parts/body.scad
└── parts/lid.scad
```

```openscad
// params.scad
peg_dia = 4;
fit_margin = 0.3;

// parts/body.scad
include <../params.scad>;
cylinder(d=peg_dia, h=10);

// parts/lid.scad
include <../params.scad>;
cylinder(d=peg_dia + fit_margin, h=10);
```

### Solution Checklist

- [ ] Define fit_margin parameter
- [ ] All hole diameters use: `peg_dia + fit_margin`
- [ ] All press fits use: `peg_dia - press_fit_margin`
- [ ] Test in OpenSCAD (measure with cursor)
- [ ] Do a small test print first
- [ ] Adjust margin if needed, re-export

---

## Problem: Render is Extremely Slow

### Symptom
Preview/render takes 30+ seconds, makes iteration impossible

### Causes

**1. $fn too high for preview**
```openscad
// ❌ WRONG
$fn = 100;  // High detail for everything

// ✅ CORRECT
$fn = 32;   // Fast preview
// Use $fn=100 only when exporting
```

**2. Complex geometry with high $fn**
```openscad
// ❌ SLOW
difference() {
    sphere(r=50, $fn=100);      // 100 facets
    sphere(r=40, $fn=100);      // Another 100
    sphere(r=35, $fn=100);      // Another 100
}

// ✅ FAST
difference() {
    sphere(r=50, $fn=32);       // Preview fast
    sphere(r=40, $fn=32);
    sphere(r=35, $fn=32);
}
// Switch to $fn=100 only for export
```

**3. Unnecessary detail in hidden geometry**
```openscad
// ❌ SLOW - Subtracted geometry uses high $fn
module part() {
    difference() {
        sphere(r=50, $fn=100);      // Visible
        sphere(r=40, $fn=100);      // Hidden! Still slow
    }
}

// ✅ FAST - Reduce $fn for subtracted parts
module part() {
    difference() {
        sphere(r=50, $fn=100);      // Visible, high detail
        sphere(r=40, $fn=32);       // Hidden, low detail
    }
}
```

### Solution Checklist

- [ ] Set `preview_fn = 32` for fast iteration
- [ ] Only use `export_fn = 100+` when exporting STL
- [ ] Hidden geometry can use lower $fn
- [ ] Test with simpler geometry first
- [ ] Use F5 (fast preview) not F6 (slow render) during development

---

## Problem: Module Parameters Don't Work as Expected

### Symptom
Module doesn't behave correctly when called with different parameters

### Causes

**1. Module expects globals but doesn't get them**
```openscad
// ❌ WRONG - References global directly
base_l = 100;
module box() {
    cube([base_l, 60, 40], center=true);  // Hard-coded dependency
}

box(150);  // Still makes 100mm box!

// ✅ CORRECT - Accepts parameter
base_l = 100;
module box(l=base_l) {
    cube([l, 60, 40], center=true);
}

box();      // Uses global default (100)
box(150);   // Uses parameter override
```

**2. Parameters don't have defaults**
```openscad
// ❌ WRONG - No defaults
module box(l, w, h, t) {
    // ...
}

box();           // ERROR
box(100, 60);    // ERROR - missing 2 params

// ✅ CORRECT - All have defaults
module box(l=100, w=60, h=40, t=2) {
    // ...
}

box();           // Works
box(150);        // Works
box(l=120, h=50); // Works
```

**3. Nested modules don't pass parameters correctly**
```openscad
// ❌ WRONG
module assembly(l, w, h) {
    base(l, w, h);  // Forgot parameters
    lid(l, w);      // Not all needed params
}

// ✅ CORRECT
module assembly(l=base_l, w=base_w, h=base_h) {
    base(l=l, w=w, h=h);
    lid(l=l, w=w);
}
```

### Solution Checklist

- [ ] Every module parameter has a default
- [ ] Defaults match global variables
- [ ] Nested modules pass required parameters explicitly
- [ ] Can call module with no arguments
- [ ] Can override individual parameters
- [ ] Test: `module_name();` works

---

## Problem: Dimensions Are Wrong in Exported STL

### Symptom
Exported STL is wrong size (e.g., 100mm box is actually 50mm)

### Causes

**1. Wrong parameter at render time**
```openscad
// ❌ WRONG
base_l = 100;
module box(l=base_l) { cube([l, 60, 40], center=true); }
base_l = 50;  // ← Changed after module definition!
box();        // Now renders 50mm box
```

**2. Missing parameter in multi-part project**
```openscad
// assembly.scad defines params correctly
include <params.scad>;

// body.scad DOESN'T include params
module body() {  // base_l is undefined!
    cube([base_l, 60, 40], center=true);
}
```

**3. Mixing different $fn settings per part**
```openscad
// ❌ Different renders might use different geometry
$fn = 32;
cube([100, 60, 40]);     // 32-facet cylinders

$fn = 100;
sphere(r=10);            // 100-facet sphere (different precision)
```

### Solution Checklist

- [ ] Verify render at correct $fn (32 for preview, 100+ for export)
- [ ] Check parameter values in console output
- [ ] Multi-part: Verify all files `include <params.scad>`
- [ ] Use consistent $fn throughout
- [ ] Measure in OpenSCAD (cursor shows dimensions)
- [ ] Check that bounding box looks right before export

---

## Problem: Code is Disorganized and Hard to Maintain

### Symptom
Can't find where a dimension is defined, hard to make changes

### Causes

**1. No consistent structure**
```openscad
// ❌ Chaotic organization
// ... random parameters scattered
module foo() { ... }
// ... more parameters
function bar() { ... }
// ... more modules
```

**2. Magic numbers everywhere**
```openscad
// ❌ Numbers with no context
cube([100, 60, 40], center=true);  // Where's 100 come from?
translate([0, 0, 20]) sphere(r=10);  // Why 20?
```

**3. Functions doing too much**
```openscad
// ❌ Complex, unclear
function calc(l, w, h, t, m, c) = ...  // What do m and c mean?

// ✅ Clear, focused
function interior_l(l, t) = l - 2*t;
function interior_w(w, t) = w - 2*t;
function margin_fit(nominal, fit) = nominal + fit;
```

### Solution: Use Strict 5-Layer Pattern

```openscad
// === PARAMETERS ===         (all config, top of file)
// === INCLUDES ===           (libraries, after params)
// === FUNCTIONS ===          (computed values)
// === MODULES ===            (geometry building blocks)
// === RENDER ===             (single entry point, bottom)
```

### Solution Checklist

- [ ] First 30 lines: PARAMETERS only
- [ ] Next 10 lines: INCLUDES only
- [ ] Next 30 lines: FUNCTIONS only
- [ ] Next N lines: MODULES only
- [ ] Last 10 lines: RENDER only
- [ ] Every parameter has a comment
- [ ] Every function has a name explaining what it computes
- [ ] No hard-coded numbers below line 30

---

## Problem: Can't Test or Debug Designs

### Symptom
Hard to check if design is correct before printing, mysterious errors

### Causes

**1. No way to visualize individual parts**
```openscad
// ❌ Can't see parts separately
module assembly() {
    part_a();
    part_b();
    part_c();
    // Which one is wrong?
}

// ✅ Can toggle visibility
include_a = true;
include_b = true;
include_c = true;

module assembly() {
    if (include_a) part_a();
    if (include_b) part_b();
    if (include_c) part_c();
}
```

**2. No clearance verification**
```openscad
// ✅ Add comments showing expected clearances
peg_dia = 4;
fit_margin = 0.3;
// Peg hole should be 4.3mm
// Clearance: 0.3mm (sliding fit)

hole_dia = peg_dia + fit_margin;
cylinder(d=hole_dia, h=10);
```

**3. Can't measure exported parts**
- Use OpenSCAD measurement tool
- Select two points, read distance in status bar
- Verify critical dimensions before export

### Solution Checklist

- [ ] Add `debug_mode = true;` toggle parameter
- [ ] Add color to identify parts
- [ ] Add `%` prefix to semi-transparent parts
- [ ] Use `echo()` to print dimensions to console
- [ ] Measure critical dimensions before exporting
- [ ] Do test print of critical features first

---

## Problem: Changes to One File Don't Update Others

### Symptom
Changed parameter in assembly.scad, but parts/body.scad doesn't update

### Causes

**1. Using `use <params.scad>` instead of `include`**
```openscad
// ❌ WRONG - use doesn't execute code
use <params.scad>;  // Doesn't load parameters!

// ✅ CORRECT - include executes
include <params.scad>;  // Loads all parameters
```

**2. Parameters defined in multiple files**
```openscad
// assembly.scad
base_l = 100;

// body.scad
base_l = 100;  // Duplicate! Won't update

// ✅ CORRECT: One file
// params.scad
base_l = 100;

// assembly.scad + body.scad both:
include <params.scad>;
```

### Solution Checklist

- [ ] Single params.scad file with all parameters
- [ ] All files: `include <path/to/params.scad>;`
- [ ] No parameters defined in other files
- [ ] Use `include` (not `use`) for params
- [ ] Use `use` (not `include`) for module libraries

---

## Problem: STL File is Huge or Corrupted

### Symptom
Export produces 500MB+ file, or STL won't open in slicer

### Causes

**1. $fn too high**
```openscad
// ❌ WRONG
$fn = 500;  // Produces massive mesh

// ✅ CORRECT
$fn = 100;  // High quality, reasonable size
```

**2. Unnecessary detail in subtracted geometry**
```openscad
// ❌ Creates excess geometry
difference() {
    sphere(r=50, $fn=200);
    sphere(r=40, $fn=200);  // Subtracted, still high detail!
}

// ✅ Reduce subtracted detail
difference() {
    sphere(r=50, $fn=100);
    sphere(r=40, $fn=32);   // Subtracted, lower detail
}
```

### Solution Checklist

- [ ] Set $fn = 100 (not higher)
- [ ] Reduce $fn for non-visible/subtracted geometry
- [ ] Check file size before importing to slicer
- [ ] Export → STL (not STL binary, unless specified)
- [ ] Verify in slicer before printing

---

## Problem: Union/Difference Operations Look Wrong

### Symptom
Boolean operations (`union`, `difference`) produce unexpected shapes

### Causes

**1. Geometry doesn't actually intersect**
```openscad
// ❌ Gap between parts - difference does nothing
cube([100, 60, 40], center=true);
translate([50.1, 0, 0]) cube([50, 60, 40], center=true);

// ✅ Actually overlaps
cube([100, 60, 40], center=true);
translate([40, 0, 0]) cube([50, 60, 40], center=true);
```

**2. Z-fighting (surfaces exactly on top of each other)**
```openscad
// ❌ Surfaces at exact same Z - rendering glitches
difference() {
    cube([100, 60, 40], center=true);
    translate([0, 0, 0]) cube([96, 56, 38], center=true);  // Exact depth!
}

// ✅ Slightly offset to prevent Z-fighting
difference() {
    cube([100, 60, 40], center=true);
    translate([0, 0, 0.1]) cube([96, 56, 38], center=true);  // Tiny offset
}
```

### Solution Checklist

- [ ] Verify geometry overlaps (use transparency to see)
- [ ] Use small offsets (0.1mm) to prevent Z-fighting
- [ ] Preview with transparency: `%module();`
- [ ] Render (F6) not just Preview (F5) to see final result

---

## Quick Diagnosis Flowchart

```
Issue occurs
├─ Render is slow
│  └─ Set $fn = 32, use $fn = 100 only for export
├─ Parts don't fit
│  └─ Add fit_margin parameter, use in hole diameter
├─ Dimensions wrong
│  └─ Verify parameters, check all files include params.scad
├─ Code is messy
│  └─ Follow 5-layer pattern (PARAMS, INCLUDES, FUNCTIONS, MODULES, RENDER)
├─ Can't test parts
│  └─ Add include_X toggles and debug_mode
├─ Changes don't propagate
│  └─ Use single params.scad, include it everywhere
├─ STL file huge
│  └─ Reduce $fn, lower detail in hidden geometry
└─ Boolean operations wrong
   └─ Check overlap, add small offsets to prevent Z-fighting
```

---

## When In Doubt

1. **Check $fn** - Is it appropriate for preview vs. export?
2. **Check parameters** - Are they defined at the top?
3. **Check composition** - Can you test each module independently?
4. **Check structure** - Does the file follow 5-layer pattern?
5. **Check tolerance** - Are fit margins parameterized?
6. **Measure in OpenSCAD** - Use cursor to verify dimensions
7. **Do a test print** - Catch issues before full-size print
