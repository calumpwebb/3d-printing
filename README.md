# 3D Printing Design Projects

A collection of 3D printing designs using OpenSCAD with a focus on parametric, reusable component design.

## Project Structure

```
printing/
├── lib/
│   └── common.scad          # Shared reusable modules for all projects
├── example_container_with_pegs.scad   # Example showing module usage
├── CLAUDE.md                # Project context & guidelines
├── README.md                # This file
└── [your-design].scad       # Your individual design files
```

## Quick Start

### Creating a New Design

1. **Create a new `.scad` file** with a descriptive name (e.g., `my_box.scad`)

2. **Start with the 3-layer structure:**
   ```scad
   // === PARAMETERS ===
   base_length = 100;
   base_width = 60;
   base_height = 40;
   wall_thickness = 2;

   // === INCLUDE SHARED MODULES ===
   use <lib/common.scad>;

   // === CUSTOM MODULES ===
   module my_part(length=base_length, width=base_width) {
       // Your design here
   }

   // === RENDER ===
   my_part();
   ```

3. **Use shared modules from `lib/common.scad`:**
   ```scad
   peg(diameter=4, height=15);
   box_shell(length=100, width=60, height=40, wall_t=2);
   peg_hole(diameter=4.3, height=20);
   ```

4. **Design with parameters, not magic numbers** — this lets you create variants by changing one line

## Shared Modules Reference

All modules are in `lib/common.scad`. Common ones:

### Pegs & Holes
- **`peg(diameter=4, height=10, center_z=true)`** - Cylindrical peg for fitting into holes
- **`peg_hole(diameter=4.3, height=10, depth_from_top=true)`** - Hole sized for peg fit

### Shapes & Structures
- **`box_shell(length=100, width=60, height=40, wall_t=2, bottom_t=0)`** - Hollow box with walls
- **`rounded_edges(size=[100,60,40], radius=3)`** - Round the corners
- **`mounting_wall(width=50, depth=30, height=40, thickness=3)`** - Simple wall for mounting

### Fasteners
- **`countersink_hole(diameter=8, depth=3, hole_diameter=3.2)`** - Flush-fit bolt hole
- **`snap_clip(width=20, thickness=1.5, depth=8)`** - Rectangular snap fit clip

### Utilities
- **`interior_dimension(outer, wall_thickness)`** - Calculate inner size of hollow part
- **`with_clearance(dimension, margin=0.3)`** - Add clearance for fit tolerance
- **`preview(part_module, transparency=0.3)`** - Transparent preview in assembly

## Units

**All dimensions are in millimeters (mm).**

If you see dimensions in inches elsewhere, convert:
- 1 inch = 25.4 mm

## Print Orientation

Always design with:
- **X, Y plane** = print bed surface (horizontal)
- **Z axis** = print height (vertical, layers stack upward)
- **Center pieces at origin (0,0)** in X and Y
- **Largest flat surface on the bed** for stability

This means OpenSCAD's `center=true` for cubes places the part centered at origin, which is correct.

## Example: Using Modules

See `example_container_with_pegs.scad` for a complete example showing:
- Box with internal peg holes in a grid pattern
- Colored preview of pegs for assembly
- Optional lid
- Grid iteration patterns
- Proper use of the 3-layer structure

To see it: open `example_container_with_pegs.scad` in OpenSCAD.

## Adding New Modules to the Library

Before adding a module to `lib/common.scad`:

1. **It should be reusable** - used in 2+ projects, or a fundamental part
2. **Follow the pattern:**
   ```scad
   // Clear documentation comment
   module my_module(param1=default1, param2=default2) {
       // Implementation
   }
   ```
3. **Test it** in an example file first
4. **Add documentation** - what is it, what do parameters do
5. **Use sensible defaults** - the module should work standalone

## Tips for Parametric Design

1. **Define all dimensions at the top** - no magic numbers in module bodies
2. **Use functions for repeated calculations:**
   ```scad
   function interior_dim(outer, wall) = outer - 2*wall;
   ```
3. **Create variants by changing one parameter:**
   ```scad
   // Small version
   base_length = 50;
   // vs. Large version
   base_length = 150;
   // Everything else scales automatically if designed right
   ```
4. **Use `$fn=32` for cylinders** (pegs, holes) to make them smooth
5. **Use `$fn=16` for spheres** (rounded corners) - less detail, faster renders

## Common Patterns

### Grid of Holes
```scad
for (x = [-30, 0, 30]) {
    for (y = [-20, 0, 20]) {
        translate([x, y, 0])
            peg_hole(diameter=4.3, height=10);
    }
}
```

### Hollow Box with Bottom
```scad
box_shell(length=100, width=60, height=40, wall_t=2, bottom_t=3);
```

### Assembly with Transparency
```scad
container_body();
color([1, 0.5, 0]) peg(diameter=4, height=15);  // Orange peg
color([0.8, 0.8, 0.8, 0.7]) lid();              // Gray transparent lid
```

## OpenSCAD Tips

- **Render time too long?** Lower `$fn` values during iteration, increase only for export
- **Preview vs. Render:** Press `F5` to preview (fast), `F6` to render (slow but more accurate)
- **STL Export:** Design → Export as STL

## Resources

- [OpenSCAD Official](https://openscad.org/)
- [OpenSCAD Cheat Sheet](https://openscad.org/cheatsheet/)
- [Parametric Design Guide](https://blog.prusa3d.com/parametric-design-in-openscad_8758/)
