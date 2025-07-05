import SwiftUI
import AppKit
import UserNotifications

@main
struct ClaudeRadarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var themeManager = ThemeManager()
    
    var body: some Scene {
        Settings {
            SettingsView()
                .environmentObject(themeManager)
        }
        
        // Debug window commented out for production
        // WindowGroup("ClaudeRadar Debug") {
        //     DebugView()
        //         .environmentObject(UsageDataManager.shared)
        //         .environmentObject(themeManager)
        //         .frame(width: 400, height: 500)
        // }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem?
    var popover: NSPopover?
    var eventMonitor: EventMonitor?
    var themeManager: ThemeManager?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("🚀 ClaudeRadar: App did finish launching")
        
        setupMenuBar()
        setupEventMonitor()
        
        // Listen for manual menu bar setup
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(setupMenuBar),
            name: .setupMenuBar,
            object: nil
        )
        
        // Note: Notifications will be added in a future update
        
        print("✅ ClaudeRadar: Setup completed")
    }
    
    @objc private func setupMenuBar() {
        print("🔧 Setting up menu bar item...")
        
        // Initialize theme manager if not already done
        if themeManager == nil {
            themeManager = ThemeManager()
        }
        
        // Remove existing status bar item if present
        if let existingItem = statusBarItem {
            NSStatusBar.system.removeStatusItem(existingItem)
        }
        
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusBarItem?.button {
            // Try different system symbols
            if let image = NSImage(systemSymbolName: "gauge.high", accessibilityDescription: "Claude Radar") {
                button.image = image
                print("✅ Menu bar icon set: gauge.high")
            } else if let image = NSImage(systemSymbolName: "gauge", accessibilityDescription: "Claude Radar") {
                button.image = image
                print("✅ Menu bar icon set: gauge")
            } else {
                // Fallback to text if no icons work
                button.title = "CR"
                print("⚠️ Using text fallback: CR")
            }
            
            button.action = #selector(togglePopover)
            button.target = self
            print("✅ Menu bar button configured")
        } else {
            print("❌ Failed to get menu bar button")
        }
        
        popover = NSPopover()
        popover?.contentSize = NSSize(width: DesignTokens.Layout.menuBarWidth, height: DesignTokens.Layout.menuBarHeight)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(
            rootView: MenuBarView()
                .environmentObject(UsageDataManager.shared)
                .environmentObject(themeManager!)
        )
        
        print("✅ Menu bar setup completed")
    }
    
    private func setupEventMonitor() {
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let popover = self?.popover, popover.isShown {
                self?.closePopover(sender: event)
            }
        }
    }
    
    @objc func togglePopover() {
        if let popover = popover {
            if popover.isShown {
                closePopover(sender: nil)
            } else {
                showPopover()
            }
        }
    }
    
    private func showPopover() {
        if let button = statusBarItem?.button, let popover = popover {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            eventMonitor?.start()
        }
    }
    
    private func closePopover(sender: AnyObject?) {
        popover?.performClose(sender)
        eventMonitor?.stop()
    }
}