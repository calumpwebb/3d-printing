# 3D Printing Design Assistant

## Context
Helping design 3D printed parts for various use cases.

## Tools
- **OpenSCAD** - parametric 3D CAD modeler using code

## Units
- **All code in mm** - user may mention inches, convert to mm (1 inch = 25.4mm)

## Workflow
- Keep designs in a **single .scad file** per session
- Create a new file each session unless user specifies loading an existing one
- Code along with the user, iterating on designs

## File Naming
- Use descriptive names based on the part being designed
- Example: `phone_stand.scad`, `cable_clip.scad`

## Print Orientation
- **Always lay pieces flat on the X,Y plane** for printing and assembly
- Z should be the print height (layers build up in Z)
- Rotate pieces so largest flat surface is on the bed (Z=0)
- **Center individual print pieces at origin (0,0)** in X and Y

## Shared Modules & Code Reuse

This project uses OpenSCAD's module system for reusable components.

### Library File Structure
- **`lib/common.scad`** - Shared modules for common parts (pegs, holes, walls, etc.)
- Individual `.scad` files `use <lib/common.scad>` to access shared modules
- Never `include` the library—use `use` instead to avoid execution duplication

### Using Shared Modules
In your design file, at the top after parameters:
```scad
use <lib/common.scad>;
```

Then call modules like:
```scad
peg(diameter=4, height=15);
box_shell(length=100, width=60, height=40, wall_t=2);
mounting_wall(width=50, depth=30, height=40);
```

### Adding New Modules to lib/common.scad
1. Write the module following the **3-layer pattern**: parameters at top, helpers/functions, then modules
2. Always use default parameters that work standalone
3. Add documentation comment explaining what it does
4. Test with `example_*.scad` before committing

### Example Files
- **`example_container_with_pegs.scad`** - Shows using `peg()`, `box_shell()`, grid patterns, and assembly visualization

### Module Naming Convention
- **Pegs/holes:** `peg()`, `peg_hole()`, `countersink_hole()`
- **Shapes:** `box_shell()`, `rounded_edges()`, `mounting_wall()`
- **Fasteners:** `snap_clip()`
- **Utilities:** `interior_dimension()`, `with_clearance()`, `preview()`
