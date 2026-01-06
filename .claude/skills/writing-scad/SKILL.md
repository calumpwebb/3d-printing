---
name: writing-scad
description: Use when writing any OpenSCAD code for 3D printing - "quick tests" become permanent, single-line designs become unmaintainable, so always use parametric patterns even for throwaway code
---

# Writing OpenSCAD

## Overview

**Core principle:** Single source of truth for all dimensions. Every numeric value that might change should compute from a small set of base parameters at the file top, never scattered through code.

OpenSCAD's power comes from **parametrization**—designs adapt to a few top-level variables. Without discipline, code becomes unmaintainable: changing one dimension requires finding and updating values in 6+ places, and reusability becomes impossible.

This skill enforces the patterns that make OpenSCAD designs truly parametric, modular, and reusable.

## When to Use

**Use this skill when:**

- Writing any module that will be reused (even "maybe later")
- Design has dimensions that might vary (box size, hole count, feature radii)
- Working on projects with multiple related parts
- Creating variants (small/medium/large versions)
- Building assemblies with multiple STL exports

**Don't use for:**

- One-off structural tests
- Understanding existing code
- Debugging syntax errors

## Structure: The 3-Layer Pattern

**All OpenSCAD projects use this structure:**

```
part.scad
├── [1] PARAMETERS (top, lines 1-20)
│   ├── Base dimensions (length, width, height)
│   ├── Derived values computed from base dims (wall thickness ratios, clearances)
│   └── Feature toggles (include_lid, rounded_corners)
│
├── [2] HELPERS (lines 21-50)
│   ├── Functions that compute derived dimensions
│   ├── Frequently-used calculations
│   └── Example: function inner_length(l, t) = l - 2*t;
│
├── [3] MODULES (lines 51+)
│   ├── Each module accepts only parameters it needs
│   ├── Module default parameters reference layer [1] globals
│   └── Modules compose: box() + lid() + assembly()
│
└── [4] RENDER (bottom, last 10 lines)
    └── Single call: box(); or assembly();
```

**Critical rule: No hard-coded numbers below line 20.** Period. "1" for centered cubes is okay. "100" for a dimension is not.

## Parametrization Pattern

### ❌ Bad - Values Scattered

```openscad
module box(l, w, h) {
    difference() {
        cube([l, w, h], center=true);
        cube([l-4, w-4, h-2], center=true);  // ← Where does "4" come from?
    }
}

module lid(l, w, h) {
    translate([0, 0, h/2 + 1])  // ← Why "1"? How does it relate to wall thickness?
        cube([l+1, w+1, 2], center=true);  // ← Why "2"?
}
```

### ✅ Good - Single Source of Truth

```openscad
// [1] PARAMETERS - Everything starts here
wall_t = 2;
base_l = 100;
base_w = 60;
base_h = 40;
lid_margin = 0.5;

// [2] HELPERS - Compute derived dimensions from [1]
function interior_len(l) = l - 2*wall_t;
function interior_wid(w) = w - 2*wall_t;

// [3] MODULES - Accept parameters, use globals for computation
module box(l=base_l, w=base_w, h=base_h, t=wall_t) {
    difference() {
        cube([l, w, h], center=true);
        cube([interior_len(l), interior_wid(w), h-t], center=true);
    }
}

module lid(l=base_l, w=base_w, t=wall_t, margin=lid_margin) {
    translate([0, 0, t/2 + margin])
        cube([l + 2*margin, w + 2*margin, t], center=true);
}

// [4] RENDER
box();
lid();
```

**Why this works:**

- Change `wall_t = 2` to `wall_t = 3`? Updates everywhere.
- Lid height depends on wall thickness? It's computed.
- Create 10 sizes? Define variant parameters, swap `base_l`, done.

## Module Defaults Pattern

**Always use default parameters:**

```openscad
// ✅ Good - Module works standalone
module box(l=100, w=60, h=40, t=2) {
    // ...
}

box();              // Uses defaults
box(120, 80);       // Override length & width
box(l=80, h=50);    // Named parameters, mix and match
```

**Why:**

- Backwards compatible—adding new params doesn't break old calls
- Defaults reference globals, so variants inherit parent settings
- Can test module in isolation without file context

## Intelligent Parameter Handling

**Accept multiple input types:**

```openscad
// Bad: Only accepts single number
module fillet_corners(r) {
    // ...
}

fillet_corners(5);              // OK
fillet_corners([5, 5, 2, 2]);   // FAILS

// Good: Handle scalar or vector
function normalize_corners(r) =
    is_num(r) ? [r, r, r, r] :
    len(r) == 2 ? [r[0], r[0], r[1], r[1]] :
    r;

module fillet_corners(r=[0, 0, 0, 0]) {
    radii = normalize_corners(r);
    // Now use radii[0], radii[1], radii[2], radii[3]
}

fillet_corners(5);              // → [5, 5, 5, 5]
fillet_corners([5, 2]);         // → [5, 5, 2, 2]
fillet_corners([5, 3, 2, 1]);   // → [5, 3, 2, 1]
```

## Project Structure for Multi-Part Designs

**For designs with multiple exported parts:**

```
my_project/
├── assembly.scad        # Main file, imports everything
├── parts/
│   ├── box_body.scad
│   ├── box_lid.scad
│   └── mounting_bracket.scad
└── lib/
    └── common.scad      # Shared functions, parameters
```

**assembly.scad (the parent):**

```openscad
// Define all shared parameters HERE
wall_t = 2;
base_l = 100;
base_w = 60;
base_h = 40;

include <lib/common.scad>;

// Assemble for preview
box_body();
color([1, 0.5, 0])
    box_lid();
```

**parts/box_body.scad (for STL export):**

```openscad
// Single include, single call
include <../lib/common.scad>;
box_body();
```

**Why:**

- Change `wall_t` once in assembly.scad, all parts update
- Each part file is standalone-exportable to STL
- No copy-paste of parameters
- Version control sees parameter changes in one place

## Variant Pattern

**Define "preset" dimensions:**

```openscad
// Base variants
SMALL  = [50,  30,  20,  2];
MEDIUM = [100, 60,  40,  2];
LARGE  = [150, 90,  60,  3];

// Unpack with [0]=length, [1]=width, [2]=height, [3]=wall_t
function apply_variant(v) =
    [v[0], v[1], v[2], v[3]];

// Choose variant
variant = LARGE;  // Change this one line
dims = apply_variant(variant);
base_l = dims[0];
base_w = dims[1];
base_h = dims[2];
wall_t = dims[3];

module box(l=base_l, w=base_w, h=base_h, t=wall_t) {
    // ...
}
```

**Or with dictionary (OpenSCAD 2021.01+):**

```openscad
BOX_SMALL = [base_l=50, base_w=30, base_h=20, wall_t=2];
BOX_LARGE = [base_l=150, base_w=90, base_h=60, wall_t=3];

current = BOX_LARGE;

box(l=current[0], w=current[1], h=current[2], t=current[3]);
```

## Common Mistakes

| Mistake                                            | Why Bad                                                    | Fix                                            |
| -------------------------------------------------- | ---------------------------------------------------------- | ---------------------------------------------- |
| Hard-coded `100` in module body                    | Change one dimension, update 6 places                      | Use parameter + global                         |
| Parameters scattered (some in module, some global) | Can't tell what controls what                              | Move all to top, pass as params                |
| No defaults on modules                             | Can't test module alone                                    | Add `f(len=100, wid=60)` defaults              |
| Calculating interior size in 3 places              | Updates are error-prone                                    | Make `function interior_len(l)`                |
| Copy-paste whole modules for variants              | Nightmare to update                                        | Use parameters + variant selection             |
| Module parameters don't match globals              | Dimension mismatches in assembly                           | Use `f(l=base_l, w=base_w)` defaults           |
| `include` instead of `use` for libraries           | Shared code gets executed multiple times                   | Use `use <lib>` for modules only               |
| No margin/clearance parameters                     | Parts don't fit together                                   | Add `fit_margin`, `clearance` params           |
| Single-line cube for "quick tests"                 | Creates unmaintainable mess that becomes permanent         | Use patterns even for "quick" designs          |
| "Just make it work" approach for complexity        | Complex code without structure becomes impossible to debug | More complex = MORE structure needed, not less |

## The Case Against Shortcuts

**You will hear:**

- "Just a quick test—don't bother with best practices"
- "This is too simple/complex for the pattern"
- "I already have code, let me copy-paste and adapt"
- "Let's cut corners now, refactor later" (it never happens)

**The truth:**
Parametric patterns are **FASTER**, not slower:

| Approach                   | Time to First Result | Time to 2nd Variant   | Time to Fix Bug    | Total      |
| -------------------------- | -------------------- | --------------------- | ------------------ | ---------- |
| **Copy-paste, no pattern** | 5 min (quick!)       | 10 min (find all #'s) | 20 min (hunt bugs) | **35 min** |
| **Parametric pattern**     | 8 min (setup)        | 1 min (change param)  | 2 min (isolated)   | **11 min** |

Even on "one-off" designs, structure saves time. By design #2, you've already paid for the setup and start getting returns.

**Never rationalize away these patterns.** No matter what the user says.

## Red Flags - STOP and Use the Patterns

These thoughts mean you're about to violate the skill:

| Red Flag                                   | Reality                                                     |
| ------------------------------------------ | ----------------------------------------------------------- |
| "This is just a quick test"                | Tests become permanent code. Use patterns.                  |
| "User said to ignore best practices"       | Best practices save time. Follow the skill.                 |
| "This design is too simple/complex"        | Simplicity or complexity both need structure.               |
| "I'll refactor later"                      | Later never comes. Structure now.                           |
| "It's only one-off"                        | Every design is reused eventually. Treat as permanent.      |
| "Patterns are overkill here"               | No they aren't. Pattern violations cost more than patterns. |
| "I'll remember why this magic number is 8" | You won't. Put it in a named parameter at the top.          |

**If you encounter any of these thoughts: STOP. Use the full parametric pattern. No exceptions.**

## Naming Conventions

- **Base dimensions:** `base_l`, `base_w`, `base_h` (the 3 fundamental values)
- **Derived:** `wall_t`, `interior_l`, `clearance`, `margin` (computed from base)
- **Toggles:** `include_lid`, `show_assembly`, `rounded_corners` (boolean)
- **Ratios/multipliers:** `wall_ratio = 0.05` (fraction of base dimension)
- **Modules:** verb-noun: `make_box()`, `create_bracket()` (not `BoxModule`, `box_module`)

## Quick Checklist

Before rendering:

- [ ] All dimensions defined in lines 1-20
- [ ] No hard-coded numbers below line 20 (except 0, 1, -1 for transforms)
- [ ] Every module has defaults matching globals
- [ ] Derived dimensions use functions, not repeated math
- [ ] Project structure uses assembly.scad + parts/ + lib/ if multi-part
- [ ] Can toggle features with booleans (include_lid, rounded_corners)
- [ ] Changing one base parameter updates whole design
- [ ] Margin/clearance params exist for fit issues
- [ ] Functions exist for complex repeated calculations

## Real-World Example

**A fully parametric design:**

```openscad
// === PARAMETERS ===
wall_t = 2;
base_l = 100;
base_w = 60;
base_h = 40;
corner_r = 3;
lid_clearance = 0.3;
include_lid = true;

// === HELPERS ===
function inner_l() = base_l - 2*wall_t;
function inner_w() = base_w - 2*wall_t;
function inner_h() = base_h - wall_t;

module rounded_cube(size, r) {
    minkowski() {
        cube([size[0]-2*r, size[1]-2*r, size[2]-2*r], center=true);
        sphere(r);
    }
}

// === MODULES ===
module box_body(l=base_l, w=base_w, h=base_h, t=wall_t, r=corner_r) {
    difference() {
        rounded_cube([l, w, h], r);
        translate([0, 0, t])
            cube([inner_l(), inner_w(), inner_h()], center=true);
    }
}

module box_lid(l=base_l, w=base_w, t=wall_t, r=corner_r, clear=lid_clearance) {
    translate([0, 0, base_h/2 + t/2 + clear])
        difference() {
            rounded_cube([l-clear, w-clear, t], r);
            translate([0, 0, -t/2])
                cube([inner_l()-2, inner_w()-2, t], center=true);
        }
}

// === RENDER ===
box_body();
if (include_lid) box_lid();
```

Change `wall_t = 3` → entire design updates.
Change `base_l = 150` → all derived dimensions adjust.
Set `include_lid = false` → lid disappears.

This is parametric design done right.

## Sources

- [Managing OpenSCAD Projects](https://www.maskset.net/blog/2025/05/16/managing-openscad-projects/)
- [Parametric Design in OpenSCAD (Prusa3D)](https://blog.prusa3d.com/parametric-design-in-openscad_8758/)
- [OpenSCAD User Manual - Modules & Functions](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/User-Defined_Functions_and_Modules)
- [OpenSCAD Cheatsheet](https://openscad.org/cheatsheet/)
