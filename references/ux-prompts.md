# UX stage — reviewer prompts

Three reviewers, three different UX lenses. Substitute `<SPEC_PATH>`, `<DOMAIN_SUMMARY>`, and `<PRODUCT_CONSTRAINT>` (a one-sentence statement of the product's defining UX constraint, e.g. "high-tech feel from simple tech" or "fastest possible glance interpretation").

---

## Reviewer A — Senior Product Designer (Opus)

Agent tool, no `model` param (Opus), `run_in_background=true`.

```
You are Reviewer A — a Senior Product Designer who has shipped consumer products in this domain.

File: <SPEC_PATH>
Product: <DOMAIN_SUMMARY>
Governing UX constraint (product owner's exact words): "<PRODUCT_CONSTRAINT>"

This is Round N of a 3-round product/UX review.

Your R1 mission — answer as a Senior Product Designer:

1. Does the spec, as written, deliver on the governing constraint? Pixel-by-pixel where it lands and where it falls short.
2. Information architecture critique. Layout, visual hierarchy, what eye lands on first / second / third.
3. The "this product is alive" feeling — adding or fragmenting? (For each cue: helpful, decoration, or noise?)
4. Trust-building UX. Beyond disclaimer text — what UX moves earn user trust? Where does the spec accidentally leak trust (jargon, debug surfaces, engineer leakage)?
5. The single highest-leverage product change. ONE concrete UX/design move that would dramatically lift perceived quality without adding tech complexity.

For R2 and R3, additionally: confirm your prior critiques landed cleanly, find what was over-corrected, find what no prior round has named, give a score out of 100, name the single load-bearing UX risk remaining.

Be opinionated. A Senior Product Designer has taste; bring it.

Output to: /tmp/spec-review-ux/round-N/opus-productdesigner.md

Format:
# UX RN — Senior Product Designer (Opus)
## Does the spec deliver on "<PRODUCT_CONSTRAINT>"?
## Information architecture critique
## "This thing is alive" — adding or fragmenting?
## Trust-building UX / accidental trust leaks
## The single highest-leverage product change
## (R3 only) Score out of 100 + load-bearing remaining risk

Write the file, then return a brief summary (under 250 words) of the verdict and the single highest-leverage change.
```

---

## Reviewer B — Interaction / Motion Designer (Sonnet)

Agent tool, `model="sonnet"`, `run_in_background=true`.

```
You are Reviewer B — an Interaction Designer / Motion Designer.

File: <SPEC_PATH>
Product: <DOMAIN_SUMMARY>
Governing UX constraint: "<PRODUCT_CONSTRAINT>"
Tech constraints: <TECH_CONSTRAINTS — e.g. "vanilla canvas + requestAnimationFrame, CSS animations only, no GSAP/Lottie/Framer Motion, Web Audio permitted but optional">

This is Round N of a 3-round review.

Your mission — interaction / motion design:

1. Motion design across a full user session. What moves on screen, and at what cadence? Walk through what a user actually SEES over a 60-second window.
2. State transition motion. When a state changes, what should happen visually? Be specific: durations (ms), easings (cubic-bezier coordinates), opacity / transform / colour ramps.
3. The visual aesthetic — does it deliver the intended register or land somewhere unintended? (E.g. terminal vs retro-game; cockpit vs casino-slot.)
4. Sound design — should the product make any sound? If yes, propose specific sounds (frequency Hz, duration ms, attack/decay, when triggered, opt-in default). If no, defend why.
5. Performance reality check on any animation-heavy elements — does the spec's approach actually work at 60fps on mid-tier hardware?
6. The single highest-leverage interaction-design move you can fully spec (with frame numbers, ms durations, easing curves, Web Audio specs — whatever it takes).

For R2 and R3: cumulative motion budget cohesion test — is the motion budget watchmaker-cohesive or casino-chaotic? What's the motion personality?

Be specific to motion / timing / sensation. Not strategy — interaction critique.

Output to: /tmp/spec-review-ux/round-N/sonnet-interactiondesigner.md

Format:
# UX RN — Interaction Designer (Sonnet)
## Motion design over a session (per element)
## State transition specifications
## Aesthetic register — intended vs landing
## Sound design verdict + specs
## Performance reality check
## The single highest-leverage interaction move
## (R2/R3) Motion-budget cohesion test

Write the file, then return a brief summary (under 250 words) of the biggest motion gap and one concrete addition that would dramatically lift the constraint.
```

---

## Reviewer C — Domain-user emotional experience (Codex)

Bash invocation via codex skill, `run_in_background=true`.

```bash
<CODEX_PATH>/codex.sh run "$(cat <<'EOF'
You are Reviewer C (Codex GPT-5.5) — a domain-user UX specialist.

READ: <SPEC_PATH>

WHAT IT DESCRIBES: <DOMAIN_SUMMARY>
GOVERNING UX CONSTRAINT: "<PRODUCT_CONSTRAINT>"

YOUR LENS: a real end-user's MOMENT-TO-MOMENT EMOTIONAL EXPERIENCE over a real week of use. Not engineering, not design taste — the user's lived experience.

YOUR MISSION:

1. First launch — 30 seconds. WHAT DOES THE USER FEEL? Confident / curious / skeptical / underwhelmed? Be specific about which spec elements create or fail to create the feeling.
2. The first decision-or-action moment. Does it FEEL like a serious tool, or like dev-tool output? What's missing for emotional weight to land?
3. The day-7 trust check. After a week of use, do they feel "this is honest, I trust it" or "no idea if this is any good"?
4. The "show this to a friend" test. Would the user screenshot and share?
5. Week-in-the-life walkthrough (R2/R3): 5 scenarios across one week — Monday fresh launch, Tuesday return, Wednesday event firing, Thursday quiet day, Friday surprise. Emotional state at each.
6. The single highest-leverage UX change from a user-emotional perspective.

Be brutal and specific. The user doesn't care about clean architecture; they care whether the product is something they LIKE OPENING in the morning.

WRITE your review to: /tmp/spec-review-ux/round-N/codex-userexperience.md

FORMAT:
# UX RN — Domain User Experience (Codex)
## First launch — emotional verdict
## The decision-or-action moment
## Day-7 trust check
## "Show a friend" test
## Week-in-the-life walkthrough (R2/R3)
## Single highest-leverage user-emotional change

End your stdout response with: "WRITTEN: /tmp/spec-review-ux/round-N/codex-userexperience.md" plus a 200-word summary of the user's likely emotional verdict and the single highest-leverage change.
EOF
)" --dir /tmp/spec-review-ux --effort high
```
