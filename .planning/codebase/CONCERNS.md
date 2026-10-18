---
last_mapped_commit: f6310e9fedcdac500a2a7c1adbdb2aa4a2d82305
last_mapped_at: 2026-10-07
---

# Concerns

**Analysis Date:** 2026-10-07

## Security Concerns

### Token Storage (Critical)

- **Issue:** Tokens stored in-memory (`TokenStorage` class)
- **Risk:** Tokens lost on app restart/reload
- **Impact:** Users must re-login frequently
- **Recommendation:** Use `flutter_secure_storage` for persistent secure token storage
- **Location:** `lib/core/storage/token_storage.dart`

### API Base URL Hardcoding

- **Issue:** Base URLs hardcoded in `dependency_injection.dart`
- **Risk:** Difficult to change environments, potential for production URLs in debug builds
- **Impact:** Deployment errors, security risk if debug URLs exposed
- **Recommendation:** Use environment variables or configuration files
- **Location:** `lib/core/di/dependency_injection.dart`

### No Certificate Pinning

- **Issue:** No SSL certificate pinning for API calls
- **Risk:** Man-in-the-middle attacks possible
- **Impact:** Data interception, credential theft
- **Recommendation:** Implement certificate pinning with dio
- **Location:** `lib/core/network/dio_client.dart`

### Production API URL Commented Out

- **Issue:** Production Railway URL is commented out in code
- **Risk:** Debug builds may use wrong URL in production
- **Impact:** App may not work in production builds
- **Recommendation:** Proper environment-based configuration
- **Location:** `lib/core/di/dependency_injection.dart`

## Architecture Concerns

### Empty Configuration Files

- **Issue:** `app_config.dart`, `env.dart`, `routes.dart` are empty
- **Risk:** Configuration scattered across codebase
- **Impact:** Difficult to maintain, environment switching issues
- **Recommendation:** Implement proper configuration management
- **Location:** `lib/config/`

### go_router Not Configured

- **Issue:** `go_router` dependency present but not configured
- **Risk:** Navigation inconsistencies, no deep linking
- **Impact:** Poor user experience, limited sharing capabilities
- **Recommendation:** Implement go_router with proper route configuration
- **Location:** `lib/config/routes.dart`

### No Offline Support

- **Issue:** Floor ORM present but not used for offline caching
- **Risk:** App requires constant internet connection
- **Impact:** Poor UX in areas with poor connectivity
- **Recommendation:** Implement offline caching for frequently accessed data
- **Location:** Database layer not implemented

### In-Memory Token Storage

- **Issue:** Tokens not persisted across app restarts
- **Risk:** Users logged out on every app restart
- **Impact:** Poor user experience, high login friction
- **Recommendation:** Use secure persistent storage
- **Location:** `lib/core/storage/token_storage.dart`

## Code Quality Concerns

### No Test Coverage

- **Issue:** No test files present in the codebase
- **Risk:** Bugs not caught before production
- **Impact:** Unstable releases, regression bugs
- **Recommendation:** Implement unit, widget, and integration tests
- **Location:** `test/` directory

### Missing Mocking Libraries

- **Issue:** No mocking libraries (mockito, mocktail) configured
- **Risk:** Difficult to write tests for external dependencies
- **Impact:** Low test coverage, fragile tests
- **Recommendation:** Add mocktail or mockito to dev dependencies
- **Location:** `pubspec.yaml`

### No BLoC Testing Utilities

- **Issue:** `bloc_test` not in dependencies
- **Risk:** Difficult to test BLoC state transitions
- **Impact:** Untested state management logic
- **Recommendation:** Add bloc_test to dev dependencies
- **Location:** `pubspec.yaml`

### Empty Files

- **Issue:** Several files are empty (`base_urls.dart`, `api_endpoints.dart`, etc.)
- **Risk:** Confusion about intended functionality
- **Impact:** Development friction, unclear architecture
- **Recommendation:** Implement or remove empty files
- **Location:** Multiple locations in `lib/core/network/`, `lib/config/`

## Performance Concerns

### Image Caching

- **Status:** `cached_network_image` is properly configured
- **Concern:** None - good implementation
- **Location:** `pubspec.yaml`

### Code Generation Overhead

- **Issue:** Multiple code generation dependencies (freezed, injectable, floor, json_serializable)
- **Risk:** Slow build times
- **Impact:** Longer development cycles
- **Recommendation:** Monitor build times, consider selective generation
- **Location:** `pubspec.yaml`

### No Lazy Loading for Features

- **Issue:** All features loaded at startup via DI
- **Risk:** Slower app startup time
- **Impact:** Poor first impression
- **Recommendation:** Consider lazy loading for non-critical features
- **Location:** `lib/core/di/dependency_injection.dart`

## Maintainability Concerns

### Inconsistent File Organization

- **Issue:** Some features have full Clean Architecture structure, others may not
- **Risk:** Inconsistent patterns across codebase
- **Impact:** Difficult to onboard new developers
- **Recommendation:** Enforce consistent structure across all features
- **Location:** `lib/features/`

### Missing Documentation

- **Issue:** No inline documentation for complex logic
- **Risk:** Difficult to understand code intent
- **Impact:** Slower development, potential bugs
- **Recommendation:** Add documentation for complex functions and classes
- **Location:** Throughout codebase

### No Error Handling Strategy

- **Issue:** Error handling exists but no unified strategy
- **Risk:** Inconsistent error messages to users
- **Impact:** Poor user experience, difficult debugging
- **Recommendation:** Implement unified error handling strategy
- **Location:** `lib/core/errors/`

## Dependency Concerns

### Outdated Dependencies

- **Issue:** Some dependencies may be outdated
- **Risk:** Security vulnerabilities, missing features
- **Impact:** Potential security issues, missed improvements
- **Recommendation:** Regular dependency audits and updates
- **Location:** `pubspec.yaml`

### Unused Dependencies

- **Issue:** Some dependencies may not be actively used (e.g., floor, sqflite)
- **Risk:** Unnecessary bloat
- **Impact:** Larger app size, longer build times
- **Recommendation:** Remove unused dependencies or implement their intended use
- **Location:** `pubspec.yaml`

### Firebase Configuration

- **Issue:** Firebase initialized but no services actively used
- **Risk:** Unnecessary overhead
- **Impact:** Larger app size, privacy concerns
- **Recommendation:** Either implement Firebase services or remove dependency
- **Location:** `lib/main.dart`, `pubspec.yaml`

## Platform-Specific Concerns

### Android Configuration

- **Issue:** Android configuration not reviewed
- **Risk:** Missing permissions, incorrect configuration
- **Impact:** App crashes, feature failures on Android
- **Recommendation:** Review AndroidManifest.xml and Gradle config
- **Location:** `android/`

### iOS Configuration

- **Issue:** iOS configuration not reviewed
- **Risk:** Missing permissions, incorrect configuration
- **Impact:** App crashes, feature failures on iOS
- **Recommendation:** Review Info.plist and Xcode project settings
- **Location:** `ios/`

### Web Configuration

- **Issue:** Web platform has different base URL handling
- **Risk:** Inconsistent behavior across platforms
- **Impact:** Platform-specific bugs
- **Recommendation:** Ensure consistent configuration across platforms
- **Location:** `lib/core/di/dependency_injection.dart`

## API Integration Concerns

### Hardcoded API Endpoints

- **Issue:** API endpoints not centralized
- **Risk:** Difficult to update endpoints
- **Impact:** Breaking changes require code changes
- **Recommendation:** Centralize endpoint definitions
- **Location:** `lib/core/network/api_endpoints.dart` (empty)

### No API Versioning Strategy

- **Issue:** API version hardcoded in base URL
- **Risk:** Breaking changes difficult to handle
- **Impact:** App may break when API updates
- **Recommendation:** Implement API versioning strategy
- **Location:** `lib/core/network/base_urls.dart`

### Token Refresh Race Conditions

- **Issue:** Token refresh uses queue mechanism but may have edge cases
- **Risk:** Multiple simultaneous refresh attempts
- **Impact:** Token refresh failures, user logout
- **Recommendation:** Thoroughly test token refresh edge cases
- **Location:** `lib/core/network/dio_client.dart`

## User Experience Concerns

### No Loading States

- **Issue:** Loading widget exists but usage inconsistent
- **Risk:** Poor UX during network operations
- **Impact:** Users don't know app is working
- **Recommendation:** Ensure consistent loading states across all operations
- **Location:** `lib/core/loaders/loading_widget.dart`

### No Error Messages to Users

- **Issue:** Error handling exists but user-facing messages unclear
- **Risk:** Users see technical error messages
- **Impact:** Poor user experience, support burden
- **Recommendation:** Implement user-friendly error messages
- **Location:** Error handling throughout app

### No Offline Mode

- **Issue:** App requires internet connection
- **Risk:** Unusable in poor connectivity areas
- **Impact:** Limited user base, poor reviews
- **Recommendation:** Implement offline mode with cached data
- **Location:** Not implemented

## Deployment Concerns

### No CI/CD Configuration

- **Issue:** No CI/CD pipeline configured
- **Risk:** Manual deployment errors
- **Impact:** Inconsistent releases, potential bugs
- **Recommendation:** Set up CI/CD pipeline (GitHub Actions, Bitrise, etc.)
- **Location:** `.github/` (empty)

### No Automated Testing in CI

- **Issue:** No automated tests run in deployment pipeline
- **Risk:** Bugs deployed to production
- **Impact:** Unstable releases
- **Recommendation:** Add automated tests to CI/CD
- **Location:** Not configured

### Vercel Config Present but Not Used

- **Issue:** `vercel.json` exists but web deployment not configured
- **Risk:** Confusion about deployment strategy
- **Impact:** Unused configuration
- **Recommendation:** Either implement web deployment or remove config
- **Location:** `vercel.json`

## Priority Recommendations

### High Priority

1. **Implement secure token storage** - Use flutter_secure_storage
2. **Environment-based configuration** - Proper dev/staging/prod setup
3. **Add test coverage** - Unit, widget, and integration tests
4. **Implement go_router** - Proper navigation and deep linking
5. **Fix empty configuration files** - Implement or remove

### Medium Priority

1. **Implement offline caching** - Use Floor ORM
2. **Add certificate pinning** - Improve security
3. **Set up CI/CD pipeline** - Automated testing and deployment
4. **Centralize API endpoints** - Better maintainability
5. **Implement Firebase services** - Or remove if not needed

### Low Priority

1. **Optimize code generation** - Reduce build times
2. **Add comprehensive documentation** - Improve maintainability
3. **Implement lazy loading** - Improve startup time
4. **Review platform configurations** - Ensure consistency

---
*Codebase analysis: 2026-10-07*
