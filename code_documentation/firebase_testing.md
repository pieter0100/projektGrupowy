# Firebase Testing Guide

## Test Setup

### Prerequisites
```bash
npm install
```

### Files
- `test/firestore.rules.test.js` - Security rules test suite
- `scripts/validate-privacy-implementation.js` - Rules validation script

## Running Tests

### 1. Validation Script (Quick Check)
```bash
npm run validate:privacy
```
Validates security rules syntax and requirements without emulator.

### 2. Emulator Tests (Full Test Suite)
```bash
# Terminal 1: Start emulator
npm run emulator:start

# Terminal 2: Run tests
npm run test:rules
```

## Test Coverage

### User Data Privacy Tests
- Users can access only their own data
- Cross-user access blocked
- Authentication enforcement

### Immutable Results Tests
- Results cannot be updated after creation
- Results cannot be deleted
- Owner validation on creation

### Public Data Tests  
- Levels accessible without authentication
- Leaderboards accessible without authentication
- Write access denied for all users

### Authentication Tests
- Unauthenticated access properly blocked
- Authenticated access granted where appropriate
- UID validation enforced

## Troubleshooting

### Common Issues
1. **Emulator connection failed**: Check if emulator is running on port 8080
2. **Permission denied errors**: Verify collection names match between rules and code
3. **Test timeout**: Increase `testTimeout` in package.json jest config

### Validation Script Checks
- 11 total validation checks
- All must pass for complete implementation
- Clear PASS/FAIL indicators for each requirement
