# AGENTS.md

## Build/Test Commands
- `flutter test` - Run all tests
- `flutter test test/core/services/ai/services_test.dart` - Run single test file
- `flutter analyze` - Run static analysis/linting
- `dart format .` - Format all Dart files

## Code Style Guidelines

### Imports & Formatting
- Use relative imports (`prefer_relative_imports` rule enabled)
- Follow `flutter_lints` package rules
- Use `dart format` for code formatting

### Types & Naming
- Use strong typing with explicit types where beneficial
- Follow Dart naming conventions: `camelCase` for variables/functions, `PascalCase` for classes/types
- Use descriptive names; avoid abbreviations
- Model classes use `AIModel`, `AIRequest`, `AIResponse` pattern

### Architecture
- Feature-first structure: `lib/features/{feature}/presentation|viewmodel|widgets`
- Core services in `lib/core/services/` with base classes for extensibility
- Repository pattern for storage (`lib/core/storage/`)
- Dependency injection via `AppServices` singleton

### Error Handling
- Use proper exception handling with try-catch blocks
- Return nullable types where appropriate, use null-aware operators
- HTTP errors handled in service layer with proper status codes

### Testing
- Unit tests in `test/` mirroring `lib/` structure
- Use mock HTTP servers for API testing (see `services_test.dart`)
- Test both success and error scenarios