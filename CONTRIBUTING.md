# Contributing to SnackRadar

Thank you for your interest in contributing to SnackRadar! This document provides guidelines and instructions for contributing to the project.

## Development Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd snackradar
   ```

2. **Install Dependencies**
   - Ensure you have Xcode 14.0+ installed
   - Swift Package Manager will automatically fetch Firebase dependencies when you open the project

3. **Firebase Configuration**
   - Follow the instructions in `SnackRadar/Environment/README.md` to set up your Firebase project
   - Add your `GoogleService-Info.plist` to the `SnackRadar/Environment/` directory

4. **Open the Project**
   ```bash
   open SnackRadar.xcodeproj
   ```

## Project Structure

Please maintain the existing MVVM architecture:

```
SnackRadar/
├── App/           # Application lifecycle and global state
├── Models/        # Data models
├── ViewModels/    # Business logic and state management
├── Views/         # SwiftUI views
├── Services/      # External service integrations
├── Resources/     # Assets, colors, fonts
└── Environment/   # Configuration files
```

## Coding Guidelines

### Swift Style

- Use Swift naming conventions (camelCase for variables/functions, PascalCase for types)
- Prefer `let` over `var` whenever possible
- Use meaningful variable and function names
- Avoid force unwrapping (`!`) - prefer optional binding or nil coalescing
- Keep functions small and focused on a single responsibility

### SwiftUI Best Practices

- Extract complex views into separate components
- Use `@State` for view-local state
- Use `@StateObject` for view-owned ObservableObject instances
- Use `@ObservedObject` or `@EnvironmentObject` for shared state
- Prefer `@ViewBuilder` for view composition

### MVVM Pattern

- **Models**: Pure data structures, conform to `Codable` for Firebase
- **Views**: Presentation only, minimal logic
- **ViewModels**: Business logic, state management, service calls
- Keep ViewModels testable by avoiding UIKit dependencies

### Firebase Integration

- Use `FirebaseService.shared` for all Firebase operations
- Handle errors gracefully with user-friendly messages
- Update `AppState` for loading and error states
- Use async/await for Firebase operations when possible

### Design System

- Use colors from `AppColors` struct
- Use fonts from `AppFonts` struct
- Maintain consistency with the existing color palette
- Ensure proper contrast for accessibility

## Git Workflow

1. **Branch Naming**
   - Feature: `feat/feature-name`
   - Bug fix: `fix/bug-description`
   - Documentation: `docs/description`
   - Refactor: `refactor/description`

2. **Commit Messages**
   - Use descriptive commit messages
   - Format: `type: description`
   - Types: feat, fix, docs, style, refactor, test, chore
   - Example: `feat: add snack detail view`

3. **Pull Requests**
   - Create a PR against the main branch
   - Provide a clear description of changes
   - Reference any related issues
   - Ensure all tests pass
   - Request code review

## Testing

- Write unit tests for ViewModels
- Test business logic thoroughly
- Test Firebase service integrations with mocks
- Ensure UI components render correctly with previews

## Code Review

When reviewing code, consider:
- Code quality and readability
- Adherence to MVVM architecture
- Proper error handling
- Performance implications
- Accessibility
- Security considerations

## Questions?

If you have any questions or need clarification, feel free to:
- Open an issue for discussion
- Reach out to the maintainers
- Check existing documentation

Thank you for contributing to SnackRadar! 🎉
