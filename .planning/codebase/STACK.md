---
last_mapped_commit: f6310e9fedcdac500a2a7c1adbdb2aa4a2d82305
last_mapped_at: 2026-10-07
---

# Tech Stack

**Analysis Date:** 2026-10-07

## Core Framework

- **Flutter** - Cross-platform mobile app framework
- **Dart** - Programming language (SDK ^3.13.4)
- **Version:** 1.0.11+11

## State Management

- **flutter_bloc** ^8.1.3 - BLoC pattern implementation
- **get_it** ^7.6.4 - Service locator for dependency injection
- **injectable** ^2.3.2 - Code generation for DI

## Networking

- **dio** ^5.3.3 - HTTP client with interceptors
- Custom token refresh logic in `DioClient`
- Base URL configuration per platform (Web/Android)

## Local Storage

- **floor** ^1.4.2 - SQLite ORM
- **sqflite** ^2.3.0 - SQLite database plugin
- **TokenStorage** - In-memory token storage (not persisted)

## Navigation

- **go_router** ^12.1.1 - Declarative routing

## Maps & Location

- **flutter_map** ^7.0.2 - Map rendering
- **latlong2** ^0.9.1 - Latitude/longitude utilities
- **geolocator** ^13.0.2 - GPS location services

## Image Handling

- **cached_network_image** ^3.4.1 - Image caching to prevent re-downloads

## Firebase

- **firebase_core** ^3.8.1 - Firebase integration
- Generated firebase_options.dart for platform configuration

## Code Generation

- **build_runner** ^2.4.13 - Code generation runner
- **freezed** ^2.5.2 - Immutable classes with code generation
- **freezed_annotation** ^2.4.1 - Freezed annotations
- **json_annotation** ^4.9.0 - JSON serialization annotations
- **json_serializable** ^6.8.0 - JSON serialization code gen
- **injectable_generator** ^2.6.2 - DI code generation
- **floor_generator** ^1.4.2 - Floor ORM code generation

## UI & Theming

- **google_fonts** ^6.2.1 - Google Fonts integration
- **cupertino_icons** ^1.0.8 - iOS-style icons
- Custom theme in `core/theme/app_theme.dart`

## Utilities

- **dartz** ^0.10.1 - Functional programming utilities

## App Update

- **package_info_plus** ^8.1.2 - App version info
- **ota_update** ^7.1.0 - Over-the-air update mechanism

## Development Tools

- **flutter_launcher_icons** ^0.13.1 - App icon generation
- **flutter_lints** ^6.0.0 - Flutter linting rules

## Architecture Pattern

- **Clean Architecture** - Separation of concerns with layers:
  - `data/` - Data sources, repositories implementation
  - `domain/` - Entities, repositories interfaces, use cases
  - `presentation/` - BLoC, pages, widgets

## Environment Configuration

- **BASE_URL** - Compile-time environment variable for API base URL
- Debug mode: `http://localhost:3000/api/v1` (Web) or `http://10.0.2.2:3000/api/v1` (Android)
- Production: `https://yellow-bookapi-production.up.railway.app/api/v1` (commented out)

---
*Codebase analysis: 2026-10-07*
