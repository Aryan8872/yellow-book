# Phase 9: UI Consistency & OAuth Integration for the OfferNepal Mobile App — Research

**Researched:** 2026-11-04  
**Domain:** Flutter consumer app (mobileapp/) + NestJS backend (api/offernepal/)  
**Confidence:** HIGH (all technical claims verified through web research, codebase analysis, and library documentation review)

## Research Summary

This phase focuses on four key areas for the OfferNepal mobile app:
1. **Design System Documentation** - Creating comprehensive markdown documentation for design tokens
2. **Google OAuth Integration** - Implementing secure Google Sign-In with proper token handling
3. **Avatar Upload Enhancement** - Robust image compression, retry logic, and multipart upload
4. **Map Marker Customization** - Text labels on markers with zoom-based visibility

The research identifies proven libraries, architectural patterns, and implementation approaches for each area, with specific attention to security, performance, and user experience requirements.

---

## 1. Design System Documentation Patterns

### Current State
The mobile app already has a design system defined in mobileapp/lib/core/theme/app_theme.dart with:
- Comprehensive color palette (brands, pastels, surfaces, text)
- Typography system using Google Fonts (Plus Jakarta Sans)
- Shadow definitions for cards, docks, and floating elements
- Material 3 theme configuration

### Recommended Documentation Format

Based on industry best practices (FlutterInit, Google Labs design.md spec, Vercel design system), use **DESIGN.md** with embedded YAML tokens:

```markdown
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

## Typography
```yaml
typography:
  fontFamily: "Plus Jakarta Sans"
  headlineLarge:
    fontSize: 32
    fontWeight: 600
    letterSpacing: -0.5
  bodyMedium:
    fontSize: 14
    fontWeight: 400
    lineHeight: 1.5
```

## Spacing
```yaml
spacing:
  xs: 4
  sm: 8
  md: 16
  lg: 24
  xl: 32
```

## Components
```yaml
components:
  buttonPrimary:
    backgroundColor: "{colors.crimsonPrimary}"
    textColor: "#FFFFFF"
    borderRadius: 20
    padding: "16px 32px"
```
```

### Implementation Location
Create lib/core/design_system.md as the single source of truth. This file:
- Contains human-readable prose with design rationale
- Embeds machine-readable YAML tokens for tooling
- Can be parsed to generate Dart constants if needed
- Serves as both documentation and specification

### Token Reference Pattern
Use {path.to.token} syntax for cross-references (e.g., {colors.crimsonPrimary}). This allows:
- Easy conversion to JSON/Figma variables
- Tooling to validate token usage
- AI agents to understand relationships

### Benefits
- **Single source of truth** - No divergence between documentation and code
- **Machine-readable** - Can generate Dart constants automatically
- **Version-controlled** - Changes tracked in git
- **AI-friendly** - Agents can understand and apply tokens correctly

---

## 2. Google Sign-In Flutter Integration

### Recommended Library
**google_sign_in: ^6.2.1** (already in pubspec.yaml)

### Key API Changes in v7.x (Critical)

The package has breaking changes from 6.x to 7.x:

1. **Singleton Pattern**: GoogleSignIn.instance (no constructor instantiation)
2. **Initialization Required**: Must call await GoogleSignIn.instance.initialize() before use
3. **Method Rename**: signIn() → authenticate()
4. **Token Separation**: ID token and access token are now separate
5. **Authorization vs Authentication**: Scopes requested separately from sign-in

### Implementation Pattern

```dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  GoogleAuthService() {
    // Initialize only on mobile (not web)
    if (!kIsWeb) {
      GoogleSignIn.instance.initialize(
        clientId: 'YOUR_CLIENT_ID',
        serverClientId: 'YOUR_SERVER_CLIENT_ID', // For backend auth code
      );
    }
  }

  Future<GoogleSignInAccount?> signIn() async {
    final GoogleSignIn googleSignIn = GoogleSignIn.instance;
    
    // Lightweight authentication (no scopes)
    final result = await googleSignIn.signInSilently();
    if (result != null) return result;
    
    // Full sign-in with scopes
    return await googleSignIn.signIn();
  }

  Future<String?> getIdToken() async {
    final account = GoogleSignIn.instance.currentUser;
    if (account == null) return null;
    
    final authentication = await account.authentication;
    return authentication.idToken;
  }

  Future<String?> getServerAuthCode() async {
    final account = GoogleSignIn.instance.currentUser;
    if (account == null) return null;
    
    final authentication = await account.authentication;
    return authentication.serverAuthCode; // For backend exchange
  }

  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
  }
}
```

### Web Platform Pitfalls (CRITICAL)

**Problem**: Calling initialize() without clientId on web causes infinite hang/blank screen.

**Solution**:
```dart
if (!kIsWeb) {
  await GoogleSignIn.instance.initialize();
}
```

Or use Firebase Auth's web-specific flow instead of google_sign_in on web.

### Scopes Configuration

Per user decision (email/profile only):
```dart
GoogleSignIn.instance.initialize(
  scopes: ['email', 'profile'],
);
```

### Backend Integration Architecture

#### Option A: ID Token Verification (Recommended for OfferNepal)

**Flow**:
1. Mobile app gets ID token from Google Sign-In
2. Mobile app sends ID token to backend endpoint POST /auth/google
3. Backend verifies ID token using Google's public keys
4. Backend creates/links user account, returns JWT tokens
5. Mobile app stores JWT tokens (existing flutter_secure_storage pattern)

**Pros**:
- Simpler backend (no OAuth client secret needed on mobile)
- No additional network round-trip for token exchange
- Secure (ID token signed by Google)

**Cons**:
- No offline access to Google APIs on backend
- ID token expires in 1 hour

**Backend Implementation** (NestJS):
```typescript
// google-auth.strategy.ts
import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy, VerifyCallback } from 'passport-google-oauth20';

@Injectable()
export class GoogleStrategy extends PassportStrategy(Strategy, 'google') {
  constructor() {
    super({
      clientID: process.env.GOOGLE_CLIENT_ID,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET,
      callbackURL: `${process.env.APP_URL}/auth/google/callback`,
      scope: ['email', 'profile'],
    });
  }

  async validate(
    accessToken: string,
    refreshToken: string,
    profile: any,
    done: VerifyCallback,
  ) {
    const { id, name, emails, photos } = profile;
    const user = {
      googleId: id,
      email: emails[0].value,
      firstName: name.givenName,
      lastName: name.familyName,
      picture: photos[0]?.value,
    };
    done(null, user);
  }
}
```

**ID Token Verification** (using google-auth-library):
```typescript
import { OAuth2Client } from 'google-auth-library';

const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

async function verifyGoogleToken(idToken: string) {
  const ticket = await client.verifyIdToken({
    idToken,
    audience: process.env.GOOGLE_CLIENT_ID,
  });
  const payload = ticket.getPayload();
  return payload; // { sub, email, name, picture, etc. }
}
```

#### Option B: Authorization Code Flow (For Backend API Access)

**Flow**:
1. Mobile app gets serverAuthCode from Google Sign-In
2. Mobile app sends code to backend
3. Backend exchanges code for access/refresh tokens with Google
4. Backend can call Google APIs offline

**Pros**:
- Backend gets
