# Apply-changes guidance — between rounds

When all three reviewers in a round complete, the orchestrator (you) applies findings to the spec. The reviewers never edit the spec directly — they produce reports; you reconcile and edit.

## The reconciliation loop

1. **Read each reviewer's full report.** Don't just rely on the brief summary they returned to you — read the file they wrote.
2. **Dedupe.** Same issue named by two reviewers → single finding with both citations. Two reviewers in agreement = signal, not noise.
3. **Resolve conflicts.** Reviewers disagree → orchestrator decides. Name the reasoning in one line.
4. **Tier by severity.** Reviewers used BLOCKER / MAJOR / MINOR / NIT or equivalent. Roll up into a single ranked list.
5. **Filter.** Drop nits unless trivial. Drop findings the user has explicitly accepted as out of scope.
6. **Decide what lands THIS round vs. defers to a later round.** Not every finding needs to land before the next reviewers fire — only the ones likely to mask later findings.

## The "what lands this round" rule

| Severity | Action |
|---|---|
| BLOCKER | Land before the next round (otherwise the next round will keep flagging it) |
| MAJOR | Land before the next round if quick (≤ 5 spec lines), otherwise defer to end-of-stage batch |
| MINOR | Defer to end-of-stage batch |
| NIT | Defer to a "polish pass" after all stages |

## How to apply — surgical edits, not rewrites

- Use the **Edit tool** for each change. Read first, edit with a unique-context `old_string` and a precise `new_string`.
- **Never use Write to overwrite a whole spec.** Loses surrounding context, loses unrelated edits, generates risk.
- Batch related changes into a single message where possible (multiple Edit calls in one message run in parallel if independent).
- After each edit, verify the file is still well-formed — `wc -l` it occasionally, eyeball a section near the edit.

## The change log discipline

Every round produces a new Rev N entry in the spec's change log. Format:

```markdown
- **Rev N (this rev):** <stage> R<round> hardening — <one-sentence frame>.
  - **§X update:** <what changed, why> — <attribution to reviewer if useful>.
  - **§Y update:** <what changed, why>.
  - **NEW §Z:** <new section topic — why it now exists>.
- **Rev N-1:** …
```

Lead each bullet with the section number that changed. Cite the reviewer when the finding was clearly their move. Keep each bullet ≤ 2 lines if possible.

The change log is **the single most useful artefact** for anyone reading the spec later — it's the why, not just the what.

## When to add a new section

Reviewers commonly surface concerns that don't fit any existing section. Add a new top-level section (`## §N — <topic>`) when:

- The concern spans multiple existing sections.
- It introduces a new structural commitment (e.g. "security architecture", "accessibility conformance", "auto-mode exclusion documentation").
- It will be referenced by other sections via cross-links.

Don't add new sections for one-off nits — those go inline.

## When to PUSH BACK on a finding

The orchestrator's job is reconciliation, not unconditional acceptance. Push back when:

- The finding is wrong (factually incorrect, based on a misreading of the spec, applies a standard from a different domain).
- The finding contradicts a non-goal that's been re-affirmed across multiple rounds.
- The finding's fix would invalidate substantial earlier work for a small gain.

Document the push-back in the change log: "considered but not landed — reasoning". Future-you will thank you.

## When a finding is too big to land in-round

Some findings require a separate review pass — e.g. "this is design-by-accumulation, the IA needs to be restructured". Don't try to fix these inline. Surface to the user, ask whether to:

- Pause the current stage, restructure, then continue.
- Defer the restructure to a post-review polish phase.
- Accept the bloat and continue, with a documented design-debt entry.

## After applying changes

1. `wc -l <SPEC_PATH>` — record the new line count for the synthesis report.
2. Update the change log.
3. Refresh `/tmp/spec-review-<stage>/SPEC.md` so the next round reads the new version.
4. Brief check-in to the user (one sentence per round): "Round N complete — spec at Rev M, <new line count> lines (+/- delta from Rev M-1)."
