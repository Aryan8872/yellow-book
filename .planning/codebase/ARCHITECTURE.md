---
last_mapped_commit: f6310e9fedcdac500a2a7c1adbdb2aa4a2d82305
last_mapped_at: 2026-10-07
---

# Architecture

**Analysis Date:** 2026-10-07

## Architectural Pattern

**Clean Architecture** with BLoC state management following Flutter best practices.

### Layers

1. **Presentation Layer** (presentation/)
   - UI components (pages, widgets)
   - BLoC state management
   - User interactions
   - Location: `lib/features/*/presentation/`

2. **Domain Layer** (domain/)
   - Business entities
   - Repository interfaces
   - Use cases
   - Location: `lib/features/*/domain/`

3. **Data Layer** (data/)
   - Data sources (remote, local)
   - Repository implementations
   - Data models
   - Location: `lib/features/*/data/`

4. **Core Layer** (core/)
   - Cross-cutting concerns
   - Dependency injection
   - Network configuration
   - Storage
   - Theme
   - Location: `lib/core/`

## Module Structure

### Core Modules (Infrastructure)

**Dependency Injection** (`lib/core/di/`)
- Service locator setup with get_it
- Injectable code generation
- Dio client configuration
- Token storage integration
- Location: `lib/core/di/dependency_injection.dart`, `service_loader.dart`

**Network** (`lib/core/network/`)
- Dio HTTP client with interceptors
- Token refresh logic
- Base URL configuration
- Common response handling
- Location: `lib/core/network/dio_client.dart`, `base_urls.dart`, `api_endpoints.dart`

**Storage** (`lib/core/storage/`)
- Token storage (in-memory)
- Future: Secure storage for sensitive data
- Location: `lib/core/storage/token_storage.dart`

**Theme** (`lib/core/theme/`)
- App theme configuration
- Color schemes
- Typography
- Location: `lib/core/theme/app_theme.dart`

**Error Handling** (`lib/core/errors/`)
- Exception types
- Failure types
- Error handling utilities
- Location: `lib/core/errors/`

**Widgets** (`lib/core/widgets/`)
- Reusable UI components
- Glass container
- Section headings
- Slide-to-confirm buttons
- Location: `lib/core/widgets/`

### Feature Modules

**Auth Module** (`lib/features/auth/`)
- User authentication (login, register)
- Token management
- Profile management
- BLoC: `AuthBloc`
- Location: `lib/features/auth/`

**Home Module** (`lib/features/home/`)
- Home feed with featured offers
- Category browsing
- Map integration
- Search functionality
- BLoC: `HomeBloc`, `MapBloc`, `SearchBloc`, `OfferDetailBloc`
- Location: `lib/features/home/`

**Offer Module** (`lib/features/offer/`)
- Offer details
- Offer redemption
- Offer tracking
- Location: `lib/features/offer/`

**Catalog Module** (`lib/features/catalog/`)
- Offer catalog
- Filtering
- Sorting
- Location: `lib/features/catalog/`

**Map Module** (`lib/features/map/`)
- Map view of offers
- Location-based discovery
- Location: `lib/features/map/`

**Profile Module** (`lib/features/profile/`)
- User profile
- Settings
- Location: `lib/features/profile/`

**Search Module** (`lib/features/search/`)
- Search functionality
- Location: `lib/features/search/`

## Data Flow

### Request Lifecycle

1. **User Interaction**
   - User interacts with UI widget
   - Event emitted to BLoC

2. **BLoC Processing**
   - BLoC receives event
   - Calls use case from domain layer

3. **Use Case Execution**
   - Use case calls repository interface
   - Business logic validation

4. **Repository Implementation**
   - Repository calls data source
   - Maps data between layers

5. **Data Source**
   - Remote: API call via Dio
   - Local: Database query via Floor/SQLite

6. **Response**
   - Data flows back through layers
   - BLoC emits new state
   - UI rebuilds with new state

### Authentication Flow

1. User enters credentials in login form
2. `AuthBloc` emits `LoginEvent`
3. `LoginUseCase` calls `AuthRepository`
4. `AuthRepositoryImpl` calls `AuthRemoteDatasource`
5. Dio POST to `/auth/login`
6. Response with access/refresh tokens
7. Tokens stored in `TokenStorage`
8. `AuthBloc` emits `Authenticated` state
9. User navigated to home screen

### Token Refresh Flow

1. API request fails with 401
2. `DioClient` interceptor catches error
3. Checks if refresh token exists
4. If refresh in progress, queues request
5. Calls `authRemote.refresh()`
6. Saves new tokens to storage
7. Retries original request with new token
8. Drains queued requests with new token
9. If refresh fails, clears tokens and fails all requests

## Dependency Injection

### Service Locator Pattern

- **get_it** - Service locator container
- **injectable** - Code generation for registration
- **LazySingleton** - Single instance created on first use
- **@module** - Dependency injection module

### Key Dependencies

- `TokenStorage` - LazySingleton
- `Dio` - LazySingleton with interceptors
- `AuthRemoteDatasource` - LazySingleton
- `HomeRemoteDataSource` - LazySingleton
- `CategoryRemoteDataSource` - LazySingleton
- `DioClient` - LazySingleton
- `AuthRepository` - LazySingleton
- `HomeRepository` - LazySingleton
- `OfferRepository` - LazySingleton

## State Management

### BLoC Pattern

- **Events** - User actions/intents
- **States** - UI states
- **BLoC** - Business logic component
- **BlocProvider** - Provides BLoC to widget tree

### Example: AuthBloc

**Events:**
- `LoginRequested`
- `RegisterRequested`
- `LogoutRequested`

**States:**
- `AuthInitial`
- `AuthLoading`
- `Authenticated`
- `AuthError`

## Network Architecture

### HTTP Client Configuration

- **Base URL:** Configured per platform (Web/Android)
- **Timeouts:** 15 seconds connect/receive
- **Headers:** Content-Type, Accept, Authorization
- **Interceptors:** Auth interceptor, token refresh

### Error Handling

- HTTP errors caught in Dio interceptors
- Token refresh on 401
- Custom error types in `core/errors/`
- User-friendly error messages

## Storage Architecture

### Token Storage

- **Current:** In-memory (not persisted)
- **Future:** Secure storage (flutter_secure_storage)
- **Location:** `lib/core/storage/token_storage.dart`

### Local Database

- **Floor ORM** - Type-safe SQLite access
- **sqflite** - SQLite database plugin
- **Future:** Offline data caching

## Navigation Architecture

### go_router

- Declarative routing
- Route guards for authentication
- Deep linking support
- Location: `lib/config/routes.dart` (currently empty)

## Firebase Integration

- **firebase_core** - Initialized in main()
- **firebase_options.dart** - Platform-specific configuration
- **Future:** Push notifications, analytics

## Performance Optimizations

### Image Caching

- **cached_network_image** - Prevents re-downloads
- GPU decode caching
- Memory-efficient scrolling

### Code Generation

- **freezed** - Immutable classes reduce rebuilds
- **json_serializable** - Fast JSON parsing
- **injectable** - Fast DI resolution

## Security Considerations

### Current State

- Token storage is in-memory (not secure)
- No certificate pinning
- Base URLs hardcoded

### Recommendations

- Use flutter_secure_storage for tokens
- Add certificate pinning
- Environment-based configuration
- API key protection

---
*Codebase analysis: 2026-10-07*
