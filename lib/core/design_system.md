---
version: 1.0
name: OfferNepal Mobile
description: "Premium discount platform design system with Himalayan Crimson, pastel palette, and neo-banking aesthetic"
---

# OfferNepal Design System

## Color Palette

### Brand Colors
```yaml
colors:
  crimsonPrimary: "#E11D48"
  crimsonDark: "#B80035"
  emeraldJade: "#059669"
  amberFlame: "#F59E0B"
```

### Pastel Card Palette
```yaml
pastels:
  periwinkle: "#9F8EFC"
  peach: "#FF8652"
  canary: "#FFD94A"
  mint: "#76EDB8"
  coral: "#FF5C67"
```

### Surface Colors
```yaml
surfaces:
  canvas: "#ECEAF6"
  card: "#FFFFFF"
  onCard: "#0F172A"
```

### Text Colors
```yaml
text:
  primary: "#0F172A"
  secondary: "#475569"
  muted: "#94A3B8"
```

### Border Colors
```yaml
borders:
  subtle: "#E2E8F0"
  light: "#EAE8F4"
```

### Dark Anchors
```yaml
dark:
  pitchBlack: "#0D0D12"
  darkPill: "#111116"
```

## Typography

### Font Family
```yaml
typography:
  fontFamily: "Plus Jakarta Sans"
```

### Text Scale
```yaml
textStyles:
  displayLarge:
    fontSize: 38
    fontWeight: 900
    letterSpacing: -1.2
  displayMedium:
    fontSize: 32
    fontWeight: 700
    letterSpacing: -0.8
  headlineLarge:
    fontSize: 32
    fontWeight: 600
    letterSpacing: -0.5
  headlineMedium:
    fontSize: 24
    fontWeight: 600
    letterSpacing: -0.3
  headlineSmall:
    fontSize: 20
    fontWeight: 600
    letterSpacing: -0.3
  titleLarge:
    fontSize: 18
    fontWeight: 600
    letterSpacing: -0.3
  titleMedium:
    fontSize: 16
    fontWeight: 600
    letterSpacing: -0.2
  bodyLarge:
    fontSize: 16
    fontWeight: 500
    letterSpacing: -0.1
  bodyMedium:
    fontSize: 14
    fontWeight: 400
    lineHeight: 1.5
  bodySmall:
    fontSize: 12
    fontWeight: 400
    letterSpacing: 0
  labelLarge:
    fontSize: 14
    fontWeight: 500
    letterSpacing: 0.2
  labelMedium:
    fontSize: 12
    fontWeight: 500
    letterSpacing: 0.2
  labelSmall:
    fontSize: 11
    fontWeight: 500
    letterSpacing: 0.2
```

## Spacing

### 4px Grid System
```yaml
spacing:
  xs: 4
  sm: 8
  md: 16
  lg: 24
  xl: 32
  xxl: 48
```

### Component Spacing
```yaml
componentSpacing:
  inputHorizontal: 18
  inputVertical: 16
  cardPadding: 16
  sectionSpacing: 24
```

## Shadows

### Soft Card Shadow
```yaml
shadows:
  softCard:
    - color: "#000000"
      offset: {x: 0, y: 4}
      blurRadius: 24
      spreadRadius: 0
      opacity: 0.04
    - color: "#000000"
      offset: {x: 0, y: 2}
      blurRadius: 6
      spreadRadius: 0
      opacity: 0.02
```

### Card Deck Shadow
```yaml
  cardDeck:
    - color: "#000000"
      offset: {x: 0, y: 8}
      blurRadius: 24
      spreadRadius: -4
      opacity: 0.08
```

### Floating Dock Shadow
```yaml
  floatingDock:
    - color: "#000000"
      offset: {x: 0, y: 12}
      blurRadius: 32
      spreadRadius: 0
      opacity: 0.12
```

## Components

### Button Primary
```yaml
components:
  buttonPrimary:
    backgroundColor: "{colors.crimsonPrimary}"
    textColor: "#FFFFFF"
    borderRadius: 20
    padding: "16px 32px"
    fontSize: 16
    fontWeight: 600
```

### Input Field
```yaml
  inputField:
    backgroundColor: "#FFFFFF"
    borderColor: "{borders.subtle}"
    borderRadius: 18
    paddingHorizontal: 18
    paddingVertical: 16
    fontSize: 16
    fontWeight: 500
```

### Card
```yaml
  card:
    backgroundColor: "{surfaces.card}"
    borderColor: "{borders.subtle}"
    borderRadius: 20
    padding: 16
    shadow: "{shadows.softCard}"
```

## Border Radius Standards
```yaml
borderRadius:
  small: 12
  medium: 18
  large: 20
  xlarge: 28
```

## Usage Guidelines

### Color Usage
- **Primary Brand (crimsonPrimary)**: Call-to-action buttons, important highlights
- **Pastels**: Category cards, decorative elements, background accents
- **Canvas**: App background
- **Card**: Content containers, modals, sheets
- **Text Primary**: Headlines, important text
- **Text Secondary**: Body text, labels
- **Text Muted**: Helper text, timestamps, secondary information

### Typography Usage
- **Display Large**: Hero text, onboarding screens
- **Headline Large**: Section headers, page titles
- **Body Medium**: Standard body text
- **Label Medium**: Form labels, captions
- **Label Small**: Fine print, metadata

### Spacing Usage
- Use multiples of 4px for all spacing
- **xs (4px)**: Icon padding, tight spacing
- **sm (8px)**: Icon-text spacing, small gaps
- **md (16px)**: Standard component padding, section spacing
- **lg (24px)**: Large section spacing, card gaps
- **xl (32px)**: Page margins, major sections

### Shadow Usage
- **softCard**: Standard cards, floating elements
- **cardDeck**: Stacked cards, depth effects
- **floatingDock**: Bottom navigation, fixed overlays

---

*Last updated: 2026-11-04*
