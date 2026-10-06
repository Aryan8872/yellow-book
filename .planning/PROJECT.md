# OfferNepal Mobile App

**Last updated:** 2026-10-07 after initialization

## What This Is

A Flutter mobile application for customers to discover, browse, and redeem offers from merchants on the OfferNepal platform. The app connects to the NestJS backend API to provide real-time offer listings, location-based discovery, and voucher redemption functionality.

## Core Value

Enable customers to easily find and redeem discounts at local merchants through an intuitive mobile experience, driving foot traffic to merchants and savings for users.

## Context

**Platform:** Flutter (cross-platform: iOS, Android, Web)
**Backend:** NestJS API at `http://localhost:3000/api/v1` (development)
**Architecture:** Clean Architecture with BLoC state management
**Current State:** Partially implemented with auth, home, offers, and map features

## Requirements

### Validated

- ✓ User authentication (login, register) with JWT tokens - existing
- ✓ Token refresh mechanism - existing
- ✓ Home feed with featured/trending offers - existing
- ✓ Category browsing - existing
- ✓ Offer details view - existing
- ✓ Map-based offer discovery - existing
- ✓ Search functionality - existing
- ✓ Location services integration - existing
- ✓ Image caching for performance - existing
- ✓ Firebase core integration - existing

### Active

- [ ] Complete offer redemption flow with voucher code generation
- [ ] User profile management (edit profile, view history)
- [ ] Favorites/bookmarked offers
- [ ] Offer notifications (push notifications)
- [ ] Offline mode with cached offers
- [ ] Secure token storage (flutter_secure_storage)
- [ ] Environment-based configuration (dev/staging/prod)
- [ ] Deep linking for shareable offers
- [ ] App update mechanism (OTA updates)
- [ ] Analytics and crash reporting
- [ ] Proper go_router navigation implementation
- [ ] Test coverage (unit, widget, integration)

### Out of Scope

- Merchant-specific features (separate merchant web app)
- Admin features (separate admin panel)
- Social features (sharing to social media)
- Payment integration (handled by merchants)
- Advanced map features beyond basic display

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Flutter framework | Cross-platform (iOS, Android, Web) from single codebase | — Implemented |
| Clean Architecture | Separation of concerns, testability | — Implemented |
| BLoC state management | Predictable state, testable, Flutter community standard | — Implemented |
| Dio for networking | Interceptor support, token refresh, timeout handling | — Implemented |
| Firebase integration | Future push notifications, analytics | — Partially implemented |
| Floor ORM (not used) | Planned for offline caching | — Pending implementation |
| In-memory token storage | Temporary, needs secure storage | — Needs replacement |

## Architecture

**Tech Stack:**
- Flutter ^3.13.4 with Dart
- flutter_bloc for state management
- Dio for HTTP client with token refresh
- get_it + injectable for dependency injection
- flutter_map + geolocator for maps/location
- Firebase core for platform services

**Module Structure:**
- `features/auth/` - Authentication (login, register, token management)
- `features/home/` - Home feed, categories, map, search
- `features/offer/` - Offer details, redemption
- `features/catalog/` - Offer catalog with filtering
- `features/profile/` - User profile and settings
- `features/map/` - Map-based discovery
- `features/search/` - Search functionality
- `core/` - Shared utilities (network, storage, theme, DI)

## API Integration

**Base URL:** Configured per platform (Web: localhost:3000, Android: 10.0.2.2:3000)
**Authentication:** JWT Bearer tokens with automatic refresh
**Key Endpoints:**
- POST `/auth/login` - User login
- POST `/auth/register` - User registration
- POST `/auth/refresh` - Token refresh
- GET `/offers/home` - Home page data
- GET `/offers` - Offer listing with filters
- GET `/offers/:id` - Offer details
- POST `/offers/:id/redeem` - Track redemption

## Current Concerns

**High Priority:**
- Token storage is in-memory (not secure/persistent)
- No environment-based configuration
- No test coverage
- Empty configuration files (routes, env, app_config)
- go_router not configured

**Medium Priority:**
- No offline support
- No certificate pinning
- Firebase services not actively used
- No CI/CD pipeline

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-10-07 after initialization*
