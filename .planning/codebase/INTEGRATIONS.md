---
last_mapped_commit: f6310e9fedcdac500a2a7c1adbdb2aa4a2d82305
last_mapped_at: 2026-10-07
---

# External Integrations

**Analysis Date:** 2026-10-07

## Backend API Integration

### REST API

- **Purpose:** Primary backend communication
- **Library:** dio ^5.3.3
- **Base URLs:**
  - Debug Web: `http://localhost:3000/api/v1`
  - Debug Android: `http://10.0.2.2:3000/api/v1`
  - Production: `https://yellow-bookapi-production.up.railway.app/api/v1` (commented out)
- **Configuration:** `lib/core/di/dependency_injection.dart`
- **Features:**
  - JWT authentication with Bearer tokens
  - Automatic token refresh on 401 errors
  - Request queuing during token refresh
  - Timeout: 15 seconds (connect/receive)

### API Endpoints

**Authentication:**
- POST `/auth/login` - User login
- POST `/auth/register` - User registration
- POST `/auth/refresh` - Token refresh
- GET `/auth/me` - Get current user profile

**Home/Offers:**
- GET `/offers/home` - Home page data
- GET `/offers` - Offer listing
- GET `/offers/:id` - Offer details
- POST `/offers/:id/view` - Track offer view
- POST `/offers/:id/redeem` - Track offer redemption

**Categories:**
- GET `/categories` - Category listing

### Authentication Flow

1. User logs in via `AuthRemoteDatasource`
2. API returns access + refresh tokens
3. Tokens stored in `TokenStorage` (in-memory)
4. Dio interceptor adds `Authorization: Bearer <token>` header
5. On 401 error, `DioClient` triggers token refresh
6. New tokens saved and request retried
7. If refresh fails, tokens cleared and user logged out

## Firebase Integration

### Firebase Core

- **Purpose:** Firebase platform integration
- **Library:** firebase_core ^3.8.1
- **Configuration:** `lib/firebase_options.dart` (generated)
- **Initialization:** In `main.dart` before `runApp()`
- **Error Handling:** Catches initialization errors, proceeds with fallback

### Current Firebase Features

- **Core SDK** - Initialized but no specific services used yet
- **Platform Configuration** - Generated via FlutterFire CLI

### Potential Firebase Services (Not Yet Implemented)

- **Authentication** - Alternative to custom auth
- **Cloud Firestore** - Real-time database
- **Cloud Messaging** - Push notifications
- **Analytics** - User analytics
- **Crashlytics** - Crash reporting
- **Remote Config** - Remote configuration

## Local Database Integration

### SQLite (Floor ORM)

- **Purpose:** Local data persistence
- **Library:** floor ^1.4.2, sqflite ^2.3.0
- **Status:** Dependencies present but not actively used
- **Code Generation:** floor_generator ^1.4.2
- **Future Use:** Offline caching, local favorites

### Current State

- Floor ORM configured but no database entities defined
- No DAOs (Data Access Objects) implemented
- No database migrations present

## Maps & Location Integration

### flutter_map

- **Purpose:** Map rendering for offer locations
- **Library:** flutter_map ^7.0.2
- **Location Provider:** latlong2 ^0.9.1
- **Features:**
  - OpenStreetMap tiles
  - Marker rendering
  - User location display
- **Usage:** `lib/features/home/presentation/bloc/map_bloc.dart`

### Geolocator

- **Purpose:** GPS location services
- **Library:** geolocator ^13.0.2
- **Features:**
  - Current location detection
  - Location permissions
  - Distance calculations
- **Usage:** Location-based offer discovery

## Image Caching Integration

### cached_network_image

- **Purpose:** Efficient image loading and caching
- **Library:** cached_network_image ^3.4.1
- **Features:**
  - Disk caching
  - Memory caching
  - GPU decode caching
  - Placeholder support
- **Benefits:** Prevents re-downloads on scroll, reduces memory usage

## App Update Integration

### package_info_plus

- **Purpose:** App version information
- **Library:** package_info_plus ^8.1.2
- **Usage:** `lib/core/services/app_update_service.dart`
- **Features:**
  - Current version detection
  - Build number access

### ota_update

- **Purpose:** Over-the-air app updates
- **Library:** ota_update ^7.1.0
- **Usage:** `lib/core/services/update_available_dialog.dart`
- **Features:**
  - Check for updates
  - Download and install updates
  - Update dialog UI

## Dependency Injection Integration

### get_it

- **Purpose:** Service locator for dependency injection
- **Library:** get_it ^7.6.4
- **Configuration:** `lib/core/di/dependency_injection.dart`
- **Code Generation:** injectable ^2.3.2, injectable_generator ^2.6.2
- **Usage:** Singleton and lazy singleton registration

### Injectable Pattern

```dart
@LazySingleton()
class TokenStorage {
  // ...
}

@module
abstract class DependencyInjection {
  @LazySingleton()
  Dio dio(TokenStorage storage) {
    // ...
  }
}
```

## State Management Integration

### flutter_bloc

- **Purpose:** State management using BLoC pattern
- **Library:** flutter_bloc ^8.1.3
- **Usage:** All feature modules use BLoC
- **Observer:** `AppBlocObserver` in `lib/core/bloc/`

### BLoC Observer

- **Location:** `lib/core/bloc/app_bloc_observer.dart`
- **Purpose:** Log state changes and errors
- **Configuration:** Registered in `main.dart`

## Navigation Integration

### go_router

- **Purpose:** Declarative routing
- **Library:** go_router ^12.1.1
- **Status:** Dependency present but not configured
- **Configuration:** `lib/config/routes.dart` (empty)
- **Future Use:** Route-based navigation, deep linking

## Code Generation Integration

### build_runner

- **Purpose:** Code generation orchestration
- **Library:** build_runner ^2.4.13
- **Generators Used:**
  - freezed - Immutable classes
  - json_serializable - JSON serialization
  - injectable_generator - Dependency injection
  - floor_generator - Database ORM

### Build Commands

```bash

# Generate code

flutter pub run build_runner build

# Generate with conflict resolution

flutter pub run build_runner build --delete-conflicting-outputs

# Watch for changes

flutter pub run build_runner watch
```

## UI/UX Integrations

### Google Fonts

- **Purpose:** Custom typography
- **Library:** google_fonts ^6.2.1
- **Usage:** `lib/core/theme/app_theme.dart`
- **Features:** Access to Google Fonts library

### Cupertino Icons

- **Purpose:** iOS-style icons
- **Library:** cupertino_icons ^1.0.8
- **Usage:** iOS platform consistency

## Functional Programming Integration

### dartz

- **Purpose:** Functional programming utilities
- **Library:** dartz ^0.10.1
- **Usage:** Either pattern for error handling
- **Features:** Either<Failure, Success>, Option types

## Platform-Specific Integrations

### Android

- **Location:** `android/` directory
- **Configuration:** AndroidManifest.xml
- **Permissions:** Location, internet (likely)

### iOS

- **Location:** `ios/` directory
- **Configuration:** Info.plist
- **Permissions:** Location, internet (likely)

### Web

- **Location:** `web/` directory
- **Entry Point:** `web/index.html`
- **Configuration:** Web-specific base URL

## Deployment Integrations

### Vercel

- **Purpose:** Web deployment
- **Configuration:** `vercel.json`
- **Status:** Config present but not actively used

### Railway

- **Purpose:** Backend API hosting
- **URL:** `https://yellow-bookapi-production.up.railway.app`
- **Status:** Production API endpoint

## Future Integrations (Planned)

### Push Notifications

- **Firebase Cloud Messaging (FCM)**
- Local notifications
- Offer alerts

### Analytics

- **Firebase Analytics**
- User behavior tracking
- Conversion tracking

### Crash Reporting

- **Firebase Crashlytics**
- Error tracking
- Crash analysis

### Secure Storage

- **flutter_secure_storage**
- Secure token storage
- Sensitive data protection

### Deep Linking

- **go_router** deep linking
- Shareable offer links
- Campaign tracking

## Environment Configuration

### Compile-Time Variables

- **BASE_URL** - API base URL (String.fromEnvironment)
- **Debug/Release** - Build mode detection
- **Platform Detection** - Web vs Android vs iOS

### Configuration Files

- `lib/config/app_config.dart` - Empty (to be implemented)
- `lib/config/env.dart` - Empty (to be implemented)
- `lib/config/routes.dart` - Empty (to be implemented)

## Security Considerations

### Current State

- Token storage is in-memory (not secure)
- No certificate pinning
- Base URLs hardcoded
- No API key encryption

### Recommendations

- Use flutter_secure_storage for tokens
- Add certificate pinning for API calls
- Environment-based configuration
- Secure storage for sensitive data

---
*Codebase analysis: 2026-10-07*
