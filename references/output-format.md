# Output format — what each reviewer writes, what the orchestrator surfaces

## Per-reviewer file format

Each reviewer writes a single Markdown file at the path specified in their prompt. The file uses the format the prompt itself dictates (see the stage's `*-prompts.md`). The reviewer ALSO returns a brief summary (≤250 words) to the orchestrator via their final response — that's what the orchestrator surfaces to the user during the round.

## Severity ranking conventions

Use these tokens consistently across all reviewers:

| Token | Meaning |
|---|---|
| **BLOCKER** | Must fix before ship. The spec is incorrect, would cause a build failure, has a security hole that's actually exploitable, or fails a hard accessibility threshold. |
| **MAJOR** | Should fix; ship without only if explicitly accepted as a known risk with a documented reason. |
| **MINOR** | Worth doing; nice-to-have; would improve quality without being blocking. |
| **NIT** | Cosmetic / pedantic. Surface so it's known; defer fix to a polish pass. |

A few stage-specific equivalents exist (e.g. UX uses "highest-leverage move" framing; Security uses "B1/B2/B3" for blockers; A11y uses contrast ratio numbers directly). The intent maps to the four-token ladder.

## Per-round orchestrator output

After each round (3 reviewers complete + findings applied), the orchestrator surfaces to the user:

```
Stage: <stage>  |  Round <N>  complete

Top findings landed:
- <finding 1, one line>
- <finding 2, one line>
- <finding 3, one line>

Spec: Rev <M>, <line count> lines (+/- delta from previous rev).
```

Brief. No reviewer-by-reviewer breakdown unless the user asks. The change log entry in the spec carries the full attribution.

## Per-stage check-in (between stages)

If the user opted for stage check-ins (default), surface:

```
Stage <stage> complete.

Score arc: R1 <score> → R2 <score> → R3 <score>  (if scoring used in this stage)

Top 3 findings that landed this stage:
1. <one line>
2. <one line>
3. <one line>

Single load-bearing remaining risk: <one line>

Continue to <next stage>?  (default: yes)
```

The user may stop here, redirect, or continue. Honour the response.

## Final synthesis (after all stages)

The skill's final deliverable. Single message to the user, structured:

```
# Final synthesis — <N> stages, <M> rounds, <K> revisions

## The arc
- Start: <line count> lines
- End:   <line count> lines  (+<delta>, +<percentage>%)
- Revisions: Rev 1 → Rev <N>

## Per-stage scores (if collected)
- Engineering: R1 <score> → R3 <score>
- UX: ...
- Security: ...
- Accessibility: ...

## Top findings that survived to ship
1. <one line, with section reference>
2. ...
5. <one line>

## The single load-bearing remaining risk
<one paragraph>

## What this skill did NOT test for
<honest enumeration — e.g. real-user testing, performance benchmarks under load, regulatory legal review, accessibility testing with actual disabled users, security pen-test against running code>

## Ship-readiness verdict
<one line: yes / no / conditional>
```

The "what this skill did NOT test for" section is **mandatory**. Reviewers reading specs are not a substitute for reviewers reading running code, paying users, security pen-testers, or accessibility users. Be honest about the gap so the user doesn't over-trust the output.

## What NOT to include in surfaced summaries

- **Per-reviewer model identity in user-facing text.** Internal: Opus / Sonnet / Codex. User-facing: "the architectural reviewer" / "the build-feasibility reviewer" / "the trader-experience reviewer". The orchestrator may mention Opus/Sonnet/Codex once at the start of a round so the user knows model diversity is happening, but per-round summaries should focus on findings, not on which model produced them.
- **Verbose tool call counts.** The user doesn't care that the Opus reviewer used 12 tool calls.
- **Reviewer raw text dumps.** Surface the summary; the full text lives in `/tmp/spec-review-<stage>/round-N/<reviewer>.md` if the user wants to dig in.

## Length budget per orchestrator message

| Message type | Target length |
|---|---|
| Per-reviewer completion ping | ≤ 150 words |
| Per-round summary | ≤ 250 words |
| Per-stage check-in | ≤ 400 words |
| Final synthesis | ≤ 1500 words |

Brevity respects the user's time. The spec itself is the artefact; the orchestrator's messages are the running commentary.
