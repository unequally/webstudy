# PharmAgent Reader Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Rebuild the PharmAgent single-file paper-reading webpage into a clear, top-to-bottom learning experience with stronger method exposition, chapter navigation, evidence labeling, and reliable responsive interactions.

**Architecture:** Replace the current accumulated HTML/CSS with one intentional document: a fixed utility bar, a compact reading rail, a constrained article column, and an evidence sidebar that collapses on smaller screens. Keep content as semantic HTML in reading order, use native `details` for expandable study notes, and keep all interaction logic in one small script at the end of the file.

**Tech Stack:** HTML5, CSS custom properties and responsive grid/flexbox, vanilla JavaScript, MathJax CDN, existing PNG page assets.

## Global Constraints

- Use only claims supported by `PharmAgent.txt` and the provided paper page images; mark uncertainty explicitly.
- Keep the page runnable by opening `PharmAgent.html` directly; do not add a build step.
- Keep evidence labels distinct: paper evidence, plain-language explanation, and critical evaluation.
- Preserve figure/table page references and use existing `pharmagent_assets` images.
- Support desktop, tablet, and mobile reading; avoid decorative gradients, large hero marketing blocks, and dense nested cards.
- Keep print, dark mode, search, copy, image zoom, language toggle, progress, and Markdown export working.

---

### Task 1: Rebuild the document shell and design system

**Files:**
- Replace: `PharmAgent.html`

**Interfaces:**
- Produces semantic IDs consumed by navigation and scroll-progress logic: `overview`, `map`, `chapters`, `method`, `results`, `figures`, `limits`, `reproduce`, `glossary`, `briefing`.
- Produces controls consumed by JavaScript: `menu-toggle`, `search-toggle`, `search-input`, `theme-toggle`, `language-toggle`, `export-markdown`, `print-page`, `left-rail`, `right-rail`, `lightbox`, `toast`.

- [ ] Write the new document skeleton with `header`, `aside`, `main`, `article`, `details`, `table`, and `figure` elements in top-to-bottom reading order.
- [ ] Add the CSS token system, typography, responsive breakpoints, print rules, evidence badges, method flow styles, result tables, and image/lightbox styles.
- [ ] Render the opening screen as paper identity, one-sentence thesis, three findings, three cautions, and a visual research pipeline.

### Task 2: Re-author the paper reading content around the user’s reading path

**Files:**
- Modify: `PharmAgent.html`

**Interfaces:**
- Content sections use the IDs from Task 1 and include source labels such as `p.4`, `Eq. (5)`, `Table 3`, and `Appendix M`.

- [ ] Add a chapter map that explains what Abstract, Introduction, Related Work, Methods 3.1–3.6, Results, Discussion, Ethics, and Appendices each do.
- [ ] Add a method deep dive that follows Algorithm 1 from seed scoring through candidate generation, acceptance, reviewer feedback, multiplier updates, replay, and budget termination.
- [ ] Add plain-language explanations for the Lagrangian objective, normalized violation, incumbent, Chemical-CER, AA-AUC, and PHV.
- [ ] Add experiment interpretation that separates E1 target-only performance from E2 feasible-search performance and states the E1/E2 trade-off.
- [ ] Add figure/table reading cards for Table 1, Figure 1, Figure 2, Tables 2–3/Figure 3, Figure 4, and Table 4, with image references and uncertainty boundaries.
- [ ] Add conclusions, innovation analysis, limitations, reproduction gaps, glossary, advisor briefing, and likely defense questions.

### Task 3: Implement the interaction layer

**Files:**
- Modify: `PharmAgent.html`

**Interfaces:**
- `updateProgress()` updates the top reading bar and active TOC link.
- `toggleRail()` opens/closes the mobile navigation.
- `searchSections(query)` returns matching article sections and scrolls to the selected result.
- `copyText(text)` copies key findings and displays the toast.
- `exportMarkdown()` exports visible article content as UTF-8 Markdown.

- [ ] Implement scroll progress and active section tracking with `IntersectionObserver` plus a scroll fallback.
- [ ] Implement mobile rail toggling, backdrop dismissal, Escape-key dismissal, and accessible button labels.
- [ ] Implement section search with short excerpts and keyboard focus behavior.
- [ ] Implement dark mode persistence, English abstract toggle, image lightbox, copy buttons, print, and Markdown export.
- [ ] Ensure MathJax is configured after the page content is present and does not block reading if the CDN is unavailable.

### Task 4: Validate the rebuilt page

**Files:**
- Validate: `PharmAgent.html`

- [ ] Parse the final HTML and verify matching counts for major structural tags and unique IDs.
- [ ] Compile every inline script with Node’s `vm.Script` to catch syntax errors.
- [ ] Check every referenced local image exists under `pharmagent_assets`.
- [ ] Inspect desktop and mobile rendering with a browser-capable check when available; verify no horizontal overflow in the main layout and no overlapping controls.
- [ ] Reopen the final file in Codex and confirm the first viewport begins with the paper summary, not a marketing panel or a collapsed empty shell.
