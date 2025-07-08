# Development Tasks

## Completed Features

### Core Architecture ✅
- Menu bar integration with native macOS design
- Real-time data loading from Claude JSONL files
- Session calculation with 5-hour window logic
- Cross-session aggregation for accurate usage tracking
- Model-specific tracking (Opus, Sonnet, Haiku)

### UI Implementation ✅
- SwiftUI-based interface with theme system
- Progress bars with model-specific colors
- Header with status indicators
- Footer with live connection status
- Accessibility support with VoiceOver labels

### Data Management ✅
- JSONL parsing with deduplication
- Token plan detection (Pro, Max5, Max20)
- Burn rate calculation across sessions
- Error handling and edge cases

## Recent Bug Fixes ✅
- Fixed cross-session aggregation display
- Removed keyboard focus highlight from model progress bars
- Updated token limits to match Claude's current plans
- Improved session window calculations

## Active Development
- Documentation cleanup for public repository
- Performance optimizations
- Enhanced accessibility features

## Testing Coverage
- Unit tests for session calculation logic
- Component tests for UI elements
- Integration tests for data flow
- Accessibility tests for VoiceOver support