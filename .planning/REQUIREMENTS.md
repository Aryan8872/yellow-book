# Requirements

**Last updated:** 2026-10-07

## User Stories

### Authentication

- As a customer, I want to register with email and password so that I can access the app
- As a customer, I want to log in with my credentials so that I can access my account
- As a customer, I want to log in with Google OAuth so that I can quickly access the app
- As a customer, I want my session to persist so that I don't have to log in repeatedly
- As a customer, I want to log out so that I can secure my account

### Offer Discovery

- As a customer, I want to see featured offers on the home screen so that I can discover popular deals
- As a customer, I want to browse offers by category so that I can find relevant deals
- As a customer, I want to search for offers by name or keyword so that I can find specific deals
- As a customer, I want to see offers near my location so that I can find convenient deals
- As a customer, I want to view offer details so that I can understand the deal terms

### Offer Redemption

- As a customer, I want to generate a redemption code so that I can redeem an offer at a merchant
- As a customer, I want to see my redemption history so that I can track my savings
- As a customer, I want to know when an offer expires so that I don't miss out

### User Profile

- As a customer, I want to view my profile so that I can see my account information
- As a customer, I want to edit my profile so that I can keep my information up to date
- As a customer, I want to see my subscription status so that I know my access level

### Offline Experience

- As a customer, I want to view cached offers when offline so that I can still browse deals
- As a customer, I want the app to sync when I come back online so that I have the latest data

## Acceptance Criteria

### Authentication

- [ ] User can register with email and password
- [ ] User can log in with email and password
- [ ] User can log in with Google OAuth
- [ ] JWT access token is stored securely
- [ ] JWT refresh token is stored securely
- [ ] Token refresh happens automatically on 401 errors
- [ ] User is logged out on token refresh failure
- [ ] User can log out manually
- [ ] Session persists across app restarts

### Offer Discovery

- [ ] Home screen displays featured offers
- [ ] Home screen displays trending offers
- [ ] Categories are displayed and filterable
- [ ] Search returns relevant offers
- [ ] Map shows offers near user location
- [ ] Offer details display all relevant information
- [ ] Images are cached to prevent re-downloads
- [ ] Loading states are shown during data fetch
- [ ] Error messages are user-friendly

### Offer Redemption

- [ ] User can generate redemption code for an offer
- [ ] Redemption code is unique and time-limited
- [ ] Redemption history is displayed
- [ ] Offer expiration is clearly shown
- [ ] Max redemption limit is enforced

### User Profile

- [ ] User profile displays account information
- [ ] User can edit profile fields
- [ ] Subscription status is displayed
- [ ] Profile changes are persisted

### Offline Experience

- [ ] Offers are cached locally
- [ ] Cached offers are viewable offline
- [ ] Data syncs when connection restored
- [ ] Sync status is visible to user

## Functional Requirements

### F1: Authentication

- **F1.1:** Support email/password registration
- **F1.2:** Support email/password login
- **F1.3:** Support Google OAuth login
- **F1.4:** Implement JWT token storage (secure)
- **F1.5:** Implement automatic token refresh
- **F1.6:** Implement logout functionality

### F2: Offer Discovery

- **F2.1:** Display home feed with featured/trending offers
- **F2.2:** Display category list with filtering
- **F2.3:** Implement search functionality
- **F2.4:** Display map with offer locations
- **F2.5:** Display offer details screen
- **F2.6:** Implement image caching

### F3: Offer Redemption

- **F3.1:** Generate redemption codes
- **F3.2:** Display redemption history
- **F3.3:** Show offer expiration dates
- **F3.4:** Enforce redemption limits

### F4: User Profile

- **F4.1:** Display user profile
- **F4.2:** Allow profile editing
- **F4.3:** Display subscription status

### F5: Offline Support

- **F5.1:** Cache offers locally
- **F5.2:** Display cached data offline
- **F5.3:** Sync data when online

## Non-Functional Requirements

### Performance

- **NFR1:** App launch time < 3 seconds
- **NFR2:** Screen transitions < 500ms
- **NFR3:** API response time < 2 seconds
- **NFR4:** Image loading < 1 second (cached)

### Security

- **NFR5:** Tokens stored securely (flutter_secure_storage)
- **NFR6:** SSL certificate pinning for API calls
- **NFR7:** No sensitive data in logs
- **NFR8:** Environment-based configuration

### Usability

- **NFR9:** Intuitive navigation (go_router)
- **NFR10:** Clear error messages
- **NFR11:** Loading indicators for all async operations
- **NFR12:** Consistent design language

### Reliability

- **NFR13:** App handles network failures gracefully
- **NFR14:** App handles API errors gracefully
- **NFR15:** Token refresh doesn't cause data loss
- **NFR16:** Offline mode doesn't crash app

### Maintainability

- **NFR17:** Test coverage > 70%
- **NFR18:** Code follows Clean Architecture
- **NFR19:** Documentation for complex logic
- **NFR20:** CI/CD pipeline for automated testing

## Technical Requirements

### TR1: Architecture

- Clean Architecture with separation of concerns
- BLoC pattern for state management
- Dependency injection with get_it

### TR2: Networking

- Dio HTTP client with interceptors
- Automatic token refresh
- Request timeout handling
- Error handling strategy

### TR3: Storage

- Secure token storage (flutter_secure_storage)
- Local database for offline caching (Floor ORM)
- Image caching (cached_network_image)

### TR4: Navigation

- go_router for declarative routing
- Deep linking support
- Route guards for authentication

### TR5: Testing

- Unit tests for business logic
- Widget tests for UI components
- Integration tests for critical flows
- Test coverage reporting

## Out of Scope

- Merchant-specific features (separate merchant web app)
- Admin features (separate admin panel)
- Social media sharing
- Payment processing (handled by merchants)
- Advanced map features beyond basic display
- Real-time chat or messaging
- Video streaming

## Definition of Done

A feature is complete when:

- [ ] All acceptance criteria are met
- [ ] Unit tests written and passing
- [ ] Widget tests written and passing
- [ ] Integration tests written and passing (for critical flows)
- [ ] Code reviewed
- [ ] Documentation updated
- [ ] No critical bugs
- [ ] Performance requirements met
- [ ] Security requirements met
- [ ] Deployed to staging environment

---
*Last updated: 2026-10-07*
