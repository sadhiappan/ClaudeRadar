# 🎯 ClaudeRadar

<div align="center">

![ClaudeRadar Icon](https://github.com/yourusername/ClaudeRadar/raw/main/Assets/icon-256.png)

**A beautiful, native macOS app for monitoring Claude AI token usage**

[![GitHub stars](https://img.shields.io/github/stars/yourusername/ClaudeRadar.svg)](https://github.com/yourusername/ClaudeRadar/stargazers)
[![GitHub release](https://img.shields.io/github/release/yourusername/ClaudeRadar.svg)](https://github.com/yourusername/ClaudeRadar/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![macOS](https://img.shields.io/badge/macOS-13.0+-blue.svg)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org/)

[Download Latest Release](https://github.com/yourusername/ClaudeRadar/releases/latest) • [View Screenshots](#screenshots) • [Report Bug](https://github.com/yourusername/ClaudeRadar/issues)

</div>

## ✨ Why ClaudeRadar?

**Stop guessing your Claude token usage.** ClaudeRadar is the first truly native macOS app designed specifically for Claude AI power users who need real-time visibility into their token consumption.

### 🎊 What Makes It Special

- **🔥 Native macOS Experience** - Built with SwiftUI, not Electron
- **⚡ Menu Bar Integration** - Always accessible, never intrusive  
- **📊 Real-time Monitoring** - Live updates every 3 seconds
- **🎨 Beautiful Design** - Follows Apple's Human Interface Guidelines
- **🧠 Smart Notifications** - Contextual alerts when you need them
- **📈 Usage Analytics** - Understand your Claude consumption patterns
- **🔒 Privacy First** - All data stays on your Mac

## 🎬 Screenshots

<div align="center">

### Menu Bar Interface
![Menu Bar](screenshots/menubar.png)

### Usage Analytics
![Analytics](screenshots/analytics.png)

### Settings Panel
![Settings](screenshots/settings.png)

</div>

## ⚡ Quick Start

### 📦 Install (Recommended)

1. **Download the latest release** from [GitHub Releases](https://github.com/yourusername/ClaudeRadar/releases/latest)
2. **Drag ClaudeRadar.app** to your Applications folder
3. **Launch the app** - it will appear in your menu bar
4. **Grant permissions** when prompted (to read Claude data)
5. **You're done!** 🎉

### 🛠️ Build from Source

```bash
# Clone the repository
git clone https://github.com/yourusername/ClaudeRadar.git
cd ClaudeRadar

# Build and run
swift build
swift run ClaudeRadar
```

**Requirements:**
- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later (for building from source)

## 🎯 Features

### 🔄 Real-time Monitoring
- **Live token counting** with 3-second refresh intervals
- **Session tracking** for Claude's 5-hour windows
- **Burn rate calculation** to predict usage patterns
- **Progress indicators** with beautiful color coding

### 📊 Smart Analytics
- **Usage history** with daily, weekly, and monthly views
- **Cost tracking** to monitor your Claude spending
- **Pattern detection** to understand your usage habits
- **Export capabilities** for external analysis

### 🔔 Intelligent Notifications
- **Usage warnings** when approaching limits (customizable thresholds)
- **Session expiry alerts** with countdown timers
- **Burn rate notifications** for high consumption periods
- **Silent mode** for focused work sessions

### ⚙️ Customization
- **Multiple token plans** (Pro, Max 5, Max 20, Auto-detect)
- **Custom data paths** for non-standard Claude installations
- **Refresh intervals** from 1-10 seconds
- **Notification preferences** with granular control

## 🎨 Design Philosophy

ClaudeRadar follows **Apple's Human Interface Guidelines** and embraces native macOS design patterns:

- **Menu bar first** - Accessible but not intrusive
- **System integration** - Respects Dark Mode, Focus modes, and accessibility
- **Minimal resource usage** - Efficient Swift code, no Electron bloat  
- **Privacy by design** - Zero telemetry, all data stays local

## 🔒 Privacy & Security

- **✅ No data collection** - ClaudeRadar never sends your data anywhere
- **✅ Local processing** - All analysis happens on your Mac
- **✅ Sandboxed** - Runs with minimal system permissions
- **✅ Open source** - Full transparency of what the app does

## 📈 Comparison

| Feature | ClaudeRadar | Terminal Tools | Browser Extensions |
|---------|-------------|----------------|-------------------|
| Native macOS UI | ✅ | ❌ | ❌ |
| Menu bar integration | ✅ | ❌ | ❌ |
| Real-time updates | ✅ | ✅ | ❌ |
| No dependencies | ✅ | ❌ | ✅ |
| Offline capable | ✅ | ✅ | ❌ |
| Beautiful design | ✅ | ❌ | ❌ |
| Privacy focused | ✅ | ✅ | ❌ |

## 🚀 Roadmap

### Phase 1: Foundation ✅
- [x] Menu bar app with live monitoring
- [x] Session tracking and burn rate calculation  
- [x] Basic notifications and settings
- [x] Data export functionality

### Phase 2: Advanced Features 🚧
- [ ] Historical usage charts and analytics
- [ ] Keyboard shortcuts and Touch Bar support
- [ ] Usage predictions with ML
- [ ] Dashboard widgets for macOS

### Phase 3: Pro Features 📋
- [ ] Team usage tracking
- [ ] Advanced cost optimization
- [ ] Plugin architecture
- [ ] Integration with time tracking apps

## 🤝 Contributing

ClaudeRadar is open source and welcomes contributions! Here's how you can help:

- **🐛 Report bugs** - Found something wrong? [Open an issue](https://github.com/yourusername/ClaudeRadar/issues)
- **💡 Suggest features** - Have ideas? [Start a discussion](https://github.com/yourusername/ClaudeRadar/discussions)
- **🔧 Submit PRs** - Ready to contribute code? Check our [Contributing Guide](CONTRIBUTING.md)
- **⭐ Star the repo** - Show your support and help others discover ClaudeRadar

### Development Setup

```bash
# Clone with submodules
git clone --recursive https://github.com/yourusername/ClaudeRadar.git

# Open in Xcode
open ClaudeRadar.xcodeproj

# Or build with Swift Package Manager
swift build
```

## 💝 Support

If ClaudeRadar saves you time and helps you be more productive with Claude:

- **⭐ Star this repository** to show your support
- **🐦 Share on Twitter** to help others discover it
- **☕ Buy me a coffee** via [GitHub Sponsors](https://github.com/sponsors/yourusername)

## 📝 License

ClaudeRadar is released under the [MIT License](LICENSE). Feel free to use, modify, and distribute as you see fit.

## 🙏 Acknowledgments

- **Claude AI** for creating an amazing AI assistant
- **Apple** for excellent developer tools and design guidelines
- **The Swift community** for continuous innovation
- **Beta testers** who helped shape ClaudeRadar

---

<div align="center">

**Made with ❤️ for the Claude community**

[⭐ Star](https://github.com/yourusername/ClaudeRadar) • [🐦 Tweet](https://twitter.com/intent/tweet?text=Check%20out%20ClaudeRadar%20-%20a%20beautiful%20macOS%20app%20for%20monitoring%20Claude%20AI%20token%20usage!%20https://github.com/yourusername/ClaudeRadar) • [📧 Email](mailto:your-email@example.com)

</div>