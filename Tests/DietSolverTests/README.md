# Test Suite Overview

This directory contains comprehensive tests for the Diet Solver application.

## Test Files

### Core Test Suites

1. **UnitTests.swift** - Unit tests for core business logic
   - DietSolver functionality
   - ViewModel state management
   - Medical analyzer
   - Exercise planner

2. **RegressionTests.swift** - Regression tests for critical flows
   - Complete user workflows
   - Data persistence
   - Multiple operations
   - Edge cases

3. **BlackBoxTests.swift** - Black box tests for UI interactions
   - Button actions
   - Input validation
   - Output structure
   - System behavior

4. **UXTests.swift** - UX and performance tests
   - Performance metrics
   - Usability validation
   - Accessibility checks
   - Consistency tests

5. **ABTesting.swift** - A-B testing infrastructure
   - Variant assignment
   - Test configurations
   - Allocation distribution

### Integration Tests

6. **HearingIntegrationTests.swift** - Hearing feature integration tests
7. **HearingIntegrationSwiftTestingTests.swift** - Swift Testing framework tests
8. **TactileTongueIntegrationTests.swift** - Tactile and tongue feature tests

## Running Tests

```bash
# Run all tests
swift test

# Run specific test suite
swift test --filter UnitTests
swift test --filter RegressionTests

# Run with code coverage
swift test --enable-code-coverage
```

## Test Coverage

- ✅ Unit Tests: Core business logic
- ✅ Regression Tests: Critical user flows
- ✅ Black Box Tests: UI interactions
- ✅ UX Tests: Performance and usability
- ✅ A-B Tests: Experimental features
- ✅ Integration Tests: Feature integration

## Best Practices

1. Each test should be independent
2. Use descriptive test names
3. Include setup and teardown
4. Test both success and failure cases
5. Use expectations for async operations
6. Measure performance where applicable
