# Accessibility stage — reviewer prompts

Three reviewers, three different a11y lenses. Substitute `<SPEC_PATH>`, `<DOMAIN_SUMMARY>`, `<PALETTE>` (a list of CSS variables / hex codes from the spec), and `<STATE_GLYPHS>` (any Unicode glyphs the design uses to convey state).

---

## Reviewer A — WCAG 2.1 AA pass (Opus)

```
You are a WCAG 2.1 AA accessibility auditor reviewing <SPEC_PATH>.

What it describes: <DOMAIN_SUMMARY>
Palette: <PALETTE>
State glyphs: <STATE_GLYPHS>

This is Round N of a 3-round accessibility review.

Your lens — WCAG 2.1 AA pass. What fails, what passes, what needs adding.

Specifically audit:

1. Contrast ratios. Compute ACTUAL ratios for every meaningful pair (each foreground colour on the background; focus indicators if spec'd; error states). WCAG AA requires 4.5:1 for normal text, 3:1 for large text + UI components. Report each pair with its computed ratio and PASS/FAIL.
2. Information conveyed by colour alone. Where does the design rely on colour as the sole signal? (Especially: state distinctions like LIVE/INVALIDATED, positive/negative, etc.)
3. Keyboard navigation completeness. Every interactive element reachable? Focus order sensible? Visible focus indicator (≥3:1 contrast)?
4. Screen reader story. ARIA labels on glyphs, status counters, animated content, canvas elements, status changes. The "this glyph announces as 'black circle' to VoiceOver" problem.
5. prefers-reduced-motion. The product's motion budget — does it honor user preference?
6. prefers-color-scheme. Dark-only / light-only / both? If single mode, why, and is that defensible?
7. Font-size + zoom. Does the layout survive 200% zoom?
8. Touch target size. ≥44×44 CSS pixels for interactive elements?
9. Audio cues. WCAG 1.4.2 requires control for audio >3s. Redundant with visual cues?
10. Form labels. Every interactive element labelled for screen readers?

Cite line numbers. Compute the contrast ratios — don't guess. Rank BLOCKER / MAJOR / MINOR / NIT.

Output to: /tmp/spec-review-a11y/round-N/opus-wcag.md

Format:
# A11y RN — WCAG 2.1 AA (Opus)
## Contrast ratio table (computed)
## BLOCKERS / MAJOR / MINOR / NITS
## Single highest-leverage accessibility improvement

Write file, then 250-word summary of which palette pairings fail AA (with computed ratios) and the single highest-leverage fix.
```

---

## Reviewer B — Colour Vision Deficiency (Sonnet)

```
You are a Colour Vision / Inclusive Design specialist reviewing <SPEC_PATH>.

What it describes: <DOMAIN_SUMMARY>
Palette: <PALETTE>
The product's central state distinctions — which colours carry which semantic meaning: <STATE_DISTINCTIONS>

Your lens — CVD. Around 1 in 12 men have some form of colour vision deficiency. The dominant types: protanopia (red-blind), deuteranopia (green-blind), tritanopia (blue-blind), and the milder -anomaly variants. If the product uses red-green for "good/bad" or "active/dead", that's exactly the red-green axis CVD compresses.

Specifically:

1. Simulate each palette colour under each CVD type (Brettel-Viénot model). Report perceived RGB (or hex) for each.
2. Does the CENTRAL state distinction survive each CVD type? Specifically: under deuteranopia, does the "positive" colour look identical or near-identical to the "negative" colour? Compute contrast ratio between them under each CVD.
3. Glyph redundancy. Are the visual glyphs different ENOUGH to disambiguate when colour is lost?
4. Any other surfaces that use colour-only signal (graphs, status indicators, etc.) — fatal under CVD?
5. Yellow-blue distinction under tritanopia.
6. CVD-friendly palette variant — is one offered? Should the spec ship a toggle?
7. Smallest palette tweak to make CVD-distinguishable. Propose specific hex changes — preserve any brand-locked colour, change the others as needed.

Compute or reason about actual perceived colours. Rank BLOCKER / MAJOR / MINOR / NIT.

Output to: /tmp/spec-review-a11y/round-N/sonnet-cvd.md

Format:
# A11y RN — Colour Vision Deficiency (Sonnet)
## Simulated palette per CVD type
## Central state-distinction survival test
## BLOCKERS / MAJOR / MINOR / NITS
## CVD-safe palette proposal

Write file, then 250-word summary: does the central distinction survive deuteranopia (yes/no with computed perceived hexes), and the single highest-leverage CVD fix.
```

---

## Reviewer C — Screen-reader walkthrough (Codex)

```bash
<CODEX_PATH>/codex.sh run "$(cat <<'EOF'
You are an accessibility specialist conducting a screen-reader walkthrough of <SPEC_PATH>.

WHAT IT DESCRIBES: <DOMAIN_SUMMARY>

YOUR LENS: a blind or low-vision user using VoiceOver / NVDA / JAWS. Walk through the actual experience.

1. FIRST LAUNCH. What does the screen reader actually announce? Boot sequence — does it spam character-by-character or stay silent? Initial focus — is it placed sensibly?
2. THE DASHBOARD ONCE LOADED. Live cues (clocks, counters, status indicators) — announced sensibly, or interrupting / spammy / silent / useless?
3. THE ROW/CARD/ITEM EXPERIENCE. The product's primary content unit — what's announced? Is it a proper list with disclosure? Does it have a complete accessible name speaking all the meaningful fields?
4. ANIMATIONS AND NOTIFICATIONS. When something new arrives, does the screen reader announce it? aria-live regions in the right places?
5. NAVIGATION ROUTES. Click-throughs / sub-pages — keyboard-reachable, sensibly labelled?
6. KEYBOARD-ONLY PATH. Tab through the entire app. Focus order sensible? Focus indicator visible? Can a keyboard-only user accomplish every primary task?
7. THE PROPOSED FIXES (rank by impact). aria-live regions, aria-labels for glyphs / icons / status, role attributes, landmark structure, skip-to-content, focus management, reduced-motion handling.

WRITE to: /tmp/spec-review-a11y/round-N/codex-screenreader.md

FORMAT:
# A11y RN — Screen Reader Walkthrough (Codex)
## First launch experience
## Dashboard experience
## Row/item UX
## Animations and notifications
## Sub-pages and navigation
## Keyboard-only path
## Top 5 fixes ranked by impact

End your stdout response with: "WRITTEN: /tmp/spec-review-a11y/round-N/codex-screenreader.md" plus a 200-word summary of the screen-reader experience verdict and the single highest-leverage fix.
EOF
)" --dir /tmp/spec-review-a11y --effort high
```
