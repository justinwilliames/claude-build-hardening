---
name: claude-build-hardening
description: Use this skill when the user wants to run a structured multi-round adversarial review on a technical build spec, PRD, RFC, design doc, or build brief — to harden it before handing to Claude Code or an engineering team. Trigger on phrases like "harden this spec", "stress-test this design", "run review rounds on", "adversarial review of", "multi-reviewer review", "engineering and UX review of this", "find what's wrong with this spec", "review this PRD across multiple lenses", "battle-test this brief". The skill runs four sequential stages — Engineering → UX → Security → Accessibility — each with three rounds of three parallel reviewers (Opus + Sonnet + Codex for model diversity) with spec updates applied between rounds. Total: 36 reviewer runs + 12 spec updates for a complete hardening. The skill is interactive — checks in between stages so the user can scope down.
---

# Build Spec Hardening — Multi-Round Adversarial Review

> Paths below use `{base}` as shorthand for this skill's base directory.

## What this skill is

A reproducible methodology for hardening a technical build spec via structured adversarial review. Four stages, three rounds per stage, three parallel reviewers per round, with spec updates applied between rounds. The reviewers attack a strengthened spec each round, not just accumulate critique on top.

This skill is **build-time hardening**, not run-time monitoring — use it on a spec / PRD / build brief / design doc *before* handing it to engineers or to Claude Code for implementation.

## When to use it

The skill earns its keep when:

- The spec is **high-stakes** (financial, healthcare, infrastructure, anything user-facing in production).
- The spec is **substantial** (≥500 lines, ≥3 major sections, multiple concerns intersect).
- The cost of a missed issue downstream is high (post-ship rewrite, regulatory exposure, user trust).
- You have time for **30–90 minutes of background reviewer time** + your own time to apply findings between rounds.

It is **NOT worth running** for:

- Single-feature briefs that fit in a paragraph.
- Throwaway scripts or one-shot implementations.
- Specs where the user is exploring options, not committing to a build.

When in doubt, ask the user: "This skill runs 36 reviewer rounds (Engineering / UX / Security / Accessibility) with spec updates between rounds — typically ~60–90 minutes of background time. Is the spec at the point where that investment is worth it, or are you still iterating shape?"

## The four stages

The order is **load-bearing**. Don't rearrange. Engineering must come first because UX assumes the substrate works. Security must come after UX because the attack surface depends on what's actually being built. Accessibility comes last because it's primarily about presentation, which UX defines.

| Stage | Reviewers | Lens | Why this order |
|---|---|---|---|
| **1. Engineering** | Architectural adversarial · Build-feasibility · Naive-user / first-principles · *(+ domain practitioner when applicable)* | Will it actually work, is it actually buildable, would a real user understand it, would a working practitioner refuse the output | First. UX work on a broken substrate is wasted. |
| **2. UX / Product** | Senior product designer · Interaction / motion designer · Domain-user emotional experience | Information architecture, motion design, the user's lived experience | Second. Substrate is locked; now design the surface. |
| **3. Security** | Application security · Supply chain · Threat model | Credentials, attack surface, supply chain, render-layer hardening | Third. The actual attack surface depends on the substrate AND the surface. |
| **4. Accessibility** | WCAG 2.1 AA · Colour vision deficiency · Screen-reader walkthrough | Inclusive design, contrast, ARIA, keyboard nav, CVD survival of state distinctions | Last. Presentation-layer concerns; design must exist before it can be made accessible. |

## The per-stage loop

Each stage runs three rounds. Each round runs three reviewers in parallel.

```
For each stage:
  Round 1:
    Fan out 3 reviewers in parallel (Opus + Sonnet + Codex)
    Wait for all three to complete
    Read their reports
    APPLY findings to the spec (the orchestrator does this — not the reviewers)
    Refresh the /tmp/spec-review-<stage>/SPEC.md copy

  Round 2:
    Fan out 3 reviewers in parallel — same lenses, but the spec they review is now strengthened
    Reviewers' explicit mandate: confirm prior findings were properly addressed (not just papered), find new problems introduced by R1 changes, surface what's still weak
    Apply findings

  Round 3:
    Final round — same lenses, spec twice-strengthened
    Mandate: final ship-ready verdict, what survived, single load-bearing remaining risk
    Apply findings
```

**Between stages**, brief check-in with the user: short summary of the stage's findings and what changed in the spec, then continue to the next stage (or stop if the user wants to ship at that point).

## Why three rounds per stage (not one or two)

Empirically (from the methodology's first run):

- **Round 1** surfaces the obvious cracks. ~70% of findings land here.
- **Round 2** surfaces what was over-corrected by R1 changes AND what R1 didn't have the context to see. ~25% of findings here, often the most architecturally important.
- **Round 3** is the "ship-or-not" verdict. ~5% of findings, but the ones that genuinely block.

Cutting to one round means missing the over-correction findings. Cutting to two rounds means shipping without an explicit "is this actually done?" verdict.

## Reviewer model diversity

Each round uses **three different model families** for genuine perspective diversity:

| Slot | Model | Why |
|---|---|---|
| A | **Opus 4.7** (fresh subagent) | Deepest reasoning. Best for architectural and product-design lenses. |
| B | **Sonnet 4.6** (Agent with `model="sonnet"`) | Strong build-feasibility and interaction-design lens. Faster than Opus. |
| C | **Codex GPT-5.5** (Bash subprocess via codex skill) | Different model family entirely. Catches things Claude misses. Best for naive-user / trader-experience / threat-model / screen-reader lenses. |

Lose Codex availability? Substitute a second Sonnet subagent with strong adversarial framing. The methodology survives degraded model diversity but the diversity is where the real value lives.

### Optional Reviewer D — Domain practitioner

Engineering / Build / Naive-user / Security / A11y are all generalist lenses. They will not catch wrongness that is only visible to someone who has worked in the specialised domain for a decade — yardsticks that are wrong-period for the horizon, microstructure the spec ignores, behavioural realities at the point of use, event windows treated as instants, outputs a working practitioner would refuse on sight.

When the spec is in a specialised practitioner domain (FX/trading, healthcare, legal, lifecycle marketing, field trades, sales — any domain where deep working knowledge changes which failure modes matter), add a 4th reviewer in the Engineering stage: **Reviewer D — Domain practitioner (Opus, in character)**. The canonical instance is **Eddie Carrington** (12-yr FX desk trader) for trading/forex/market-data specs. The prompt is parameterised — swap the persona block for other domains. See `references/engineering-prompts.md` for the full prompt and swap-in instructions for other practitioner archetypes.

Fire Reviewer D in Round 1, Round 2 and Round 3 alongside A/B/C — the practitioner's view of "did the revisions actually fix the desk problem, or just the engineering problem" is the value-add. Skip it for general-purpose tooling, dev workflows, or specs with no specialised practitioner audience.

## Detailed prompts and workflow

Read these references on demand:

- **{base}/references/workflow.md** — the full sequential flow with check-in points and decision rules.
- **{base}/references/engineering-prompts.md** — three reviewer prompts for the Engineering stage, parameterised on `<SPEC_PATH>`.
- **{base}/references/ux-prompts.md** — three reviewer prompts for the UX stage.
- **{base}/references/security-prompts.md** — three reviewer prompts for the Security stage.
- **{base}/references/accessibility-prompts.md** — three reviewer prompts for the Accessibility stage.
- **{base}/references/apply-changes-guidance.md** — how to land findings into the spec between rounds (tier them, batch edits, document Rev N in a change log).
- **{base}/references/output-format.md** — the structured report format each reviewer should follow.

## Invoking the skill

When the user invokes the skill, ask three setup questions:

1. **Where is the spec?** Absolute path to a Markdown file. Required.
2. **Which stages?** Default: all four. Allow user to subset (e.g. "skip a11y", "just engineering and security").
3. **Do you want me to check in between stages?** Default: yes. The user may want to pause/redirect after seeing each stage's findings.

Then execute per the workflow.

## The change log discipline

This skill produces incremental "rev" changes to the spec. Maintain a numbered change log section (default: `§N — Spec change log`) tracking each rev:

```
- Rev N (this rev): <stage> R<round> hardening — <bullet list of substantive changes>
- Rev N-1: …
```

Every substantive edit gets a one-line entry. The change log is the single best artefact for the next person to understand what was hardened and why.

## Stop conditions — when NOT to continue

The skill is opinionated, not religious. Stop early if:

- **Two consecutive reviewers in a row say "ship it" without significant findings.** The diminishing returns curve has bottomed out.
- **The user explicitly says stop / pause / redirect.**
- **An earlier stage produced a finding that changes the spec's foundational architecture.** Re-run earlier stages on the new architecture rather than continuing into UX/Security/A11y on an obsolete substrate.

## Output

The final deliverable is **the hardened spec itself** (modified in place), plus a final synthesis covering:

- Total revisions produced (Rev count, line delta, percentage growth).
- Score arc per stage (if scores were collected).
- Top 3 findings that survived all rounds.
- Single load-bearing remaining risk.
- Ship-readiness verdict.

## License

MIT. Use freely. Attribution appreciated but not required.
