---
last_mapped_commit: f6310e9fedcdac500a2a7c1adbdb2aa4a2d82305
last_mapped_at: 2026-10-07
---

# Directory Structure

**Analysis Date:** 2026-10-07

## Root Directory

```
mobileapp/
├── .dart_tool/               # Dart build tools
├── .flutter-plugins-dependencies  # Flutter plugin dependencies
├── .git/                     # Git repository
├── .github/                  # GitHub workflows
├── .idea/                    # IDE configuration
├── .metadata                 # Flutter metadata
├── android/                 # Android platform code
├── assets/                   # App assets (images, fonts)
├── build/                    # Build output
├── docs/                     # Documentation
├── entertainer basic screns/ # Basic screens (legacy)
├── ios/                      # iOS platform code
├── lib/                      # Source code
├── test/                     # Test files
├── web/                      # Web platform code
├── analysis_options.yaml     # Dart analyzer configuration
├── app_version.json          # App version info
├── build.yaml                # Build configuration
├── firebase.json             # Firebase configuration
├── pubspec.lock              # Dependency lock file
├── pubspec.yaml              # Project dependencies
└── vercel.json               # Vercel deployment config
```

## Source Directory (`lib/`)

```
lib/
├── config/                   # Configuration files
│   ├── app_config.dart       # App configuration
│   ├── env.dart              # Environment variables
│   └── routes.dart           # Route definitions
├── core/                     # Core utilities and cross-cutting concerns
│   ├── bloc/                 # BLoC utilities
│   │   ├── app_bloc_observer.dart
│   │   └── bloc_provider.dart
│   ├── config/               # Core configuration
│   ├── di/                   # Dependency injection
│   │   ├── dependency_injection.dart
│   │   ├── service_loader.config.dart
│   │   └── service_loader.dart
│   ├── errors/               # Error handling
│   │   ├── error_handling.dart
│   │   ├── exceptions.dart
│   │   └── failure.dart
│   ├── layout/               # Layout components
│   │   └── main_shell_screen.dart
│   ├── loaders/              # Loading widgets
│   │   └── loading_widget.dart
│   ├── location/             # Location services
│   ├── navigation/           # Navigation utilities
│   ├── network/              # Network layer
│   │   ├── api_endpoints.dart
│   │   ├── base_urls.dart
│   │   ├── common_response.dart
│   │   └── dio_client.dart
│   ├── services/             # Core services
│   │   ├── app_update_service.dart
│   │   └── update_available_dialog.dart
│   ├── storage/              # Storage layer
│   │   └── token_storage.dart
│   ├── theme/                # App theming
│   │   └── app_theme.dart
│   ├── usecase/              # Use case base class
│   │   └── usecase.dart
│   └── widgets/              # Reusable widgets
│       ├── glass_container.dart
│       ├── section_gap_normal.dart
│       ├── section_heading.dart
│       ├── slide_to_action_slider.dart
│       ├── slide_to_confirm_button.dart
│       └── tactile_segmented_control.dart
├── features/                 # Feature modules
│   ├── auth/                 # Authentication feature
│   ├── catalog/              # Catalog feature
│   ├── home/                 # Home feature
│   ├── map/                  # Map feature
│   ├── offer/                # Offer feature
│   ├── profile/              # Profile feature
│   └── search/               # Search feature
├── firebase_options.dart     # Firebase configuration
└── main.dart                 # Application entry point
```

## Feature Module Structure

Each feature follows Clean Architecture:

```
feature_name/
├── data/                     # Data layer
│   ├── datasources/          # Data sources (remote, local)
│   ├── models/               # Data models (DTOs)
│   └── repositories/         # Repository implementations
├── domain/                   # Domain layer
│   ├── entities/             # Domain entities
│   ├── repositories/         # Repository interfaces
│   └── usecases/             # Use cases
└── presentation/             # Presentation layer
    ├── bloc/                 # BLoC state management
    │   ├── feature_bloc.dart
    │   ├── feature_event.dart
    │   └── feature_state.dart
    ├── pages/                # Screen pages
    └── widgets/              # Feature-specific widgets
```

## Key File Locations

### Entry Points

- **Application Bootstrap:** `lib/main.dart`
- **DI Configuration:** `lib/core/di/dependency_injection.dart`
- **Service Loader:** `lib/core/di/service_loader.dart`

### Configuration

- **Dependencies:** `pubspec.yaml`
- **Environment:** `lib/config/env.dart` (empty)
- **Routes:** `lib/config/routes.dart` (empty)
- **App Config:** `lib/config/app_config.dart` (empty)

### Network

- **Dio Client:** `lib/core/network/dio_client.dart`
- **Base URLs:** `lib/core/network/base_urls.dart` (empty)
- **API Endpoints:** `lib/core/network/api_endpoints.dart` (empty)
- **Common Response:** `lib/core/network/common_response.dart`

### Storage

- **Token Storage:** `lib/core/storage/token_storage.dart`

### Theme

- **App Theme:** `lib/core/theme/app_theme.dart`

### Authentication

- **Auth BLoC:** `lib/features/auth/presentation/bloc/auth_bloc.dart`
- **Auth Repository:** `lib/features/auth/domain/repositories/auth_repository.dart`
- **Auth Remote Datasource:** `lib/features/auth/data/datasources/remote/auth_remote_datasource.dart`

### Home

- **Home BLoC:** `lib/features/home/presentation/bloc/home_bloc.dart`
- **Home Repository:** `lib/features/home/domain/repositories/home_repository.dart`
- **Home Remote Datasource:** `lib/features/home/data/datasources/home_remote_datasource.dart`

## Naming Conventions

### Files

- **BLoC:** `{feature}_bloc.dart`, `{feature}_event.dart`, `{feature}_state.dart`
- **Use Cases:** `{action}_usecase.dart`, `{action}_params.dart`
- **Repositories:** `{feature}_repository.dart` (interface), `{feature}_repository_impl.dart` (implementation)
- **Data Sources:** `{feature}_remote_datasource.dart`, `{feature}_local_datasource.dart`
- **Models:** `{entity}_model.dart`
- **Entities:** `{entity}.dart`
- **Pages:** `{screen}_page.dart`
- **Widgets:** `{widget}.dart`

### Directories

- **Features:** `lib/features/{feature-name}/`
- **Layers:** `data/`, `domain/`, `presentation/`
- **Data Sources:** `data/datasources/`
- **BLoC:** `presentation/bloc/`
- **Pages:** `presentation/pages/`
- **Widgets:** `presentation/widgets/`

## Module Dependencies

### Import Hierarchy

```
main.dart
  └─> core/di/service_loader.dart
       ├─> core/di/dependency_injection.dart
       │    ├─> core/network/dio_client.dart
       │    ├─> core/storage/token_storage.dart
       │    └─> features/*/data/datasources/
       └─> features/*/presentation/bloc/
            └─> features/*/domain/usecases/
                 └─> features/*/domain/repositories/
                      └─> features/*/data/repositories/
```

### Dependency Rules

- Domain layer has no dependencies on data or presentation
- Presentation depends on domain only
- Data depends on domain only
- Core has no dependencies on features
- Features are independent of each other

## Build Output

```
build/
├── android/                 # Android build artifacts
├── ios/                      # iOS build artifacts
└── web/                      # Web build artifacts
```

## Assets

```
assets/
├── category/                 # Category images
└── logo.jpeg                 # App logo
```

## Platform-Specific Code

```
android/                      # Android native code
├── app/                      # Android app module
├── gradle/                   # Gradle build files
└── keystore/                 # Android signing keys

ios/                          # iOS native code
├── Runner/                   # iOS app module
├── Podfile                   # CocoaPods dependencies
└── Runner.xcworkspace        # Xcode workspace

web/                          # Web platform code
└── index.html               # Web entry point
```

## Configuration Files

- **pubspec.yaml** - Dependencies and Flutter configuration
- **analysis_options.yaml** - Dart analyzer rules
- **build.yaml** - Build configuration for code generation
- **firebase.json** - Firebase deployment configuration
- **vercel.json** - Vercel deployment configuration

## Documentation

- **docs/** - Additional documentation
- **README.md** - Project overview (not present in root)

---
*Codebase analysis: 2026-10-07*
