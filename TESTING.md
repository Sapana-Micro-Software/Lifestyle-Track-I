# Comprehensive Testing Documentation

This document describes the comprehensive testing strategy implemented for the Diet Solver application.

## Test Categories

### 1. Unit Tests (`UnitTests.swift`)
Tests individual components in isolation:
- **DietSolver**: Core optimization algorithm
- **DietSolverViewModel**: State management and business logic
- **MedicalAnalyzer**: Medical test analysis
- **ExercisePlanner**: Exercise plan generation

**Coverage:**
- Basic functionality
- Nutrient requirements
- Seasonal food availability
- Taste and digestion scores
- Health data management
- Exercise plan generation

### 2. Regression Tests (`RegressionTests.swift`)
Ensures existing functionality continues to work after changes:
- Complete user flows (health data → diet plan)
- Data persistence across operations
- Multiple plan generations
- Exercise plan regeneration
- Long-term plan generation for all durations
- Edge cases (empty collections, extreme values)

**Key Scenarios:**
- Health data update doesn't break existing plans
- Multiple diet plan generations don't cause crashes
- Unit system conversion preserves data

### 3. Black Box Tests (`BlackBoxTests.swift`)
Tests system behavior from user perspective without knowledge of internal implementation:
- Button action outputs
- Input validation (invalid, empty, extreme values)
- Output structure validation
- System behavior with missing data
- System behavior with extensive data

**Focus Areas:**
- UI interactions produce expected results
- Invalid inputs are handled gracefully
- Outputs have correct structure

### 4. UX Tests (`UXTests.swift`)
Validates user experience and performance:
- **Performance**: Plan generation speed, analysis speed
- **Usability**: Default values, error recovery, data persistence
- **Accessibility**: Data availability when needed
- **Consistency**: Same inputs produce consistent results

**Metrics:**
- Response times
- Error handling
- Data accessibility
- Result consistency

### 5. A-B Testing (`ABTesting.swift`)
Infrastructure for testing different variants:
- **ABTestManager**: Variant assignment and tracking
- **Test Configurations**: Different algorithm variants, UI layouts, recommendation styles
- **Allocation Distribution**: Ensures proper variant distribution

**Test Scenarios:**
- Diet plan algorithm variants
- UI button layout variants
- Recommendation style variants
- Plan generation speed variants
- User engagement variants

## Running Tests

### Run All Tests
```bash
swift test
```

### Run Specific Test Category
```bash
swift test --filter UnitTests
swift test --filter RegressionTests
swift test --filter BlackBoxTests
swift test --filter UXTests
swift test --filter ABTesting
```

### Run with Coverage
```bash
swift test --enable-code-coverage
```

## Test Coverage Goals

- **Unit Tests**: 80%+ coverage of core business logic
- **Regression Tests**: 100% coverage of critical user flows
- **Black Box Tests**: All user-facing features
- **UX Tests**: All performance-critical paths
- **A-B Tests**: All experimental features

## Continuous Integration

Tests should be run:
- Before every commit (pre-commit hook)
- On every pull request
- Before every release
- Nightly builds for extended test suites

## Test Data

Test data is generated programmatically to ensure:
- Consistency across test runs
- Easy modification for different scenarios
- No dependency on external data sources

## Best Practices

1. **Isolation**: Each test should be independent
2. **Naming**: Test names should clearly describe what they test
3. **Assertions**: Use specific assertions with clear failure messages
4. **Setup/Teardown**: Properly initialize and clean up test state
5. **Performance**: Use `measure` blocks for performance tests
6. **Async**: Use expectations for asynchronous operations

## Future Enhancements

- UI automation tests
- Integration tests with external services
- Load testing for performance
- Security testing
- Accessibility testing automation
