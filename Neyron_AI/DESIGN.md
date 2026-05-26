---
name: Neyron AI
description: Miya Sayyorasiga sayohat — an Uzbek AI mentor (Bobo Aql) wrapped in a neuroscience metaphor.
colors:
  cosmic-deep: "#0A1628"
  cosmic-mid: "#1A2942"
  cosmic-light: "#2D3E5C"
  neuron-green: "#00E5A0"
  plasma-yellow: "#FFD93D"
  accent-red: "#FF4757"
  pure-white: "#F7F9FC"
  professor-warmth: "#E8A87C"
typography:
  display:
    fontFamily: "Inter, -apple-system, system-ui, sans-serif"
    fontSize: "22px"
    fontWeight: 600
    lineHeight: 1.3
    letterSpacing: "-0.01em"
  headline:
    fontFamily: "Inter, -apple-system, system-ui, sans-serif"
    fontSize: "20px"
    fontWeight: 600
    lineHeight: 1.35
  title:
    fontFamily: "Inter, -apple-system, system-ui, sans-serif"
    fontSize: "16px"
    fontWeight: 600
    lineHeight: 1.4
  body:
    fontFamily: "Inter, -apple-system, system-ui, sans-serif"
    fontSize: "15px"
    fontWeight: 400
    lineHeight: 1.5
  label:
    fontFamily: "Inter, -apple-system, system-ui, sans-serif"
    fontSize: "13px"
    fontWeight: 400
    lineHeight: 1.4
    letterSpacing: "0.01em"
rounded:
  sm: "12px"
  md: "16px"
  lg: "20px"
  xl: "24px"
  pill: "9999px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "16px"
  lg: "20px"
  xl: "24px"
  "2xl": "32px"
  "3xl": "48px"
components:
  button-primary:
    backgroundColor: "{colors.neuron-green}"
    textColor: "{colors.cosmic-deep}"
    rounded: "{rounded.md}"
    padding: "14px 24px"
    typography: "{typography.title}"
  card-surface:
    backgroundColor: "{colors.cosmic-mid}"
    textColor: "{colors.pure-white}"
    rounded: "{rounded.xl}"
    padding: "20px"
  input-filled:
    backgroundColor: "{colors.cosmic-mid}"
    textColor: "{colors.pure-white}"
    rounded: "{rounded.md}"
    padding: "18px 16px"
    typography: "{typography.body}"
  badge-pill:
    backgroundColor: "{colors.cosmic-mid}"
    textColor: "{colors.pure-white}"
    rounded: "{rounded.lg}"
    padding: "8px 14px"
    typography: "{typography.label}"
  bubble-bobo:
    backgroundColor: "{colors.cosmic-mid}"
    textColor: "{colors.pure-white}"
    rounded: "{rounded.md}"
    padding: "12px 16px"
    typography: "{typography.body}"
  bubble-user:
    backgroundColor: "{colors.cosmic-mid}"
    textColor: "{colors.neuron-green}"
    rounded: "{rounded.md}"
    padding: "12px 16px"
    typography: "{typography.body}"
  nav-bottom:
    backgroundColor: "{colors.cosmic-mid}"
    textColor: "{colors.cosmic-light}"
    typography: "{typography.label}"
---

# Design System: Neyron AI

## 1. Overview

**Creative North Star: "The Study at Night"**

Picture a scientist's study after sunset: the room is dim and deep-blue with the night outside, but the desk is warm — a brass lamp, an open book, the Professor turning a page, his student Maryam reading nearby. The light is low, intentional, and unhurried. Thought matters more than spectacle. That is the entire visual register of Neyron AI: a deep cosmic-navy room where the Professor turns to answer you.

The system is **flat, generous, and quiet**. Surfaces stack by tonal depth (cosmic-deep → cosmic-mid → cosmic-light), not by shadow. Corners are large and unhurried. The neuron-green accent is the lamp on the desk — present, never loud. The plasma-yellow and the warm character tone are the brass fittings and the lamplight: rare, warm, character-bearing. Color carries narrative; chrome does not.

What this system explicitly rejects: the candy-bright juice of cartoony brain-game apps (Lumosity, Elevate); the cold grey utility chrome of dark-mode SaaS dashboards (Linear-clone, Notion-clone); the glowing neon-on-black template that every AI product reaches for by reflex (ChatGPT-clone, Perplexity-clone, "futuristic" tech-startup aesthetic). When a screen begins to look like any of those, it has drifted off the North Star — the room has stopped being a study and started being a control panel. Pull it back.

**Key Characteristics:**
- Deep navy as the room, not as "dark mode"
- Tonal layering does the work shadows would do
- One true accent (neuron-green), used sparingly
- One character tone (professor-warmth) reserved for the Professor and his student Maryam (the lineage they share)
- Generous radii (20–24px) and roomy padding; nothing crowded
- Motion is slow, soft, never bouncy; respects reduced-motion
- Inter for both Latin and Cyrillic — typography works in Uzbek (both scripts) and Russian
- Copy register: modern Uzbek, Apple/Linear-grade restraint; no folkloric tea-house vocabulary

## 2. Colors

A tinted cosmic-navy room lit by a single green lamp, with one warm character flame reserved for the Professor and his student Maryam, who share that lineage.

### Primary
- **Neuron Green** (`#00E5A0`, ≈ `oklch(83% 0.18 165)`): the lamp on the desk. Primary action surfaces (the main button), the sent-message tint, selected state in navigation, success cues, and the progress fills on the Maryam card. It is loud against the navy, so it appears in narrow, deliberate moments — never as a flood.

### Secondary
- **Plasma Yellow** (`#FFD93D`, ≈ `oklch(89% 0.16 92)`): brass on the desk. Used only for streak badges, reward markers, the "magic box" surface, and rare attention cues. Never used for primary actions.

### Tertiary
- **Professor Warmth** (`#E8A87C`, ≈ `oklch(78% 0.10 50)`): the lampshade and the warm side of the Professor's face. Reserved for the Professor and his student Maryam — the avatar radial gradients (both), the Professor label color, the subtle border on the Professor greeting card and chat bubbles, the soft border around the Maryam profile card. They share this tone because Maryam carries the Professor's lineage; no third surface borrows it. **Not a general accent.**

### Neutral
- **Cosmic Deep** (`#0A1628`, ≈ `oklch(18% 0.04 250)`): the room itself. The deepest surface, top of the cosmic gradient, scaffold background, AppBar fill. Tinted toward blue — never pure black.
- **Cosmic Mid** (`#1A2942`, ≈ `oklch(28% 0.05 250)`): the table. Card surfaces, input fills, bottom-nav fill, chat bubbles for Bobo, the bottom of the cosmic gradient. The dominant card surface in the app.
- **Cosmic Light** (`#2D3E5C`, ≈ `oklch(38% 0.05 250)`): the soft edge of lamp-shadow. Caption text, disabled icons, hairline dividers, hint text, unselected-tab labels. Never used for headings or for body text on cosmic-mid (contrast is too low).
- **Pure White** (`#F7F9FC`, ≈ `oklch(98% 0.005 250)`): warm-cool tinted text white. The body and heading color. Never `#FFFFFF` — even the brightest text in this system carries a faint cool tint that matches the room.

### Accent (semantic)
- **Accent Red** (`#FF4757`, ≈ `oklch(67% 0.22 25)`): error and dangerous-action only. Always paired with an icon or text label; color is never the only signal of error.

### Named Rules

**The Lamp Rule.** Neuron-green is the lamp on the desk. Used as flooded background only on the primary CTA. Everywhere else it appears at low alpha (≤ 20%), as a small icon, or as the selected-state mark in navigation. If neuron-green coverage on a single screen exceeds ~10% of pixels, the lamp has become a floodlight — pull back.

**The Character-Tone Lock.** `professor-warmth` belongs to the Professor and to Maryam (his student, who carries his lineage). It is a character signature, not a theme accent. Do not use it on buttons, on streak indicators, on garden cards, on skill bars, on category accents, on user-side surfaces, or on any UI chrome that doesn't represent these two characters. Borrowing it dilutes the character system.

**The Tinted-Neutral Rule.** Every neutral in this system is tinted toward the cosmic-blue hue. Pure black (`#000000`), pure white (`#FFFFFF`), and untinted greys are forbidden. New neutrals introduced later must carry the same blue tint to keep the room coherent.

**The Evening-Safe Rule.** This palette exists in part to be usable late at night without disrupting melatonin. High-luminance accents (saturated yellow, pure white) are kept to small areas. Do not introduce a large bright surface (a white card, a yellow hero) on any screen that is part of a normal evening session.

## 3. Typography

**Display & Body Font:** Inter (with `-apple-system, system-ui, sans-serif` fallback).

**Character:** Inter is doing two jobs here. First, it carries Latin, Cyrillic, and Uzbek-Latin diacritics confidently with one stack, which is what the bilingual brief demands. Second, its rounded humanist forms read warmer than a geometric sans (Manrope, Geist) at the same size, which fits the lamp-lit warmth — but not so warm that it becomes friendly-product-mascot. Inter is the right answer because it is invisible: it gets out of the way of Uzbek and Russian prose and lets the Professor's voice carry.

There is no display-face contrast in this system today. Hierarchy is built from weight (400 / 600) and scale, not from font pairing. This is deliberate: a calligraphic display face would tip the room toward "mystical/poetic" and away from "wise/calm/intimate".

### Hierarchy

- **Display** (Inter 600, 22px, line-height 1.3, letter-spacing −0.01em): top-of-screen greetings in onboarding ("Xush kelibsiz"), the largest moment of any flow. Used once per screen at most.
- **Headline** (Inter 600, 20px, line-height 1.35): AppBar titles, second-level section headings. Slightly tighter than Display, never used together on the same screen.
- **Title** (Inter 600, 16px, line-height 1.4): card titles, button labels, "Sehrli quti"-style component headings. The everyday emphasis weight.
- **Body** (Inter 400, 15px, line-height 1.5): the default reading size. Bobo Aql's chat messages, descriptive paragraphs, onboarding copy. Line-height is generous because Cyrillic ascenders need room.
- **Label** (Inter 400, 13px, line-height 1.4, letter-spacing 0.01em): captions, meta-info, level indicators ("Daraja: 47 / 100"), unselected nav labels. Used in `cosmic-light` color most of the time; never used for anything actionable.

### Named Rules

**The One-Weight-Pair Rule.** This system uses Inter 400 and Inter 600. Inter 300, 500, and 700 are forbidden in production UI unless a future explicit need justifies an extension to this file. Two weights, two scripts, every screen — that is the whole rhythm.

**The Cyrillic-First Test.** Every typographic decision must be checked against a Cyrillic or Uzbek-Latin string of realistic length before shipping. If `Ассалому алайкум, қадрли меҳмонийм!` overflows where `Assalomu alaykum` did not, the layout is wrong, not the text. Russian strings expand the most; design to the long string, not the English mock.

**The No-Display-Face Rule.** Do not introduce a serif, script, or display sans (e.g. Cormorant, Playfair, Space Grotesk, Monument Extended) without an explicit decision to change the system. The single-family discipline is what keeps the room quiet.

## 4. Elevation

This system is **flat by default, glow on state**. Cards, inputs, buttons, and bubbles sit on the cosmic surface with no shadow. Depth is conveyed entirely by tonal layering — cosmic-deep behind cosmic-mid behind cosmic-light — which the dark palette makes legible without any drop-shadow.

Glow appears only in two situations: (1) on the **character widgets** (the Professor's warm radial glow and Maryam's matching warm halo) — these are diegetic lights inside the scene, not UI elevation; and (2) as a **state response** — focus rings, hover states for the rare hoverable surface, and the soft alpha-tinted borders around the Professor greeting card and chat bubbles that read as warm reflected light.

There are no rectangular drop-shadows on rectangular surfaces anywhere in this system. That is the line that separates this from a SaaS dashboard.

### Glow Vocabulary

- **Character glow — Professor** (radial gradient `professor-warmth → cosmic-mid`, plus `box-shadow: 0 0 20px 2px rgba(232,168,124,0.4)`): only on the Professor avatar.
- **Character glow — Maryam** (radial gradient `professor-warmth → cosmic-mid`, plus `box-shadow: blurRadius ≈ 0.25 × size, color rgba(232,168,124, 0.5 × intensity)`): only on the Maryam avatar. Intensity scales with the user's level (1–100), brighter at higher levels.
- **Focus ring** (`box-shadow: 0 0 0 2px rgba(0,229,160,0.6)`): focus state on inputs and pressable surfaces.

### Named Rules

**The Flat-By-Default Rule.** Surfaces are flat at rest. If you find yourself reaching for `box-shadow: 0 4px 12px rgba(0,0,0,0.3)` on a card, stop. The card already has depth from sitting on a darker surface; the shadow makes it look like a SaaS dashboard.

**The Glow-Is-Diegetic Rule.** The glows that exist in this system belong to characters or to states. They are not UI ornaments. Do not add a glow to a card, a button, or a section heading because it "looks cosmic". The cosmic feel comes from the navy, not from neon bloom.

## 5. Components

Component voice for the whole system: **generous and restrained.** Padding is roomy, corners are large (20–24px on cards), but chrome is quiet — no borders unless meaningful, no shadows, no flourishes. Things feel unhurried.

### Buttons

- **Shape:** moderately rounded corners (16px radius — `{rounded.md}`).
- **Primary** (`button-primary`): neuron-green fill (`#00E5A0`) with cosmic-deep text (`#0A1628`). Padding 14×24 (vertical × horizontal). Title-weight label (Inter 600, 16px). The only flooded-green surface in the system.
- **Pressed state:** subtle scale-down to 0.98 over 120ms ease-out-quart. No color shift required.
- **Focus state:** 2px neuron-green ring at 60% alpha around the perimeter; no outline-offset gap.
- **Secondary / Ghost:** not yet defined in code. When introduced, use cosmic-mid fill with pure-white text, no border. Reserve neuron-green text for icon-buttons inside chat (send icon).
- **Disabled state:** opacity 0.4 on the entire button, no separate disabled color token.

### Cards / Containers

- **Corner Style:** large radius (24px for hero cards on screens; 20px for secondary cards — `{rounded.xl}` / `{rounded.lg}`). The current code uses 24px on Planet-screen cards and 20px on the theme default; keep that pattern.
- **Background:** `cosmic-mid` (`#1A2942`) sitting on the `cosmic-deep → cosmic-mid` vertical gradient scaffold.
- **Shadow Strategy:** none. Depth comes from the cosmic gradient behind the card.
- **Border:** none by default. When a card carries a character (Bobo greeting card) or a category color (the magic-box yellow card), use a 1px border at 20–30% alpha of that character/category color. This is reflected lantern light, not a structural stroke.
- **Internal Padding:** 20px on standard cards (`{spacing.lg}`), 16px on dense items.

### Inputs / Text Fields

- **Style:** filled with `cosmic-mid` (`#1A2942`), no visible border, radius 16px (`{rounded.md}`).
- **Padding:** 18px vertical / 16px horizontal — generous, not cramped.
- **Hint text:** `cosmic-light` (`#2D3E5C`). Body weight.
- **Focus:** neuron-green ring (2px, 60% alpha). No color shift on the fill itself.
- **Error:** thin accent-red border (1.5px) plus an icon-and-text label below the field. **Color is never the only error signal.**

### Pills / Badges

- **Style:** filled `cosmic-mid` with a 1px border at 30% alpha of the role color (plasma-yellow for streak, neuron-green for coins). Radius 20px (`{rounded.lg}`).
- **Padding:** 8×14.
- **Typography:** Title-weight (16px 600) for the numeric value in the role color; emoji or icon at body size beside it.

### Chat Bubbles

- **Professor bubble** (`bubble-professor`): `cosmic-mid` fill, pure-white text, asymmetric radius — 18px on three corners, 4px on the bottom-left (the corner pointing toward the Professor's avatar). 1px border at 22% professor-warmth alpha — the warm-light spill from the desk lamp.
- **User bubble** (`bubble-user`): neuron-green at 20% alpha fill, neuron-green text, asymmetric radius — 18px on three corners, 4px on the bottom-right. No border.
- **Padding:** 12×16. Max width 72% of screen width.
- **Typography:** Body (15px, line-height 1.4).

### Navigation (Bottom Tab Bar)

- **Background:** `cosmic-mid` fill, 0.2px top border in `cosmic-light` (hairline).
- **Typography:** Label (Inter 400, 13px). Always show labels — never icons-only.
- **Active state:** neuron-green icon and label.
- **Inactive state:** `cosmic-light` icon and label.
- **No badge dots, no animated indicator pill** at this stage. The room stays quiet.

### Signature Components

**Professor Avatar** (the neuroscientist, present on most screens at sizes 32–160). Circular, radial-gradient from `professor-warmth` (center) to `cosmic-mid` (edge), with a soft warm `box-shadow` glow at 40% alpha. A small plasma-yellow rectangle near the top reads as an academic cap. Scales 1.0 → 1.03 over 3s ease-in-out (the breath); must be statically renderable for chat headers and reduced-motion contexts.

**Maryam Avatar** (the Professor's young student, the warm companion). Circular, radial-gradient from `professor-warmth` (center) to `cosmic-mid` (edge), with a soft warm `box-shadow` glow whose blur and spread scale with the user's `level` prop (1–100). She breathes slightly faster than the Professor (2.5s 1.0 → 1.04 ease-in-out), which reads as a younger pulse. She shares his tone because she carries his lineage — never re-skin her into a cool palette or a different character color.

**Hero Characters** (the Professor and Maryam together, the "study at night" composition). A single Image asset (`bobo_maryam.png`) of the two characters side by side, used on the splash screen, the onboarding greeting and finish steps, and the chat empty state. Wrapped in a soft `professor-warmth → transparent` radial backdrop and a slow floating motion (`-4 → +4` Y over 3s, ease-in-out). Reduced-motion contexts get the static composition; the warmth backdrop stays.

**Greeting Card** (the entry point to the Professor chat, on the Planet home). A `cosmic-mid` card with a 22% professor-warmth border, holding a "Professor" label in professor-warmth and a two-line greeting in pure-white, with a small neuron-green "Suhbat" pill on the right. This is the most important affordance in the entire product — the door into the conversation — and its design should never compete with the chat itself.

## 6. Do's and Don'ts

### Do

- **Do** use `cosmic-deep` (`#0A1628`) as the page scaffold and `cosmic-mid` (`#1A2942`) as the card surface. The vertical `cosmic-deep → cosmic-mid` gradient is the default backdrop for every full-screen container.
- **Do** keep `neuron-green` to ≤ 10% of any given screen. The Lamp Rule.
- **Do** reserve `professor-warmth` for the Professor and Maryam alone — the two characters who share the lineage. The Character-Tone Lock.
- **Do** convey depth through tonal layering (cosmic-deep → cosmic-mid → cosmic-light), not through shadows.
- **Do** check every screen in Uzbek-Latin, Uzbek-Cyrillic, and Russian before shipping. Design to the longest expansion, not the English mock.
- **Do** keep motion slow (200–800ms), soft (ease-out-quart / ease-in-out for character breath), and respectful of `prefers-reduced-motion`.
- **Do** use generous corner radii (20–24px on cards) and roomy padding. Things should feel unhurried.
- **Do** pair every error color signal with an icon and a text label.
- **Do** keep streak and reward cues quiet — no confetti, no full-screen celebration, no "+50 XP!" toast bursts.

### Don't

- **Don't** use `#000000` or `#FFFFFF` anywhere. Every neutral in this system is tinted toward the cosmic-blue hue. The Tinted-Neutral Rule.
- **Don't** add a drop-shadow to a card, a button, or a section heading. The Flat-By-Default Rule. If you feel the card "needs depth", the surface behind it isn't dark enough yet.
- **Don't** introduce gradient text (`background-clip: text` on a gradient). Use solid `pure-white` for emphasis; carry hierarchy with weight and scale.
- **Don't** introduce glassmorphism, frosted blur, or `backdrop-filter` as a decorative effect. The room is not a sci-fi cockpit.
- **Don't** drift into the cartoony brain-game-app aesthetic (Lumosity, Elevate, Peak): no candy palettes, no mascot juice, no "Level Up!" full-screen takeovers, no bright primary-color cards.
- **Don't** drift into the dark-SaaS-dashboard aesthetic (Linear-clone, Notion-clone): no grey-on-grey card grids, no sidebars-and-data-tables layouts, no "command palette" patterns lifted from desktop productivity tools.
- **Don't** drift into the sci-fi / crypto / AI-template aesthetic (Perplexity-clone, ChatGPT-clone, "futuristic" tech-startup landing): no glowing terminal gradients, no holographic chrome, no "✨" sparkle iconography, no neon-on-black.
- **Don't** introduce a serif, script, or display sans beyond Inter without an explicit DESIGN.md update. The No-Display-Face Rule.
- **Don't** introduce Inter weights other than 400 and 600 in production UI. The One-Weight-Pair Rule.
- **Don't** use color as the only signal for any state (error, success, selected, disabled). There must always be a non-color cue.
- **Don't** introduce a large bright surface (a white card, a saturated-yellow hero) on a screen that is part of a normal evening session. The Evening-Safe Rule.
- **Don't** localize by retrofitting English mocks. Russian and Uzbek strings expand, and Cyrillic has different ascender behavior; design to the longest realistic string, not the English placeholder.
