# Product

## Register

product

## Users

Teens and adults (13–60), primarily Uzbek- and Russian-speaking, using the app in their personal time — often in the evening, on a phone, alone. They come back because they want a conversation worth having, not because a streak is shouting at them. Most of them are not "self-improvement maximalists"; they are curious people who want a calmer, smarter relationship with their own attention.

The user's mental state when opening the app is usually low-energy and reflective. They are not at a desk. They are not in a hurry. The product earns its place by respecting that.

## Product Purpose

Neyron AI — *Miya Sayyorasiga Sayohat* ("Journey to Brain Planet") is a mobile AI mentor wrapped in a neuroscience metaphor. The center of the product is the **Professor**, a neuroscientist users talk to as a thoughtful expert; **Maryam** is his young student, the warm companion who appears alongside him. Games (Schulte attention training, etc.), the Lab, the Garden, and the Academy are supporting surfaces — they exist to give the conversation things to point at, return to, and grow with.

Success looks like: a user opens the app in the evening, has a short, real-feeling exchange with the Professor, maybe runs one focused exercise, and closes it feeling steadier than when they opened it. Not "engaged." Steadier.

This is explicitly **not** a productivity tool, **not** a kids' brain-game app, and **not** a meditation app. It is closer to a quiet evening in a scientist's study — the lamp on, a book half-open, the Professor turning to answer a question.

## Brand Personality

**Wise, calm, intimate. International quality, Uzbek voice.**

- **Wise** — The Professor speaks like someone who has spent decades inside the field. He does not perform expertise; he simply has it. He explains brain phenomena in clear, modern terms — nothing folkloric, nothing patronising.
- **Calm** — pacing is slow on purpose. No urgency cues, no countdowns, no "you're falling behind." The interface breathes between actions.
- **Intimate** — the app addresses one person, by name, in their language. Copy is in second person but never coach-y. Closer to a letter than a notification.

Voice rules that fall out of this: short sentences over long. Modern Uzbek phrasing — never folksy, never translated-from-English. Drop *choyxona*-era vocabulary (*qadrli mehmonim*, *choy quyib qo'yibman*, *ko'k choy*); this is a study, not a tea house. Apple- or Linear-grade restraint in word count. No exclamation marks except in genuine greetings. The Professor never says "Let's crush it" or any equivalent — he says less than you'd expect, and what he says lands.

## Anti-references

The product must visibly resist three category reflexes:

- **Cartoony brain-game apps (Lumosity, Elevate, Peak).** No candy palettes, no mascot juice, no "+50 XP!" toast bursts, no confetti for completing a 30-second task. Streaks exist, but they are quiet.
- **Generic dark-SaaS dashboards (Linear-clone, Notion-clone neutral grey utility chrome).** This is not a productivity tool. Avoid grey-on-grey card grids, sidebar-and-data-table layouts, "command bar" patterns lifted from desktop SaaS.
- **Sci-fi / crypto / AI-template neon-on-black (Perplexity-clone, ChatGPT-clone, generic AI-startup landing).** No glowing terminal gradients, no holographic chrome, no "futuristic" reflexes. The cosmic theme is poetic, not techno.

The current cosmic-navy palette is on the right track because it reads as **night sky**, not as **dashboard chrome** or **neon UI**. Keep that distinction loadbearing in every future decision.

## Design Principles

1. **The mentor speaks, the app listens.** Bobo Aql is the product. Every screen — Lab, Garden, Academy, Profile — is downstream of the conversation, not parallel to it. When in doubt about hierarchy, ask: does this make the dialogue richer, or does it compete with it?

2. **Quiet over loud, always.** The app is used in the evening, often before sleep. Motion is slow and rare. Color is restrained outside of moments that earn brightness. Sounds, if any, are soft. We are not optimizing for "delight per second"; we are optimizing for *steadiness*.

3. **Adult dignity inside a neuroscience metaphor.** The space / brain-planet imagery stays poetic and grown-up. Bobo Aql is not a cartoon grandfather; the Lab is not a kids' science kit; the Garden is not a Duolingo grove. Treat the user as a literate adult who chose this aesthetic on purpose.

4. **Bilingual by craft, not by retrofit.** Every typographic, layout, and copy decision is checked in Uzbek (Latin), Uzbek (Cyrillic), and Russian — not English-first then localized. Strings expand and contract; diacritics need room; the rhythm of Uzbek prose is not English prose. Design works for whichever script the user reads in.

5. **Refuse the AI-product reflex.** Most AI apps in 2026 look the same: neon gradients on black, glassmorphism, terminal-monospace chrome, "✨" everywhere. Neyron AI should feel like a thoughtful product made in Tashkent by people who care, not like a Y Combinator template with Uzbek strings dropped in. When a choice feels like the default AI-app reflex, pick the second option.

## Accessibility & Inclusion

**WCAG 2.2 AA baseline**, with explicit additional care for multi-script typography (Russian / Uzbek-Cyrillic / Uzbek-Latin / English).

- Text contrast ≥ 4.5:1 against every background it actually sits on (the cosmic-navy backgrounds are tinted, not pure black — verify each pairing rather than trusting the palette name).
- Hit targets ≥ 44×44 pt. The age slider, language toggle, and onboarding controls are the highest-risk surfaces; treat them generously.
- Respect `prefers-reduced-motion`. The flutter_animate flourishes (fade-ins, scale-ins on Bobo Aql) must have a no-motion path that still feels finished, not broken.
- **Typography for Cyrillic + Latin:** the chosen body font must carry Cyrillic confidently (Inter does — keep verifying when introducing display fonts). Avoid display fonts that only ship Latin glyphs and fall back ungracefully for Cyrillic. Line-height needs to accommodate Cyrillic ascenders/descenders without crowding.
- **Copy & i18n:** strings live in resource files, not in widgets. Test every screen in the longest expansion (typically Russian) before shipping. No truncation in primary actions.
- Color is never the only signal. Streak state, error state, success state must carry a non-color cue (icon, shape, text).
- The evening-safe palette claim in `app_colors.dart` is a real promise: keep cool-blue / low-luminance discipline. Don't introduce high-luminance accents (bright yellows, pure whites) at full saturation in late-evening flows.
