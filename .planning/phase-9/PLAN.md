# Phase 9: UI Consistency & OAuth Integration - Implementation Plan

**Phase:** 9
**Status:** Pending
**Created:** 2026-11-04
**Priority:** High

---

## Objective

Ensure UI consistency across the app, implement OAuth authentication, enhance avatar upload functionality, and improve map markers for better user experience.

---

## Design System Analysis

### Current Design Tokens (from lib/core/theme/app_theme.dart)

**Color Palette:**
- Canvas/Background: #ECEAF6 (Soft Ceramic Milk Lavender)
- Card Surface: #FFFFFF
- Primary Brand: #E11D48 (Himalayan Crimson)
- Dark Anchors: #0D0D12 (Pitch Black Onyx), #111116 (Dark Pill)
- Pastel Palette:
  - Periwinkle: #9F8EFC
  - Peach: #FF8652
  - Canary: #FFD94A
  - Mint: #76EDB8
  - Coral: #FF5C67
- Text: #0F172A (Primary), #475569 (Secondary), #94A3B8 (Muted)
- Borders: #E2E8F0 (Subtle), #EAE8F4 (Light)

**Typography:**
- Font: Plus Jakarta Sans
- Weights: 500-900 (body to display)
- Tracking: Tight (-0.3 to -1.2)
- Sizes: 11px (body small) to 38px (display large)

**Shadows:**
- Soft Card Shadow: Dual diffuse with blur 24/6
- Card Deck Shadow: Bottom-heavy with negative offset
- Floating Dock Shadow: Heavy blur 32

**Spacing & Components:**
- Border Radius: 18-28px (inputs, cards)
- Input Padding: 18px horizontal, 16px vertical
- Card Border: 1px with borderSubtle

---

## Tasks

### Task 1: Design System Documentation & Location Page UI Update

**Goal:** Document design system and update location selection modal to match app theme

**Subtasks:**

1.1 Create design system documentation file
   - Document all color tokens with usage contexts
   - Document typography scale with use cases
   - Document spacing patterns (4px/8px/16px/24px grid)
   - Document component patterns (cards, buttons, inputs)
   - Document shadow system with elevation levels
   - Document border radius standards

1.2 Analyze location selection modal (lib/features/home/presentation/widgets/location_selection_modal.dart)
   - Current state: Basic Material Design
   - Identify inconsistencies with app theme
   - List specific changes needed (colors, spacing, typography, shadows)

1.3 Update location selection modal UI
   - Replace Material colors with AppTheme tokens
   - Update TextField to use app theme input decoration
   - Apply softCardShadow to action tiles
   - Update typography to Plus Jakarta Sans with proper weights
   - Adjust spacing to match app patterns
   - Update action tiles with consistent card styling
   - Apply app theme border radius and colors
   - Ensure loading states match app theme

1.4 Test location modal
   - Verify visual consistency with other screens
   - Test dark/light theme support (if applicable)
   - Test on different screen sizes

**Verification:**
- Location modal uses only AppTheme colors
- Typography matches Plus Jakarta Sans with correct weights
- Spacing follows 4px grid system
- Shadows match softCardShadow pattern
- Visual consistency verified against home page

---

### Task 2: OAuth Implementation (Mobile App & Backend)

**Goal:** Implement end-to-end OAuth authentication with Google

**Backend Analysis (from api/offernepal/src/modules/auth/strategies/google.strategy.ts):**
- Google OAuth strategy exists with Passport
- Validates OAuth login via authService.validateOAuthLogin()
- Uses environment variables: GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, GOOGLE_CALLBACK_URL
- Scope: email, profile
- Returns user data after validation

**Backend Issues to Fix:**

2.1 Verify OAuth environment configuration
   - Check .env for GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, GOOGLE_CALLBACK_URL
   - Ensure callback URL matches mobile app's redirect scheme
   - Test OAuth flow with Postman or browser

2.2 Verify validateOAuthLogin implementation in auth.service.ts
   - Read the method to check if it handles:
     - New user registration
     - Existing user login
     - Token generation
     - Error handling
   - Fix any gaps or issues

**Mobile App Implementation:**

2.3 Add Google Sign-In dependency
   - Add google_sign_in to pubspec.yaml
   - Configure OAuth credentials in Firebase Console (if using Firebase Auth)
   - OR configure directly with Google OAuth client credentials

2.4 Implement Google Sign-In on mobile
   - Create lib/features/auth/presentation/bloc/google_auth_bloc.dart
   - Implement Google sign-in flow:
     - Initialize GoogleSignIn
     - Trigger sign-in
     - Get idToken
     - Send idToken to backend OAuth endpoint
     - Handle JWT response
     - Store tokens securely
   - Add error handling for:
     - User cancels sign-in
     - Network errors
     - Invalid tokens
     - Backend errors

2.5 Add OAuth UI to login/register screens
   - Add "Continue with Google" button to login page
   - Add "Continue with Google" button to register page
   - Style button with Google brand colors or app theme
   - Add loading state during OAuth flow

2.6 Configure OAuth redirect scheme
   - Add custom URL scheme to android/app/build.gradle
   - Add custom URL scheme to ios/Runner/Info.plist
   - Test deep linking from OAuth callback

2.7 Test OAuth flow end-to-end
   - Test new user registration via Google
   - Test existing user login via Google
   - Test token refresh
   - Test logout
   - Test error scenarios

**Verification:**
- OAuth login creates new user in database
- OAuth login authenticates existing user
- JWT tokens are generated and returned
- Mobile app stores tokens securely
- Token refresh works automatically
- OAuth button visible on login/register screens
- End-to-end flow tested successfully

---

### Task 3: User Profile Page UI Enhancement

**Goal:** Update user profile page UI to match app design system

**Subtasks:**

3.1 Analyze current profile page
   - Locate profile page file (likely lib/features/auth/presentation/pages/profile_page.dart)
   - Identify UI inconsistencies with app theme
   - List specific changes needed

3.2 Update profile page UI
   - Replace hardcoded colors with AppTheme tokens
   - Update typography to Plus Jakarta Sans
   - Apply softCardShadow to cards
   - Update spacing to match app patterns
   - Improve visual hierarchy
   - Ensure consistent border radius
   - Update icon colors to use app theme
   - Improve information architecture

3.3 Add profile sections (if missing)
   - User info card (name, email, phone)
   - Subscription status card
   - Settings/options section
   - Logout button with app theme styling

3.4 Test profile page
   - Verify visual consistency
   - Test on different screen sizes
   - Verify all data displays correctly

**Verification:**
- Profile page uses only AppTheme colors
- Typography matches Plus Jakarta Sans
- Spacing follows app patterns
- Visual hierarchy is clear
- Consistent with other screens

---

### Task 4: Avatar Image Upload (Camera & Gallery)

**Goal:** Enable camera capture for avatar, ensure backend supports multipart upload, fix mobile app data flow

**Backend Analysis (from api/offernepal/src/modules/upload/upload.service.ts):**
- Upload service exists with LocalStorageProvider and CloudinaryStorageProvider
- Supports multipart/form-data with file validation
- MIME types: JPEG, PNG, WEBP, GIF, SVG, MP4
- Max size: 10MB
- Returns URL after upload

**Backend Verification:**

4.1 Verify user profile update endpoint accepts avatar URL
   - Check auth.service.ts update profile method
   - Verify it accepts avatarUrl field
   - Ensure it stores URL in database correctly

4.2 Verify upload endpoint is accessible
   - Check upload.controller.ts for endpoint configuration
   - Ensure it's publicly accessible or authenticated properly
   - Test with Postman

**Mobile App Implementation:**

4.3 Update edit profile page to support camera
   - Modify _pickImage() in edit_profile_page.dart
   - Add option to choose between camera and gallery
   - Show bottom sheet with "Camera" and "Gallery" options
   - Implement camera capture using ImageSource.camera
   - Implement gallery selection using ImageSource.gallery

4.4 Verify UploadRemoteDatasource
   - Check lib/core/network/upload_remote_datasource.dart
   - Ensure it sends multipart/form-data c
