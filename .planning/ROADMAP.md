# Roadmap

**Last updated:** 2026-10-07

## Phase 1: Foundation & Security (Priority: High)

**Goal:** Establish secure foundation and fix critical architecture issues

### Plans

1. **Implement Secure Token Storage**
   - Replace in-memory TokenStorage with flutter_secure_storage
   - Migrate existing token management
   - Test token persistence across app restarts

2. **Environment-Based Configuration**
   - Implement app_config.dart with environment variables
   - Create dev/staging/prod configurations
   - Update dependency_injection.dart to use config
   - Remove hardcoded base URLs

3. **Implement go_router Navigation**
   - Configure go_router with route definitions
   - Add route guards for authentication
   - Implement deep linking support
   - Migrate from current navigation to go_router

4. **Fix Empty Configuration Files**
   - Implement or remove empty files (base_urls.dart, api_endpoints.dart, env.dart)
   - Centralize API endpoint definitions
   - Document configuration structure

**Success Criteria:**
- Tokens persist securely across app restarts
- Environment switching works without code changes
- Navigation uses go_router with proper guards
- No empty configuration files remain

---

## Phase 2: Core Feature Completion (Priority: High)

**Goal:** Complete core user-facing features

### Plans

1. **Complete Offer Redemption Flow**
   - Implement redemption code generation UI
   - Connect to backend redemption endpoint
   - Display redemption history
   - Add offer expiration display
   - Enforce redemption limits

2. **User Profile Management**
   - Implement profile editing UI
   - Connect to backend profile endpoints
   - Display subscription status
   - Add profile picture upload

3. **Favorites/Bookmarks**
   - Implement bookmark functionality
   - Add favorites screen
   - Persist bookmarks locally
   - Sync with backend when available

**Success Criteria:**
- Users can generate and view redemption codes
- Users can edit their profile
- Users can bookmark offers
- All features work offline with sync

---

## Phase 3: Offline Support (Priority: Medium)

**Goal:** Enable app usage without internet connection

### Plans

1. **Implement Local Database**
   - Define Floor ORM entities for offers, categories
   - Create DAOs for data access
   - Implement database migrations

2. **Data Caching Strategy**
   - Cache offers on first load
   - Implement cache invalidation logic
   - Sync strategy when connection restored
   - Display sync status to users

3. **Offline UI States**
   - Show cached data when offline
   - Display offline banner
   - Disable features requiring internet
   - Queue actions for sync when online

**Success Criteria:**
- App works offline for cached data
- Data syncs automatically when online
- Users understand offline state
- No data loss during sync

---

## Phase 4: Testing & Quality (Priority: High)

**Goal:** Establish comprehensive test coverage

### Plans

1. **Unit Tests**
   - Add mocktail to dependencies
   - Write tests for all use cases
   - Write tests for repository implementations
   - Write tests for data source transformations
   - Target: 70%+ coverage

2. **Widget Tests**
   - Add bloc_test to dependencies
   - Write tests for all screens
   - Write tests for custom widgets
   - Test user interactions
   - Test state changes

3. **Integration Tests**
   - Set up integration_test directory
   - Write tests for auth flow
   - Write tests for offer discovery flow
   - Write tests for redemption flow

4. **CI/CD Pipeline**
   - Set up GitHub Actions or similar
   - Run tests on every commit
   - Automate build process
   - Deploy to staging on merge to main

**Success Criteria:**
- 70%+ test coverage
- All critical flows have integration tests
- CI/CD pipeline running
- Tests pass on every commit

---

## Phase 5: Enhanced Features (Priority: Medium)

**Goal:** Add value-add features for better UX

### Plans

1. **Push Notifications**
   - Implement Firebase Cloud Messaging
   - Configure notification permissions
   - Send offer alerts
   - Send redemption confirmations

2. **Analytics & Crash Reporting**
   - Implement Firebase Analytics
   - Implement Firebase Crashlytics
   - Track key user events
   - Monitor crash rates

3. **App Update Mechanism**
   - Complete OTA update implementation
   - Add update prompts
   - Test update flow
   - Handle update errors gracefully

4. **Deep Linking**
   - Implement shareable offer links
   - Handle deep link routing
   - Test on all platforms
   - Add analytics for deep links

**Success Criteria:**
- Users receive relevant notifications
- Analytics track key events
- App updates automatically
- Deep links work correctly

---

## Phase 6: Security Hardening (Priority: Medium)

**Goal:** Improve security posture

### Plans

1. **Certificate Pinning**
   - Implement SSL certificate pinning
   - Add pinning to Dio configuration
   - Handle pinning failures
   - Update pins periodically

2. **API Security**
   - Add API key encryption
   - Implement request signing (if needed)
   - Add rate limiting handling
   - Secure sensitive data in logs

3. **Code Obfuscation**
   - Configure ProGuard/R8 for Android
   - Configure code obfuscation for iOS
   - Test obfuscated builds
   - Ensure crash reports still work

**Success Criteria:**
- Certificate pinning active
- API calls are secure
- Code is obfuscated in production
- No sensitive data in logs

---

## Phase 7: Performance Optimization (Priority: Low)

**Goal:** Optimize app performance

### Plans

1. **Build Time Optimization**
   - Review code generation dependencies
   - Implement selective generation
   - Cache build artifacts
   - Optimize asset bundling

2. **Runtime Performance**
   - Profile app performance
   - Optimize image loading
   - Reduce memory usage
   - Optimize list scrolling

3. **App Size Optimization**
   - Remove unused dependencies
   - Optimize assets
   - Enable app thinning
   - Review bundle size

**Success Criteria:**
- Build time reduced by 30%
- App launch time < 3 seconds
- App size reduced by 20%
- Smooth scrolling on all lists

---

## Phase 8: Polish & Launch (Priority: High)

**Goal:** Prepare for production launch

### Plans

1. **Final Testing**
   - Comprehensive QA testing
   - Beta testing with real users
   - Fix critical bugs
   - Performance testing

2. **Store Preparation**
   - Prepare app store screenshots
   - Write app descriptions
   - Create privacy policy
   - Set up store listings

3. **Launch**
   - Deploy to production
   - Monitor crash rates
   - Monitor performance
   - Address immediate issues

**Success Criteria:**
- No critical bugs
- App approved by stores
- Crash rate < 1%
- Performance metrics met

---

## Milestone Tracking

- [ ] Phase 1: Foundation & Security
- [ ] Phase 2: Core Feature Completion
- [ ] Phase 3: Offline Support
- [ ] Phase 4: Testing & Quality
- [ ] Phase 5: Enhanced Features
- [ ] Phase 6: Security Hardening
- [ ] Phase 7: Performance Optimization
- [ ] Phase 8: Polish & Launch

---
*Last updated: 2026-10-07*
