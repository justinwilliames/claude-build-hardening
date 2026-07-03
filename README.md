# claude-build-hardening

A [Claude Code](https://docs.claude.com/en/docs/claude-code) skill that runs a structured multi-round adversarial review on a technical build spec, PRD, RFC, or design doc — to harden it before handing to engineers or to Claude Code for implementation.

## What it does

Four sequential stages, three rounds per stage, three parallel reviewers per round, with spec updates applied between rounds:

```
Engineering  →  UX / Product  →  Security  →  Accessibility
   R1→R2→R3      R1→R2→R3        R1→R2→R3      R1→R2→R3
```

Total: **36 reviewer runs + 12 spec updates** for a complete hardening pass. Typically ~60–90 minutes of background reviewer time.

The reviewers attack a **strengthened** spec each round, not just pile critique on top — between rounds, the orchestrator applies findings to the spec and refreshes the copy each reviewer reads. By round 3 of each stage, the surviving criticisms are the genuinely hard ones.

## Why three rounds per stage

- **R1** surfaces the obvious cracks. ~70% of findings.
- **R2** surfaces over-corrections from R1 changes AND what R1 didn't have context to see. ~25% — often the most architecturally important.
- **R3** is the "ship-or-not" verdict. ~5%, but the genuinely blocking ones.

## Why model diversity matters

Each round uses three different model families for genuine perspective diversity:

- **Opus 4.8** — deepest reasoning, best for architectural and product-design lenses.
- **Sonnet 4.6** — strong build-feasibility and interaction-design lens, faster than Opus.
- **Codex GPT-5.5** — different model family entirely, catches things Claude misses. Best for naive-user / threat-model / screen-reader lenses.

A second Sonnet can substitute for Codex if you don't have Codex configured, but the diversity is where the real value lives.

## When to use it

Worth running when:
- The spec is high-stakes (financial, healthcare, infrastructure, user-facing in production).
- The spec is substantial (≥500 lines, ≥3 major sections, multiple concerns intersect).
- Downstream cost of a missed issue is high.

Not worth running for:
- Single-feature briefs.
- Throwaway scripts.
- Specs where you're still iterating shape.

## Installation

### As a Claude Code skill (recommended)

Clone into your Claude Code skills directory (or anywhere, then symlink):

```bash
git clone https://github.com/justinwilliames/claude-build-hardening.git ~/.claude/skills/claude-build-hardening
```

Restart Claude Code or invoke the skill explicitly.

### As a methodology (read-only)

If you just want to learn the method without installing the skill, the `references/` directory contains the full set of reviewer prompts and the workflow. Each file is plain Markdown — usable verbatim or as a starting point for your own adaptation.

## Invocation

Inside Claude Code:

> "Run claude-build-hardening on `/path/to/SPEC.md`"

Or just describe what you want and the skill will trigger on phrases like:

- "harden this spec"
- "stress-test this design"
- "run multi-round review on"
- "engineering and UX review of this"

The skill will ask three setup questions:

1. **Where is the spec?** Absolute path.
2. **Which stages?** Default: all four. Subset OK.
3. **Check in between stages?** Default: yes.

Then it runs.

## Output

You get back:
- **The spec, modified in place** with all landed changes.
- **A change log section** inside the spec tracking each Rev N.
- **Per-round summaries** as the work happens.
- **Per-stage check-ins** between stages so you can scope down.
- **A final synthesis** covering the arc, top findings, the load-bearing remaining risk, and honest gaps (what this method does NOT test for — real users, performance under load, regulatory review, etc.).

## Repository structure

```
claude-build-hardening/
  SKILL.md                            # Main skill definition — the entry point Claude Code reads
  README.md                           # This file
  LICENSE                             # MIT
  references/
    workflow.md                       # Sequential stage flow + check-in protocol
    engineering-prompts.md            # 3 reviewer prompts for Engineering stage
    ux-prompts.md                     # 3 reviewer prompts for UX / Product stage
    security-prompts.md               # 3 reviewer prompts for Security stage
    accessibility-prompts.md          # 3 reviewer prompts for Accessibility stage
    apply-changes-guidance.md         # How to land findings between rounds
    output-format.md                  # Severity tokens, surfaced report shapes
```

## Methodology origin

This skill was extracted from a real hardening run on a forex decision-support build spec. Over 9 revisions across the four stages, the spec grew from 979 lines to 2,193 lines — but every added line addressed a finding from a structured adversarial review, not feature accumulation. The reviewers caught:

- **Engineering:** weekend-aging in a deterministic state machine, regime-blind volatility proxy, LLM-supplied inputs trusted as gospel, undefined types, unpinned APScheduler, missing SQLite WAL, the journal-as-forecast-track-record risk.
- **UX:** "8-bit" vs "terminal" aesthetic confusion (Press Start 2P reads as itch.io game-jam not Bloomberg), thesis-first row UX, motion budget cohesion (12-20 simultaneously-ticking 1Hz numbers = casino tell), the priority-ambiguity problem.
- **Security:** **stored XSS via LLM-supplied rationale** (the load-bearing find — six rounds of LLM-trust-boundary work undone if rendered output isn't escaped), drive-by CSRF on localhost, hash-verified lockfile mandate, HTTPS enforcement on overridable base URLs.
- **Accessibility:** `--dim` at 2.76:1 (WCAG fail) across the entire dim-coloured surface; LIVE-green vs INVALIDATED-red colour distinction collapsing under deuteranopia (1.8:1 — invisible to ~1 in 12 male users); status glyphs announced as "black circle" to screen readers.

None of those were caught by a single reviewer. They emerged from the multi-lens, multi-round, model-diverse structure.

## What this skill is NOT

- **Not a substitute for real-user testing.** Reviewers reading specs catch design-level issues; only paying users catch usability issues that emerge in real use.
- **Not a security pen-test.** Static-spec security review catches design-level issues; pen-testing running code catches the rest.
- **Not a legal review.** If your product has regulatory exposure, talk to a lawyer.
- **Not a substitute for accessibility testing with actual disabled users.** WCAG conformance and CVD simulation are first steps; real users surface issues no automated check catches.

The skill is honest about these gaps in the final synthesis.

## License

MIT. Use freely. Attribution appreciated but not required.

## Author

[Justin Williames](https://github.com/justinwilliames). Built with [Claude Code](https://claude.com/claude-code).
