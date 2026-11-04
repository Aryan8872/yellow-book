# Phase 9: UI Consistency & OAuth Integration - Context

**Phase:** 9
**Created:** 2026-11-04
**Status:** Discussion Complete

---

## Phase Objective

Ensure UI consistency across the app, implement OAuth authentication, enhance avatar upload functionality, and improve map markers for better user experience.

---

## Canonical References

- .planning/ROADMAP.md - Phase 9 definition and success criteria
- .planning/PROJECT.md - Project context and architecture
- .planning/REQUIREMENTS.md - User stories and acceptance criteria (F1.3: Google OAuth, F4.2: Profile editing, NFR12: Consistent design language)
- lib/core/theme/app_theme.dart - Current design system implementation
- lib/features/home/presentation/widgets/location_selection_modal.dart - Location selection modal to be updated
- lib/features/auth/presentation/pages/edit_profile_page.dart - Edit profile page to be enhanced
- lib/features/map/presentation/widgets/category_map_marker_factory.dart - Map marker implementation
- api/offernepal/src/modules/auth/strategies/google.strategy.ts - Backend Google OAuth strategy
- api/offernepal/src/modules/upload/upload.service.ts - Backend upload service with multipart support

---

## Locked Requirements (from REQUIREMENTS.md)

**F1.3:** Support Google OAuth login
**F4.2:** Allow profile editing
**NFR12:** Consistent design language

---

## Decisions

### OAuth Implementation

**D1: OAuth Scope**
- Decision: Email and profile only
- Rationale: Minimal data collection, better privacy, standard for most apps. User can update profile with additional details later.
- Implementation: Use ['email', 'profile'] scope in Google Sign-In configuration. Do not request phone, address, or other scopes.

**D2: OAuth Button Placement**
- Decision: Bottom of form (below email/password)
- Rationale: Email/password is the primary authentication method. OAuth is a secondary convenience option.
- Implementation: Place "Continue with Google" button below the email/password form. No divider needed, just spacing.

**D3: Auto-fill Behavior**
- Decision: Auto-fill all fields
- Rationale: Faster onboarding, reduces friction. User can edit fields if needed after OAuth.
- Implementation: On successful OAuth registration, auto-fill name and email from Google profile. Display edit profile page where user can modify before saving.

### Avatar Image Upload

**D4: Image Size Target**
- Decision: Max 2MB
- Rationale: Good quality while maintaining reasonable upload times for typical mobile connections.
- Implementation: Compress images to max 2MB before upload. If original is smaller, don't upscale.

**D5: Compression Quality**
- Decision: 85%
- Rationale: High quality preservation for avatar images, acceptable file size with 2MB target.
- Implementation: Use image quality parameter of 85 during compression.

**D6: Camera Permission Fallback**
- Decision: Silent fallback to gallery
- Rationale: Smoother UX, user can still upload photo even if camera permission denied.
- Implementation: When camera permission denied, automatically show gallery picker without permission dialog. No blocking dialogs.

**D7: Upload Failure Handling**
- Decision: Auto-retry 3 times with exponential backoff
- Rationale: Smoother UX, handles temporary network failures automatically without user intervention.
- Implementation: Implement retry logic with exponential backoff (1s, 2s, 4s delays). Show retry status to user. After 3 failures, show error message with manual retry button.

### Design System Documentation (Sensible Default)

**D8: Design System Documentation Format**
- Decision: Markdown file in lib/core/design_system.md
- Rationale: Most maintainable, standard documentation format, easy to update and version control.
- Implementation: Create comprehensive design system documentation as Markdown file with sections for colors, typography, spacing, shadows, components, and usage examples.

### Map Marker Display (Sensible Default)

**D9: Map Marker Text Display**
- Decision: Show branch names at zoom level 12+, truncate with ellipsis if too long
- Rationale: Balance between readability and performance. Names only visible when zoomed in enough to be useful.
- Implementation: Display branch names on markers when map zoom level >= 12. Truncate names longer than 20 characters with ellipsis. Full name shown on marker tap.

---

## Specifics

### Design System
- Document all color tokens from app_theme.dart with usage contexts
- Document typography scale (11px to 38px) with use cases per text style
- Document spacing patterns (4px grid system: 4, 8, 12, 16, 20, 24, 32, 48)
- Document shadow system (softCardShadow, cardDeckShadow, floatingDockShadow)
- Document component patterns (cards, buttons, inputs, modals)
- Document border radius standards (18-28px)

### OAuth Flow
- Initialize GoogleSignIn with email and profile scope only
- On sign-in success, extract idToken and send to backend /auth/google/callback endpoint
- Backend validates OAuth, creates/updates user, returns JWT tokens
- Store tokens securely (using flutter_secure_storage from Phase 1)
- On registration, auto-fill user profile with name and email from Google data
- Allow user to edit profile fields before final save

### Avatar Upload
- Show bottom sheet with "Camera" and "Gallery" options when user taps avatar
- If camera permission denied, silently show gallery picker
- Compress image to max 2MB with 85% quality before upload
- Use multipart/form-data to send image to backend upload endpoint
- On upload failure, auto-retry 3 times with exponential backoff (1s, 2s, 4s)
- Show loading indicator during upload
- On success, update avatar display immediately and save URL to user profile
- On final failure, show error message with manual retry button

### Map Markers
- Increase marker size from 72x88px to 108x132px (1.5x scale)
- Render branch name text below marker using Plus Jakarta Sans font
- Only show text when zoom level >= 12
- Truncate names longer than 20 characters with ellipsis
- Use category-based colors from existing _colorFor() method
- Cache rendered markers for performance

---

## Prior Decisions (from PROJECT.md & Phase 1-8)

**Architecture:**
- Clean Architecture with BLoC state management
- Dio for networking with interceptors
- get_it + injectable for dependency injection
- flutter_secure_storage for secure token storage (from Phase 1)

**Authentication:**
- JWT Bearer tokens with automatic refresh
- Token storage in flutter_secure_storage (Phase 1 requirement)
- Email/password login/register already implemented

**API Integration:**
- Base URL: Configured per platform (Web: localhost:3000, Android: 10.0.2.2:3000)
- Backend already has Google OAuth strategy implemented

**Design:**
- AppTheme well-defined in lib/core/theme/app_theme.dart
- Plus Jakarta Sans font family
- Pastel color palette with Himalayan Crimson primary
- Soft card shadows and rounded components

---

## Codebase Context

**Existing OAuth Backend:**
- api/offernepal/src/modules/auth/strategies/google.strategy.ts - Google OAuth strategy exists
- Uses environment variables: GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, GOOGLE_CALLBACK_URL
- Validates via authService.validateOAuthLogin()
- Returns user data after validation

**Existing Upload Backend:**
- api/offernepal/src/modules/upload/upload.service.ts - Upload service with multipart support
- Supports LocalStorageProvider and CloudinaryStorageProvider
- MIME types: JPEG, PNG, WEBP, GIF, SVG, MP4
- Max size: 10MB
- Returns URL after upload

**Current Mobile App State:**
- Location selection modal exists but uses basic Material Design
- Edit profile page exists with gallery-only image picker
- Map markers rendered at 72x88px, no text labels
- No Google Sign-In integration on mobile
- Design system in code but not documented

---

## Deferred Ideas

None identified during discussion.

---

## Next Steps

1. Create design system documentation (lib/core/design_system.md)
2. Update location selection modal to match app theme
3. Implement Google Sign-In on mobile app (add dependency, configure, integrate)
4. Add OAuth buttons to login/regis
