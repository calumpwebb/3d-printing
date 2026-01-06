# writing-scad-v2

**Bulletproof OpenSCAD skill for parametric 3D printing designs**

---

## What's Inside

### Main Skill: `SKILL.md`
The complete guide to writing production-ready OpenSCAD code.

**Contents:**
- 4-layer pattern (strict structure for all files)
- Parameters (single source of truth)
- Functions (computed dimensions)
- Modules (reusable building blocks)
- Render (entry point)
- $fn decision tree (preview vs. export)
- Multi-part projects (assembly + parts)
- Tolerance & fit strategy
- Common patterns (grids, transparency, conditionals)
- Migration guide (converting existing code)
- Validation checklist
- Real-world complete example

**Key improvements over v1:**
- Explicit 4-layer pattern (not 3)
- $fn management guidelines
- Multi-part project structure
- Tolerance/clearance decision tree
- Migration guide from non-parametric code
- Performance optimization tips
- 15 detailed sections vs. 14 in v1

---

## References

### `references/anti-patterns.md`
10 common mistakes and how to fix them:
1. Magic numbers scattered
2. Hard-coded computations
3. Missing module defaults
4. No tolerance planning
5. Mixing `include`/`use` incorrectly
6. Parameters in multiple files
7. Copy-paste code for variants
8. Complex geometry without structure
9. No $fn management
10. Hard-coded positions

Each anti-pattern includes:
- ❌ Bad example
- ✅ Good example
- Why it's a problem
- How to fix it

### `references/troubleshooting.md`
Real-world debugging guide for 8 major issues:
1. Parts don't fit together
2. Render is slow
3. Module parameters don't work
4. Dimensions are wrong
5. Code is disorganized
6. Can't test/debug designs
7. Changes don't propagate to other files
8. STL file is huge
9. Union/difference looks wrong

Plus: Quick diagnosis flowchart

---

## Assets

### `assets/template.scad`
Copy-paste starting template with:
- Complete 5-layer structure
- Example modules (base_box, lid, support_posts)
- Parameter organization
- Comments explaining each section
- Validation checklist (in comments)
- Export instructions

Use this to start any new design—don't write from scratch.

---

## How to Use This Skill

### For New Designs
1. Copy `assets/template.scad` as starting point
2. Follow `SKILL.md` sections 1-5 (Parameters → Render)
3. Use `references/anti-patterns.md` to avoid common mistakes
4. Check validation checklist before exporting

### For Existing Designs
1. Review current structure against `SKILL.md` sections
2. Identify anti-patterns in `references/anti-patterns.md`
3. Use migration guide in `SKILL.md` section 10
4. Refactor one section at a time

### For Debugging Issues
1. Check `references/troubleshooting.md` for symptom
2. Apply suggested fixes
3. Verify against `references/anti-patterns.md`
4. Use validation checklist

### For Multi-Part Projects
1. See `SKILL.md` section 7 (Multi-Part Projects)
2. Create single `params.scad` file
3. Create `assembly.scad` (master file)
4. Create `parts/` subdirectory with individual files
5. All files `include <../params.scad>`

---

## Key Principles

### The 4-Layer Pattern
```
[1] PARAMETERS     → All config at top
[2] INCLUDES       → Libraries/shared code
[3] FUNCTIONS      → Computed dimensions
[4] MODULES        → Geometry building blocks
[5] RENDER         → Single entry point
```

### Single Source of Truth
- All dimensions are named parameters
- No hard-coded numbers below line 30
- Functions extract repeated math
- Multi-part projects share params.scad

### Parametric from Day One
- Every module has default parameters
- Features are boolean toggles
- Variants change one parameter
- Tolerances are intentional, not guessed

### Validation Before Export
- Use the 10-item checklist (in SKILL.md)
- Test each module independently
- Measure critical dimensions
- Do test prints first

---

## File Structure

```
writing-scad-v2/
├── SKILL.md                      # Main guide (15 sections)
├── README.md                     # This file
├── references/
│   ├── anti-patterns.md          # 10 mistakes + fixes
│   └── troubleshooting.md        # Debugging guide
└── assets/
    └── template.scad             # Copy-paste starter
```

---

## When NOT to Use This Skill

- Understanding existing code (use code review tools)
- Learning OpenSCAD syntax (use OpenSCAD manual)
- Debugging syntax errors (use OpenSCAD editor)

---

## Differences from v1

| Aspect | v1 | v2 |
|--------|----|----|
| Layers | 3 (PARAMS, MODULES, RENDER) | 4 (PARAMS, INCLUDES, FUNCTIONS, MODULES, RENDER) |
| $fn guidance | Mentioned | Comprehensive decision tree |
| Multi-part projects | Basic | Detailed with params.scad pattern |
| Tolerance strategy | Brief | Decision tree + implementation |
| Error prevention | 9 red flags | 10 anti-patterns with examples |
| Migration guide | None | Complete section |
| Troubleshooting | None | 9 real-world issues + flowchart |
| Template | None | Complete example file |
| References | Embedded | Separate files for deep dives |

---

## Questions This Skill Answers

- "How do I organize an OpenSCAD file?"
- "Where do parameters go?"
- "How do I avoid magic numbers?"
- "How do I make parametric designs?"
- "How do I structure multi-part projects?"
- "What clearance should parts have?"
- "Why is my render so slow?"
- "How do I debug dimension issues?"
- "How do I refactor existing code?"
- "Can I create variants without copy-paste?"
- "What's the difference between `include` and `use`?"
- "How do I make sure parts fit?"

---

## Real-World Example

See `SKILL.md` section 14 for a complete, production-ready design with:
- All 5 layers implemented
- Proper parameter organization
- Helper functions
- Multiple modules
- Assembly visualization
- Debug mode
- Validation checklist

---

## Version

**writing-scad-v2 (v1.0.0)**

Improvements from original writing-scad:
- ✓ Explicit INCLUDES layer
- ✓ FUNCTIONS layer for computed dimensions
- ✓ $fn management section
- ✓ Tolerance decision tree
- ✓ Migration guide
- ✓ Troubleshooting reference
- ✓ Anti-patterns with fixes
- ✓ Copy-paste template
- ✓ Performance tips

---

## Related Skills

- **writing-python-code** - Apply similar parametric patterns to Python
- **superpowers:systematic-debugging** - For complex issues
- **superpowers:brainstorming** - Before major design work

---

## Feedback

This skill is designed to be bulletproof—all patterns are battle-tested on real 3D printing projects. If you find edge cases or improvements, they're worth exploring.

**Key: Follow the 4-layer pattern strictly. Exceptions are rare and should be documented.**
