import SwiftUI
import AppKit
import UserNotifications

@main
struct ClaudeRadarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var themeManager = ThemeManager.shared
    
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
        
        // Use shared theme manager instance
        themeManager = ThemeManager.shared
        
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
                .environmentObject(ThemeManager.shared)
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
        if let button = statusBarItem?.button {
            print("🔍 ShowPopover called - current theme: \(ThemeManager.shared.effectiveTheme)")
            
            // Create a fresh popover each time
            let newPopover = NSPopover()
            newPopover.contentSize = NSSize(width: DesignTokens.Layout.menuBarWidth, height: DesignTokens.Layout.menuBarHeight)
            newPopover.behavior = .transient
            newPopover.appearance = NSAppearance(named: ThemeManager.shared.effectiveTheme == .dark ? .darkAqua : .aqua)
            
            // Remove any custom styling that might interfere
            newPopover.animates = true
            
            let rootView = MenuBarView()
                .environmentObject(UsageDataManager.shared)
                .environmentObject(ThemeManager.shared)
            
            newPopover.contentViewController = NSHostingController(rootView: rootView)
            
            // Replace the old popover
            popover = newPopover
            
            print("✅ New popover created with fresh content")
            
            popover?.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            eventMonitor?.start()
        }
    }
    
    private func closePopover(sender: AnyObject?) {
        popover?.performClose(sender)
        eventMonitor?.stop()
    }
}