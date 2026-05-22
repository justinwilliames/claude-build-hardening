# Workflow — sequential stages with three rounds each

This is the full procedure the skill executes. Read in order.

## Pre-flight (once, at skill invocation)

1. Confirm the spec path. If the user gave a path, verify it exists. If they gave a description, ask for the path.
2. Get the spec's current line count: `wc -l <SPEC_PATH>`. Stash it as the "start size".
3. Ask which stages to run (default: all four — Engineering, UX, Security, Accessibility).
4. Ask: "Should I check in between stages?" (default: yes).
5. Set up working directories — one per stage:
   ```bash
   mkdir -p /tmp/spec-review-eng/{round-1,round-2,round-3}
   mkdir -p /tmp/spec-review-ux/{round-1,round-2,round-3}
   mkdir -p /tmp/spec-review-sec/{round-1,round-2,round-3}
   mkdir -p /tmp/spec-review-a11y/{round-1,round-2,round-3}
   ```
6. Copy the spec into each stage's workspace:
   ```bash
   cp <SPEC_PATH> /tmp/spec-review-eng/SPEC.md
   cp <SPEC_PATH> /tmp/spec-review-ux/SPEC.md
   cp <SPEC_PATH> /tmp/spec-review-sec/SPEC.md
   cp <SPEC_PATH> /tmp/spec-review-a11y/SPEC.md
   ```
7. Add (or verify) a "Spec change log" section at the bottom of the spec, formatted:
   ```
   ## §N — Spec change log

   - Rev 1 (initial): <one-line description of starting state>
   ```

## Per-stage loop

For each stage in [Engineering, UX, Security, Accessibility]:

### Round 1 (R1) of stage

1. Refresh the stage's spec copy: `cp <SPEC_PATH> /tmp/spec-review-<stage>/SPEC.md`.
2. Launch the three reviewers **in a single message with three parallel tool calls** (one Agent call per reviewer, all with `run_in_background=true`). Reviewer A uses Opus, B uses Sonnet, C uses Codex via the codex skill's Bash invocation.
3. The reviewer prompts come from `references/<stage>-prompts.md`. Substitute `<SPEC_PATH>` placeholders with the actual path.
4. While reviewers run, prepare the apply-changes scaffolding (see `apply-changes-guidance.md`).
5. As each reviewer completes (you'll be notified), surface a brief summary to the user (max 250 words per reviewer) so they see the findings landing in real-time.
6. Once all three complete:
   - Read each reviewer's full report.
   - Reconcile findings — dedupe, prioritise blocker > major > minor > nit.
   - **Apply findings** to the spec via Edit calls. The orchestrator (you) does this — never have the reviewers edit the spec directly.
   - Update the change log at the bottom of the spec with a new Rev N entry summarising the changes.
   - Confirm: "Round 1 of <stage> complete — spec at Rev N, <line count> lines (+/- delta)."

### Round 2 (R2) of stage

1. Refresh the stage's spec copy with the freshly-edited version.
2. Launch the same three reviewers in parallel — same lenses, same prompts, with an additional instruction: "The spec at SPEC.md has been revised since R1 — see the change log at the bottom. Your R2 mission: (a) confirm your R1 critiques were properly addressed (not just papered over), (b) find NEW problems introduced by the R1 changes, (c) surface what's still weak that R1 missed."
3. Same collect → reconcile → apply → log loop as R1.

### Round 3 (R3) of stage

1. Refresh the stage's spec copy.
2. Launch the same three reviewers — final round. Mandate: "This is the LAST round. Give a definitive ship-ready verdict. Score (if scoring), what survived, single load-bearing remaining risk."
3. Apply → log.
4. Check in with the user briefly: "<Stage> review complete. Spec is now at Rev N, <line count> lines. Continue to <next stage>, or stop here?"

## Between stages

If the user said "check in between stages" (default), produce a compact stage report:

- Stage X complete.
- Score arc (if collected): R1 → R2 → R3.
- Top 3 findings that landed.
- Single load-bearing remaining risk per the final R3 reviewers.
- Continue to stage Y? (default yes; user can stop here or redirect.)

## Stop conditions — when to halt the loop

- User says stop.
- Two consecutive reviewers in a single round say "ship it" with no significant findings → consider declaring this stage done after one round.
- A reviewer identifies a foundational issue that would require re-running earlier stages on a new architecture → pause, surface to user, ask whether to re-spec from scratch.
- The spec doubles in size — the methodology has produced design-by-accumulation rather than hardening. Step back.

## Final synthesis (after all stages complete)

Produce a single-message summary covering:

1. **The arc.** Total revisions produced (e.g. "Rev 9, 2,193 lines from 979 — +124%").
2. **Per-stage scores** (if collected).
3. **Top 5 findings that landed**, one line each.
4. **The single load-bearing remaining risk** after all stages.
5. **Ship-readiness verdict.**
6. **What this skill did NOT test for** — name the gaps honestly (e.g. real-user testing, performance benchmarks, regulatory legal review).

## Time budget

Empirical from the methodology's first run:

- One reviewer round: ~2–5 minutes background time per reviewer (concurrent).
- Apply findings: ~3–8 minutes of orchestrator (your) work per round.
- Per stage: ~15–25 minutes elapsed.
- Full four-stage run: **~60–90 minutes elapsed**, plus the user's review time at each check-in.

Communicate this up front so the user can plan.
