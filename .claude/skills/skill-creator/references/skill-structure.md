# Skill Structure & Requirements

## Frontmatter Requirements

Skills must use only these allowed frontmatter properties:

| Property        | Required | Description                                                              |
| --------------- | -------- | ------------------------------------------------------------------------ |
| `name`          | Yes      | Hyphen-case, max 64 chars                                                |
| `description`   | Yes      | Max 1024 chars, no angle brackets                                        |
| `license`       | No       | MIT, Apache-2.0, etc.                                                    |
| `allowed-tools` | No       | Restrict tool access                                                     |
| `model`         | No       | Model to use (e.g., claude-haiku-4-5-20251001, claude-sonnet-4-20250514) |

**Example:**

```yaml
---
name: my-skill
description: What this skill does and when to use it
license: MIT
model: claude-haiku-4-5-20251001
---
```

## Directory Structure

A complete skill follows this structure:

```
~/.claude/skills/{skill-name}/
├── SKILL.md                    # Main entry point (required)
├── references/                 # Deep documentation (optional)
│   ├── patterns.md
│   ├── examples.md
│   └── ...
├── assets/                     # Templates and resources (optional)
│   └── templates/
│       └── template.txt
└── scripts/                    # Automation scripts (optional)
    ├── validate.py
    ├── generate.py
    └── state.py
```

### SKILL.md (Required)

- Main entry point for the skill
- Contains frontmatter + markdown body
- Keep under 500 lines
- Use progressive disclosure: keep main SKILL.md lean and reference detailed files

### references/ (Optional)

- Deep documentation on complex topics
- Loaded by Claude only when referenced
- Examples: frameworks, specifications, detailed guides
- Named descriptively (e.g., `multi-lens-framework.md`)

### assets/ (Optional)

- Templates for skill outputs
- Example files and samples
- Configuration templates
- Resources for generating artifacts

### scripts/ (Optional)

Scripts enable skills to be **agentic** - capable of autonomous operation with self-verification.

| Category             | Purpose                         | When to Include              |
| -------------------- | ------------------------------- | ---------------------------- |
| **Validation**       | Verify outputs meet standards   | Skill produces artifacts     |
| **Generation**       | Create artifacts from templates | Repeatable artifact creation |
| **State Management** | Track progress across sessions  | Long-running operations      |
| **Transformation**   | Convert/process data            | Data processing tasks        |
| **Calculation**      | Compute metrics/scores          | Scoring or analysis          |

**Script Requirements:**

- Python 3.x with standard library only (graceful fallbacks for extras)
- `Result` dataclass pattern for structured returns
- Exit codes: 0=success, 1=failure, 10=validation failure, 11=verification failure
- Self-verification where applicable
- Documented in SKILL.md with usage examples

## Validation Workflow

Before distributing a skill, run validation:

```bash
# Quick validation (checks frontmatter, basic structure)
python scripts/quick_validate.py ~/.claude/skills/my-skill/

# Full validation (comprehensive checks)
python scripts/validate-skill.py ~/.claude/skills/my-skill/

# Package for distribution
python scripts/package_skill.py ~/.claude/skills/my-skill/ ./dist
```

### Validation Checklist

- [ ] Frontmatter contains only allowed properties
- [ ] Name is hyphen-case, ≤64 chars
- [ ] Description ≤1024 chars, no `<` or `>`
- [ ] All referenced files exist
- [ ] Scripts (if present) are executable
- [ ] No placeholder text in any file
- [ ] All directory paths use forward slashes
