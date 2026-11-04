---
status: testing
phase: 9-ui-consistency-oauth-integration
source: manual (PLAN.md + implementation review)
started: 2026-11-04
updated: 2026-11-04
---

## Current Test

number: 1
name: Cold Start Smoke Test
expected: |
  Kill any running backend/mobile app. Start the backend from scratch. Any migration/seed completes, and the app boots without errors. A basic API call (health check or categories) returns live data.
awaiting: user response

## Tests

### 1. Cold Start Smoke Test
expected: Kill any running server/service. Clear ephemeral state. Start the application from scratch. Server boots without errors, any seed/migration completes, and a primary query returns live data.
result: pass

### 2. Profile/Account version display
expected: Open Profile and Account pages. The version string is read from the installed app (e.g. v1.0.14+14), not a hardcoded value.
result: pass

### 3. No repeated update prompt
expected: When the installed build number matches the published manifest, opening the app does not show the update dialog.
result: pending

### 4. Wellness replaces Beauty
expected: Category list shows "Wellness" and no separate "Beauty" category. Existing beauty offers appear under Wellness.
result: pending

### 5. Hotel category visible
expected: "Hotel" appears in the home category grid and map filters.
result: pending

### 6. Rooms & Flats category visible
expected: "Rooms & Flats" appears in the home category grid and map filters.
result: pending

### 7. Scratch page back button
expected: On the Scratch tab, tapping the top back arrow switches to Home without a black screen. Android back on non-home tabs also returns Home.
result: pending

### 8. Map markers for new categories
expected: Map pins render distinct shapes/colors for Hotel and Rooms & Flats without errors.
result: pending

### 9. Google Sign-In
expected: Tapping "Continue with Google" opens the native account picker. With GOOGLE_SERVER_CLIENT_ID configured, sign-in succeeds; without it, a clear error is shown rather than a silent failure.
result: pending

### 10. Avatar upload
expected: In Edit Profile, choosing camera or gallery compresses the image and uploads it; the new avatar displays after success.
result: pending

## Summary

total: 10
passed: 0
issues: 0
pending: 10
skipped: 0

## Gaps

[none yet]
