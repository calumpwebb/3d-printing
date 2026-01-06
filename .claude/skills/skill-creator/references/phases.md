# The 4-Phase Process

SkillCreator uses a structured 4-phase workflow to create production-ready skills.

---

## Phase 1: Deep Analysis

Transform the user's goal into comprehensive requirements and identify all considerations.

### 1A: Input Expansion

Expand the user's request into three categories:

```
USER INPUT: "Create a skill for X"
                │
                ▼
EXPLICIT REQUIREMENTS (what they literally asked for)
IMPLICIT REQUIREMENTS (what they expect but didn't say)
UNKNOWN UNKNOWNS (what they don't know they need)
DOMAIN CONTEXT (related skills, patterns, lessons)
```

Check for overlap:

- > 7/10 match: Use existing skill instead
- 5-7/10: Clarify distinction before proceeding
- <5/10: Proceed with new skill

### 1B: Multi-Lens Analysis

Apply all 11 thinking models systematically:

| Lens                 | Core Question                   | Application                  |
| -------------------- | ------------------------------- | ---------------------------- |
| **First Principles** | What's fundamentally needed?    | Strip convention, find core  |
| **Inversion**        | What guarantees failure?        | Build anti-patterns          |
| **Second-Order**     | What happens after the obvious? | Map downstream effects       |
| **Pre-Mortem**       | Why did this fail?              | Proactive risk mitigation    |
| **Systems Thinking** | How do parts interact?          | Integration mapping          |
| **Devil's Advocate** | Strongest counter-argument?     | Challenge every decision     |
| **Constraints**      | What's truly fixed?             | Separate real from assumed   |
| **Pareto**           | Which 20% delivers 80%?         | Focus on high-value features |
| **Root Cause**       | Why is this needed? (5 Whys)    | Address cause not symptom    |
| **Comparative**      | How do options compare?         | Weighted decision matrix     |
| **Opportunity Cost** | What are we giving up?          | Explicit trade-offs          |

Minimum: Scan all 11, apply 5+ in depth.

See: [multi-lens-framework.md](multi-lens-framework.md)

### 1C: Regression Questioning

Iteratively self-question until no new insights emerge:

1. Ask: "What am I missing?"
2. Simulate expert perspectives
3. Apply unused thinking models
4. Continue until 3 consecutive rounds yield nothing new

**Termination criteria:**

- Three empty rounds
- All 11 lenses applied
- ≥3 expert perspectives considered
- Evolution/timelessness evaluated
- Automation opportunities identified

See: [regression-questions.md](regression-questions.md)

### 1D: Automation Analysis

Identify script opportunities for agentic operation:

| Question                                  | Script Category |
| ----------------------------------------- | --------------- |
| What operations repeat identically?       | Generation      |
| What outputs need validation?             | Validation      |
| What state persists across sessions?      | State Mgmt      |
| Can the skill run overnight autonomously? | All categories  |
| How will Claude verify correct execution? | Verification    |

---

## Phase 2: Specification

Generate a complete XML specification documenting all analysis decisions.

The specification captures:

- **Metadata:** Name, iteration count, timelessness score
- **Context:** Problem statement, existing landscape, distinctiveness
- **Requirements:** Explicit, implicit, discovered
- **Architecture:** Pattern, phases, decision points
- **Scripts:** Inventory, agentic capabilities
- **Evolution:** Timelessness score (≥7 required), extension points, obsolescence triggers
- **Anti-patterns:** What to avoid + why + alternatives
- **Success Criteria:** Measurable verification methods

See: [specification-template.md](specification-template.md)

### Specification Validation Checklist

- [ ] All sections present, no placeholders
- [ ] Every decision includes WHY
- [ ] Timelessness score ≥ 7 with justification
- [ ] ≥2 extension points documented
- [ ] All requirements traceable to source
- [ ] Scripts section complete (if applicable)
- [ ] Agentic capabilities documented (if scripts present)

---

## Phase 3: Generation

Create the final skill from the specification in a fresh context.

### Generation Order

1. Create directory structure

   ```bash
   mkdir -p ~/.claude/skills/{skill-name}/references
   mkdir -p ~/.claude/skills/{skill-name}/assets/templates
   mkdir -p ~/.claude/skills/{skill-name}/scripts  # if needed
   ```

2. Write SKILL.md
   - Frontmatter (YAML - allowed properties only)
   - Title and brief intro
   - Quick Start section
   - Triggers (3-5 varied phrases)
   - Quick Reference table
   - How It Works overview
   - Scripts section (if applicable)
   - Validation section
   - Anti-Patterns
   - Verification criteria
   - Deep Dive sections (in `<details>` tags)

3. Generate reference documents (if needed)
   - Deep documentation
   - Templates
   - Checklists

4. Create assets (if needed)
   - Output templates
   - Examples
   - Samples

5. Create scripts (if needed)
   - Use script-template.py as base
   - Include Result dataclass pattern
   - Add self-verification
   - Document exit codes
   - Test before finalizing

### Quality Checks During Generation

| Check               | Requirement                                                                |
| ------------------- | -------------------------------------------------------------------------- |
| Frontmatter         | Only allowed properties (name, description, license, allowed-tools, model) |
| Name                | Hyphen-case, ≤64 chars                                                     |
| Description         | ≤1024 chars, no angle brackets                                             |
| Triggers            | 3-5 distinct, natural language                                             |
| Phases              | 1-3 max, not over-engineered                                               |
| Verification        | Concrete, measurable                                                       |
| Tables over prose   | Structured information in tables                                           |
| No placeholder text | Every section fully written                                                |
| Scripts             | Shebang, docstring, argparse, exit codes, Result pattern                   |
| Script docs         | Scripts section in SKILL.md with usage examples                            |

---

## Phase 4: Multi-Agent Synthesis

Create a panel of 3-4 specialized agents to review the skill independently.

### Panel Composition

| Agent                      | Focus                                  | Key Criteria                                           |
| -------------------------- | -------------------------------------- | ------------------------------------------------------ |
| **Design/Architecture**    | Structure, patterns, correctness       | Pattern appropriate, phases logical                    |
| **Audience/Usability**     | Clarity, discoverability, completeness | Triggers natural, steps unambiguous                    |
| **Evolution/Timelessness** | Future-proofing, extension, ecosystem  | Score ≥7, extension points clear                       |
| **Script/Automation**      | Agentic capability, verification       | Scripts self-verify, documented (when scripts present) |

Each agent must approve. If any reject, return to Phase 1 with feedback. Max 5 iterations before escalating to human review.

### Panel Evaluation Format

Each agent produces:

```markdown
## [Agent Name] Review

### Verdict: APPROVED / CHANGES_REQUIRED

### Scores

| Criterion | Score (1-10) | Notes |

### Strengths

1. [Specific with evidence]

### Issues (if CHANGES_REQUIRED)

| Issue | Severity | Required Change |

### Recommendations

1. [Even if approved]
```

### Consensus Protocol

```
IF all agents APPROVED (3/3 or 4/4):
    → Finalize skill
    → Run validate-skill.py
    → Update registry
    → Complete

ELSE:
    → Collect all issues
    → Return to Phase 1 with issues as input
    → Re-apply targeted questioning
    → Regenerate skill and scripts
    → Re-submit to panel
    → (Max 5 iterations, then escalate)
```

See: [synthesis-protocol.md](synthesis-protocol.md)
