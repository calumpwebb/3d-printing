---
name: skill-creator
description: Creates production-ready Claude Code skills through autonomous analysis, specification, generation, and multi-agent review. Use when you need to build new skills or refine existing ones to meet quality standards.
model: claude-haiku-4-5-20251001
---

# SkillCreator 3.2 - Ultimate Meta-Skill

Create categorically the best possible Claude Code skills.

---

## Quick Start

Tell me what skill you need:

```
Create a skill for automated code review
```

The skill will be built autonomously with full analysis, verification, and multi-agent review.

---

## When to Use This Skill

Use SkillCreator when you:

- Need to build a new skill for a specific task
- Want to ensure a skill meets quality standards
- Need structured analysis before creating one
- Want multiple review passes before finalization

## Triggers

Claude auto-activates this skill when you ask to:

- `create a skill for {purpose}`
- `build a skill that {does something}`
- `I need a skill to {goal}`
- `design a new skill for {domain}`
- `create a Claude skill for {task}`

---

## Process Overview

```
Your Request
    │
    ▼
┌─────────────────────────────────────────────────────┐
│ Phase 1: DEEP ANALYSIS                              │
│ • Expand requirements (explicit, implicit, unknown) │
│ • Apply 11 thinking models + Automation Lens        │
│ • Question until no new insights (3 empty rounds)   │
│ • Identify automation/script opportunities          │
├─────────────────────────────────────────────────────┤
│ Phase 2: SPECIFICATION                              │
│ • Generate XML spec with all decisions + WHY        │
│ • Include scripts section (if applicable)           │
│ • Validate timelessness score ≥ 7                   │
├─────────────────────────────────────────────────────┤
│ Phase 3: GENERATION                                 │
│ • Write SKILL.md with fresh context                 │
│ • Generate references/, assets/, and scripts/       │
├─────────────────────────────────────────────────────┤
│ Phase 4: SYNTHESIS PANEL                            │
│ • 3-4 Opus agents review independently              │
│ • Script Agent added when scripts present           │
│ • All agents must approve (unanimous)               │
│ • If rejected → loop back with feedback             │
└─────────────────────────────────────────────────────┘
    │
    ▼
Production-Ready Agentic Skill
```

**Key principles:**

- Evolution/timelessness is the core lens (score ≥ 7 required)
- Every decision includes WHY
- Zero tolerance for errors
- Autonomous execution at maximum depth
- Scripts enable self-verification and agentic operation

---

## Skill Structure & Validation

See [references/skill-structure.md](references/skill-structure.md) for:

- Frontmatter requirements and validation
- Directory structure guidelines
- Script organization and patterns
- Validation and packaging workflows

For validation and packaging:

```bash
python scripts/quick_validate.py ~/.claude/skills/my-skill/
python scripts/validate-skill.py ~/.claude/skills/my-skill/
python scripts/package_skill.py ~/.claude/skills/my-skill/ ./dist
```

---

## Anti-Patterns

| Avoid               | Why                      | Instead                     |
| ------------------- | ------------------------ | --------------------------- |
| Duplicate skills    | Bloats registry          | Check existing first        |
| Single trigger      | Hard to discover         | 3-5 varied phrases          |
| No verification     | Can't confirm success    | Measurable outcomes         |
| Over-engineering    | Complexity without value | Start simple                |
| Missing WHY         | Can't evolve             | Document rationale          |
| Invalid frontmatter | Can't package            | Use allowed properties only |

---

## Verification Checklist

After creation:

- [ ] Frontmatter valid (only allowed properties)
- [ ] Name is hyphen-case, ≤64 chars
- [ ] Description ≤1024 chars, no `<` or `>`
- [ ] 3-5 trigger phrases defined
- [ ] Timelessness score ≥ 7
- [ ] `python scripts/quick_validate.py` passes

---

## Detailed Process

See [references/phases.md](references/phases.md) for complete details on each phase:

---

## References

- [Regression Questions](references/regression-questions.md) - Complete question bank (7 categories)
- [Multi-Lens Framework](references/multi-lens-framework.md) - 11 thinking models guide
- [Specification Template](references/specification-template.md) - XML spec structure
- [Evolution Scoring](references/evolution-scoring.md) - Timelessness evaluation
- [Synthesis Protocol](references/synthesis-protocol.md) - Multi-agent panel details
- [Script Integration Framework](references/script-integration-framework.md) - When and how to create scripts
- [Script Patterns Catalog](references/script-patterns-catalog.md) - Standard Python patterns

---

## Related Skills

| Skill                  | Relationship                   |
| ---------------------- | ------------------------------ |
| skill-composer         | Can orchestrate created skills |
| claude-authoring-guide | Deeper patterns reference      |
| codereview             | Pattern for multi-agent panels |
| maker-framework        | Zero error standard source     |

---

## Extension Points

1. **Additional Lenses:** Add new thinking models to `references/multi-lens-framework.md`
2. **New Synthesis Agents:** Extend panel beyond 4 agents for specific domains
3. **Custom Patterns:** Add architecture patterns to selection guide
4. **Domain Templates:** Add domain-specific templates to `assets/templates/`
5. **Script Patterns:** Add new patterns to `references/script-patterns-catalog.md`
6. **Script Categories:** Extend the 7 script categories for new use cases

---

## Changelog

### v3.2.0 (Current)

- Added Script Integration Framework for agentic skills
- Added 4th Script Agent to synthesis panel (conditional)
- Added Phase 1D: Automation Analysis
- Added Automation Lens questions to regression questioning
- Created `references/script-integration-framework.md`
- Created `references/script-patterns-catalog.md`
- Created `assets/templates/script-template.py`
- Updated skill-spec-template.xml with `<scripts>` section
- Updated validate-skill.py with script validation
- Skills can now include self-verifying Python scripts

### v3.1.0

- Added progressive disclosure structure
- Fixed frontmatter for packaging compatibility
- Added validation & packaging section
- Deep dive sections now collapsible

### v3.0.0

- Complete redesign as ultimate meta-skill
- Added regression questioning loop
- Added multi-lens analysis framework (11 models)
- Added evolution/timelessness core lens
- Added multi-agent synthesis panel

### v2.0.0

- Pattern selection guide
- Quality standards checklist

### v1.0.0

- Basic skill structure
