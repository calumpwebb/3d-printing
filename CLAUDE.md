# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

3D printing design projects using OpenSCAD, a parametric CAD modeler that uses code-based design. The repository contains a shared library of reusable modules and individual project designs organized by purpose.

## Project Structure

```
printing/
├── lib/
│   └── common.scad              # Shared parametric modules (pegs, holes, walls, fasteners)
├── projects/
│   └── ${project_name}/
│       ├── *.scad               # Design source files (e.g., coaster.scad, macbook_holder.scad)
│       ├── *.stl                # Exported STL meshes for 3D printing (optional: can be in stl/)
│       ├── stl/                 # Optional: STL export directory (some projects use this)
│       │   └── *.stl
│       └── gcode/               # G-code files for 3D printer (sliced, ready to print)
│           └── *.gcode
├── CLAUDE.md                    # This file
├── README.md                    # User-facing design guide
└── *.scad                       # Root-level design files (one-off designs or temporary work)
```

### File Organization Details

**Per-project structure (`projects/${project_name}/`):**
- **`*.scad` files**: All OpenSCAD source designs in the project root
- **STL exports**: Place in project root OR in `stl/` subdirectory (consistency within a project)
- **G-code files**: Always go in `gcode/` subdirectory, organized by printer/settings/date
- **Naming convention for G-code**: `${design_name}_${nozzle}mm_${material}_${printer}_${duration}.gcode`
  - Example: `macbook_holder_bottom_0.3mm_PLA_MK3S_22h0m.gcode`

## Development Workflow

### Creating a New Design

1. **File location:** Create new `.scad` files in the project root or in a `projects/[name]/` subdirectory
2. **Naming:** Use descriptive names (e.g., `phone_stand.scad`, `cable_clip.scad`)
3. **Structure:** Follow the 3-layer pattern in all files:
   ```scad
   // === PARAMETERS ===
   base_length = 100;
   base_width = 60;
   // ... all parameters at top

   // === INCLUDE SHARED MODULES ===
   use <lib/common.scad>;

   // === CUSTOM MODULES ===
   module my_part() { /* ... */ }

   // === RENDER ===
   my_part();
   ```

### Working with OpenSCAD

- **Preview (F5):** Fast render for iteration
- **Render (F6):** Final high-quality render (slower, more accurate)
- **Export as STL:** Design → Export as STL (for 3D printing)
- **$fn parameter:** Controls circle/sphere smoothness (32 for pegs/holes, 16 for decorative, 100+ for exports)

### Design Principles

- **Units:** All dimensions in **millimeters (mm)**. Convert inches: 1 inch = 25.4mm
- **Origin:** Center individual print pieces at (0, 0) in X and Y
- **Orientation:** Design with X,Y as the print bed (horizontal) and Z as print height (vertical)
- **Flat surfaces:** Orient pieces so the largest flat surface rests on the print bed at Z=0
- **No magic numbers:** Always define dimensions as named parameters at the top of files
- **Parametric design:** Create variants by changing parameters, not by duplicating code

## Shared Module Library (lib/common.scad)

The library provides reusable modules for common printing components. Use with `use <lib/common.scad>`.

### Core Modules

**Geometry:**
- `peg(diameter=4, height=10, center_z=true)` - Cylindrical peg for fitting into holes
- `peg_hole(diameter=4.3, height=10, depth_from_top=true)` - Hole for peg fit (slightly oversized)
- `box_shell(length=100, width=60, height=40, wall_t=2, bottom_t=0)` - Hollow box with configurable walls

**Structures:**
- `mounting_wall(width=50, depth=30, height=40, thickness=3)` - Simple mounting bracket/wall
- `rounded_edges(size=[100,60,40], radius=3)` - Round corners using Minkowski sum

**Fasteners:**
- `countersink_hole(diameter=8, depth=3, hole_diameter=3.2)` - Flush-fit bolt hole with recess
- `snap_clip(width=20, thickness=1.5, depth=8)` - Simplified rectangular snap fit clip

**Utilities:**
- `interior_dimension(outer, wall_thickness)` - Calculate inner size of hollow parts
- `with_clearance(dimension, margin=0.3)` - Add clearance for tolerance fits
- `preview(part_module, transparency=0.3)` - Transparent preview for assembly visualization

### Adding to lib/common.scad

1. **Reusability threshold:** Module should be used in 2+ projects or be a fundamental primitive
2. **Documentation:** Include clear comment describing purpose and parameters
3. **Defaults:** All parameters must have sensible defaults so module works standalone
4. **Testing:** Test new modules in an example file before committing
5. **Pattern:** Follow the same structure as existing modules (no dependencies between modules unless documented)

## Common Design Patterns

**Grid of holes:**
```scad
for (x = [-30, 0, 30]) {
    for (y = [-20, 0, 20]) {
        translate([x, y, 0]) peg_hole(diameter=4.3, height=10);
    }
}
```

**Assembly with transparency:**
```scad
body();
color([1, 0.5, 0]) peg(diameter=4, height=15);              // Orange peg
color([0.8, 0.8, 0.8, 0.7]) lid();                          // Gray transparent lid
```

## Organization Notes

**Projects folder (`projects/`):**
- Use for designs that are complete, iterated, or referenced multiple times
- Each project gets its own subdirectory with a descriptive name (e.g., `macbook_holder`, `tolerance_test`)
- All source files (`.scad`) stay in the project root directory
- STL exports can be in the project root or in an `stl/` subdirectory (keep consistent within a project)
- G-code files always go in the `gcode/` subdirectory, with naming that includes printer settings and duration

**Root `.scad` files:**
- Use for one-off designs, quick explorations, or temporary work
- When a design becomes a completed project, move it to `projects/${project_name}/`

**Version control:**
- Commit `.scad` source files (parametric designs)
- Commit `.stl` files (tracking iterations)
- Commit `.gcode` files (record of successful prints with settings)
- `.DS_Store` files are already in `.gitignore`
