# ClaudeRadar

**A native macOS menu bar app for monitoring Claude AI token usage**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![macOS](https://img.shields.io/badge/macOS-14.0+-blue.svg)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org/)

ClaudeRadar provides real-time monitoring of Claude AI token usage through a native macOS menu bar application. Built with SwiftUI, it offers live tracking of your Claude consumption across all models with session management and usage analytics.

## Features

- **Native macOS Experience** - Built with SwiftUI for optimal performance
- **Menu Bar Integration** - Accessible from your menu bar without taking up screen space
- **Real-time Monitoring** - Live updates with 3-second refresh intervals
- **Multi-Model Support** - Track usage across Opus, Sonnet, and Haiku models
- **Session Management** - Understand Claude's 5-hour session windows
- **Cross-Session Aggregation** - View total usage across multiple active sessions
- **Privacy Focused** - All data processing happens locally on your Mac

## Requirements

- macOS 14.0 (Sonoma) or later
- Swift 5.9+ (for building from source)
- Claude AI account with local data enabled

## Installation

### Build from Source

```bash
# Clone the repository
git clone https://github.com/shivadhiappan/ClaudeRadar.git
cd ClaudeRadar

# Build and run
swift build
swift run ClaudeRadar
```

### Development

```bash
# Quick development launch
./launch.sh

# Run tests
swift test

# Run with test data
./test-and-launch.sh
```

## How It Works

ClaudeRadar reads usage data from Claude's local JSONL files and provides:

- **Session Tracking**: Monitors Claude's 5-hour rolling session windows
- **Model Breakdown**: Shows usage across Opus, Sonnet, and Haiku models
- **Burn Rate Analysis**: Calculates token consumption rates
- **Real-time Updates**: Refreshes every 3 seconds for live monitoring
- **Cross-Session Aggregation**: Combines usage across multiple active sessions

### Supported Token Plans
- **Pro**: ~7,000 tokens per 5-hour session
- **Max 5**: ~35,000 tokens per 5-hour session  
- **Max 20**: ~140,000 tokens per 5-hour session
- **Auto-detect**: Automatically determines your plan based on usage patterns

## Architecture

ClaudeRadar follows modern SwiftUI patterns with clear separation of concerns:

- **Menu Bar Integration**: Native macOS menu bar app using `NSStatusItem`
- **Data Layer**: Dedicated services for data loading and session calculation
- **UI Layer**: SwiftUI views with comprehensive theme and accessibility systems
- **State Management**: Combine-based reactive state management

### Key Components
- `UsageDataManager`: Central state coordinator
- `ClaudeDataLoader`: JSONL file parsing with deduplication
- `SessionCalculator`: Business logic for session windows and burn rates
- `ThemeSystem`: Dark/light mode and accessibility support

## Configuration

ClaudeRadar automatically detects Claude data in standard locations:
- `~/.claude/projects`
- `~/.config/claude/projects`

Customize settings through the app's preferences:
- Token plan selection
- Refresh interval (1-10 seconds)
- Custom Claude data path
- Notification preferences

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

### Development Setup

```bash
# Clone the repository
git clone https://github.com/shivadhiappan/ClaudeRadar.git
cd ClaudeRadar

# Build and test
swift build
swift test
```

## License

MIT License. See [LICENSE](LICENSE) for details.

## Acknowledgments

- Claude AI for providing the excellent AI assistant
- Apple for SwiftUI and macOS development tools
- The Swift community for ongoing innovation