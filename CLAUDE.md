# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ClaudeRadar is a native macOS menu bar application built with SwiftUI that provides real-time monitoring of Claude AI token usage. The app reads usage data from Claude's local JSONL files and displays token consumption, burn rates, and session limits in a beautiful, accessible interface.

## Architecture

### Core Architecture Pattern
The app follows a modern SwiftUI architecture with clear separation of concerns:

- **Menu Bar Integration**: Native macOS menu bar app using `NSStatusItem` with `NSPopover`
- **Data Layer**: Dedicated data loading and session calculation services
- **UI Layer**: SwiftUI views with comprehensive theme and accessibility systems
- **State Management**: Combine-based reactive state with `@ObservableObject` and `@Published` properties

### Key Components

#### App Structure
- **`ClaudeRadarApp.swift`**: Main app entry point with `AppDelegate` managing menu bar lifecycle
- **`MenuBarView.swift`**: Primary UI displayed in the menu bar popover
- **`SettingsView.swift`**: Configuration interface for user preferences
- **`DebugView.swift`**: Development/debugging interface (disable for production)

#### Data Management
- **`UsageDataManager.swift`**: Central state manager coordinating data loading and UI updates
- **`ClaudeDataLoader.swift`**: Service for parsing Claude's JSONL usage files with deduplication
- **`SessionCalculator.swift`**: Business logic for calculating 5-hour session windows and burn rates

#### Design System
- **`DesignSystem.swift`**: Centralized design tokens and component styles
- **`ThemeSystem.swift`**: Theme management with dark/light mode support
- **`AccessibilitySystem.swift`**: Comprehensive accessibility features including VoiceOver support

## Common Development Commands

### Building and Running
```bash
# Build the project
swift build

# Run the app (appears in menu bar)
swift run ClaudeRadar

# Quick development launch with built-in setup
./launch.sh

# Full test and demo launch
./test-and-launch.sh
```

### Testing
```bash
# Run all tests
swift test

# Run specific test categories
swift test --filter AccessibilityTests
swift test --filter SessionCalculatorTests
swift test --filter ModelTrackingTests

# Run tests with verbose output
swift test --verbose
```

### Code Quality
The project uses Swift's built-in tools and follows Apple's Swift coding conventions:
```bash
# Build with warnings treated as errors
swift build -Xswiftc -warnings-as-errors

# Check for common issues
swift build --enable-test-discovery
```

## Key Architectural Decisions

### Session Management
- Claude uses 5-hour rolling windows for token limits
- Multiple sessions can be active simultaneously
- Session calculation logic handles overlapping time windows and multi-session burn rates
- Token plans: Pro (~7K), Max5 (~35K), Max20 (~140K), with auto-detection

### Data Processing Pipeline
1. **Path Discovery**: Auto-detects Claude data in `~/.claude/projects` and `~/.config/claude/projects`
2. **JSONL Parsing**: Recursive file discovery with deduplication based on message+request ID pairs
3. **Session Calculation**: Groups usage into 5-hour windows with burn rate analysis
4. **Real-time Updates**: 3-second refresh cycle with Combine publishers

### UI/UX Patterns
- **Menu Bar First**: Primary interface is the menu bar popover, not a traditional window
- **Accessibility**: Full VoiceOver support, high contrast modes, and keyboard navigation
- **Responsive Design**: Adapts to different screen sizes and Dynamic Type settings
- **Performance**: Efficient SwiftUI rendering with proper state management

## Testing Strategy

### Test Categories
- **Unit Tests**: Core business logic (SessionCalculator, data parsing)
- **UI Tests**: Component rendering and layout behavior
- **Accessibility Tests**: VoiceOver labels, keyboard navigation, color contrast
- **Integration Tests**: End-to-end data flow from file parsing to UI display

### Notable Test Files
- `SessionCalculatorTests.swift`: Session window calculation logic
- `AccessibilityIntegrationTests.swift`: Full accessibility workflow testing
- `MultiSessionBurnRateTests.swift`: Complex burn rate calculations
- `ModelTrackingTests.swift`: Model usage breakdown and detection

## Development Environment

### Requirements
- macOS 14.0+ (Sonnet 4 targets)
- Swift 5.9+
- No external dependencies (uses only system frameworks)

### Key Frameworks
- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming for state management
- **AppKit**: Menu bar integration and native macOS features
- **OSLog**: Performance monitoring and debugging

### Development Scripts
- `launch.sh`: Development launcher with build validation and data directory checks
- `test-and-launch.sh`: Comprehensive testing and demo setup with sample data generation
- `test-window.sh`: Window-based testing (debug mode)

## Configuration and Customization

### User Preferences (stored in UserDefaults)
- `tokenPlan`: Token plan selection (pro/max5/max20/custom_max)
- `refreshInterval`: Update frequency (1-10 seconds)
- `claudeDataPath`: Custom Claude data directory path
- `notificationThreshold`: Usage warning threshold
- `showNotifications`: Enable/disable notifications

### Theme System
- Supports system Dark/Light mode
- High contrast accessibility adjustments
- Semantic color tokens for consistent theming
- Dynamic Type scaling for font sizes

## Performance Considerations

### Memory Management
- Uses `@StateObject` and `@ObservableObject` for proper SwiftUI lifecycle management
- Implements deduplication to prevent processing duplicate JSONL entries
- Efficient file parsing with size limits (100MB max per file)

### Background Processing
- Data loading happens on background queues
- UI updates are dispatched to main queue via `@MainActor`
- Timer-based refresh system with proper cleanup

## Debugging and Monitoring

### Logging
- OSLog performance signposts for data loading operations
- Debug prints throughout the data pipeline
- Console.app integration for system-level debugging

### Common Issues
- **No menu bar icon**: Check AppDelegate setup and system permissions
- **No data displayed**: Verify Claude data directory paths and file permissions
- **Performance issues**: Monitor OSLog signposts and memory usage
- **UI not updating**: Check Combine publisher chains and main thread dispatch

## Future Development Notes

### Planned Features
- Historical usage charts and analytics
- Keyboard shortcuts and Touch Bar support
- Usage predictions with ML
- Team usage tracking capabilities

### Architecture Considerations
- The codebase is structured to easily add new data sources
- UI components are designed for extensibility
- Theme system supports custom color schemes
- Accessibility system is comprehensive and reusable