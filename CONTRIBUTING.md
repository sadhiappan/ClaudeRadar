# Contributing to ClaudeRadar

Thank you for your interest in contributing to ClaudeRadar! This document provides guidelines and information for contributors.

## 🎯 Project Vision

ClaudeRadar aims to be the **best native macOS app for Claude AI token monitoring**. We prioritize:

- **Native macOS experience** over cross-platform compatibility
- **Simplicity and elegance** over feature bloat
- **Privacy and security** over convenience
- **Performance** over quick implementations

## 🚀 Getting Started

### Prerequisites

- macOS 14.0+ (Sonoma) or later
- Xcode 15.0 or later
- Swift 5.9 or later
- Git

### Development Setup

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/yourusername/ClaudeRadar.git
   cd ClaudeRadar
   ```
3. **Create a feature branch**:
   ```bash
   git checkout -b feature/amazing-new-feature
   ```
4. **Build and run**:
   ```bash
   swift build
   swift run ClaudeRadar
   ```

### Project Structure

```
ClaudeRadar/
├── Sources/
│   ├── ClaudeRadarApp.swift      # Main app entry point
│   ├── Views/                    # SwiftUI views
│   │   ├── MenuBarView.swift
│   │   ├── SettingsView.swift
│   │   └── CircularProgressView.swift
│   ├── Models/                   # Data models
│   │   └── DataModels.swift
│   ├── Core/                     # Business logic
│   │   ├── UsageDataManager.swift
│   │   ├── ClaudeDataLoader.swift
│   │   └── SessionCalculator.swift
│   └── Utilities/                # Helper classes
│       └── EventMonitor.swift
├── Tests/                        # Unit tests
├── Assets/                       # Images, icons, etc.
├── Package.swift                 # Swift Package Manager config
└── README.md
```

## 📝 Coding Standards

### Swift Style Guide

We follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/) and [Ray Wenderlich Style Guide](https://github.com/raywenderlich/swift-style-guide).

**Key principles:**
- Use clear, descriptive names
- Prefer value types over reference types
- Use extensions to organize code
- Add documentation comments for public APIs

### Code Organization

- **One class per file** unless tightly coupled
- **Group related functionality** in extensions
- **Use MARK comments** to organize code sections
- **Keep functions small** and focused

### Example Code Style

```swift
// MARK: - Public Methods

func calculateUsageStatistics(from sessions: [ClaudeSession]) -> UsageStatistics {
    guard !sessions.isEmpty else { return .empty }
    
    let totalTokens = sessions.reduce(0) { $0 + $1.tokenCount }
    let averageTokens = totalTokens / sessions.count
    
    return UsageStatistics(
        totalSessions: sessions.count,
        totalTokensUsed: totalTokens,
        averageTokensPerSession: averageTokens
    )
}

// MARK: - Private Methods

private func formatTokenCount(_ count: Int) -> String {
    return NumberFormatter.localizedString(from: NSNumber(value: count), number: .decimal)
}
```

## 🎨 UI/UX Guidelines

### Design Principles

- **Follow Apple's Human Interface Guidelines**
- **Use system colors and fonts** when possible
- **Respect user preferences** (Dark Mode, accessibility settings)
- **Keep interfaces minimal** and focused
- **Provide immediate feedback** for user actions

### SwiftUI Best Practices

- **Use @StateObject for owned objects**
- **Use @ObservedObject for injected objects**
- **Extract subviews** when body gets complex
- **Use meaningful view names**
- **Implement proper accessibility** labels and hints

## 🧪 Testing

### Unit Tests

- Write tests for **business logic** in Core/ directory
- Use **XCTest framework**
- Aim for **high coverage** of critical paths
- **Mock external dependencies**

### Running Tests

```bash
swift test
```

### Test Organization

```swift
import XCTest
@testable import ClaudeRadar

final class SessionCalculatorTests: XCTestCase {
    var calculator: SessionCalculator!
    
    override func setUp() {
        super.setUp()
        calculator = SessionCalculator()
    }
    
    func testCalculateSessionsWithValidEntries() {
        // Given
        let entries = createMockEntries()
        
        // When
        let sessions = calculator.calculateSessions(from: entries, plan: .pro)
        
        // Then
        XCTAssertEqual(sessions.count, 1)
        XCTAssertEqual(sessions.first?.tokenCount, 1500)
    }
}
```

## 📦 Pull Request Process

### Before Submitting

1. **Run tests** and ensure they pass
2. **Update documentation** if needed
3. **Test on multiple macOS versions** if possible
4. **Check code formatting** with SwiftFormat
5. **Verify app builds and runs** correctly

### PR Description Template

```markdown
## Description
Brief description of changes made.

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Manual testing completed
- [ ] Tested on multiple macOS versions

## Screenshots
If applicable, add screenshots to help explain your changes.

## Checklist
- [ ] Code follows the project's style guidelines
- [ ] Self-review of code completed
- [ ] Code is commented, particularly in hard-to-understand areas
- [ ] Corresponding changes to documentation made
```

### Review Process

1. **Automated checks** must pass (builds, tests, linting)
2. **Code review** by at least one maintainer
3. **Testing** on different macOS versions
4. **Documentation** review if applicable
5. **Merge** when approved

## 🐛 Reporting Issues

### Bug Reports

Use the **Bug Report** template with:
- **Clear description** of the problem
- **Steps to reproduce** the issue
- **Expected vs actual behavior**
- **Environment details** (macOS version, app version)
- **Screenshots** if applicable

### Feature Requests

Use the **Feature Request** template with:
- **Problem statement** - what problem does this solve?
- **Proposed solution** - how should it work?
- **Alternatives considered** - what other approaches did you consider?
- **Additional context** - mockups, examples, etc.

## 🎁 Recognition

Contributors will be recognized in:
- **README.md** contributors section
- **GitHub contributors** page
- **Release notes** for significant contributions
- **Special mentions** in project updates

## 📜 Code of Conduct

### Our Pledge

We pledge to make participation in our project a harassment-free experience for everyone, regardless of age, body size, disability, ethnicity, gender identity and expression, level of experience, nationality, personal appearance, race, religion, or sexual identity and orientation.

### Our Standards

**Positive behavior includes:**
- Using welcoming and inclusive language
- Being respectful of differing viewpoints
- Gracefully accepting constructive criticism
- Focusing on what is best for the community
- Showing empathy towards other community members

**Unacceptable behavior includes:**
- Trolling, insulting/derogatory comments, and personal or political attacks
- Public or private harassment
- Publishing others' private information without explicit permission
- Other conduct which could reasonably be considered inappropriate

### Enforcement

Instances of abusive, harassing, or otherwise unacceptable behavior may be reported by contacting the project team. All complaints will be reviewed and investigated promptly and fairly.

## 🔄 Development Workflow

### Branching Strategy

- **main** - production-ready code
- **develop** - integration branch for features
- **feature/** - feature development branches
- **hotfix/** - urgent bug fixes

### Commit Messages

Use conventional commits format:
```
type(scope): description

Examples:
feat(ui): add usage analytics chart
fix(core): resolve session calculation bug
docs(readme): update installation instructions
```

### Release Process

1. **Feature freeze** on develop branch
2. **Create release branch** from develop
3. **Testing and bug fixes** on release branch
4. **Merge to main** and tag release
5. **Deploy** to GitHub Releases

## 🆘 Getting Help

- **GitHub Discussions** - for general questions and ideas
- **GitHub Issues** - for bug reports and feature requests
- **Twitter** - follow [@ClaudeRadar](https://twitter.com/ClaudeRadar) for updates
- **Email** - contact the maintainers directly

## 📚 Resources

- [Swift.org](https://swift.org/) - Swift language reference
- [Apple Developer Documentation](https://developer.apple.com/documentation/) - SwiftUI and AppKit docs
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/) - macOS design principles
- [Ray Wenderlich](https://www.raywenderlich.com/) - Swift and iOS/macOS tutorials

---

Thank you for contributing to ClaudeRadar! 🚀