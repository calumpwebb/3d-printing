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
