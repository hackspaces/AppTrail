import AppKit
import SwiftUI
import Combine

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private let appTracker = AppTracker()
    private var cancellables = Set<AnyCancellable>()
    private var updateTimer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupPopover()
        bindAppTracker()
        startUpdateTimer()
    }

    func applicationWillTerminate(_ notification: Notification) {
        updateTimer?.invalidate()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "clock.arrow.circlepath", accessibilityDescription: "App Trail")
            button.imagePosition = .imageLeading
            button.title = ""
            button.action = #selector(togglePopover)
            button.target = self
        }
    }

    private func setupPopover() {
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 360, height: 420)
        popover?.behavior = .transient
        popover?.animates = true
        popover?.contentViewController = NSHostingController(
            rootView: MenuView(tracker: appTracker)
        )
    }

    private func bindAppTracker() {
        appTracker.$currentApp
            .receive(on: DispatchQueue.main)
            .sink { [weak self] appName in
                self?.updateStatusBarTitle(appName: appName)
            }
            .store(in: &cancellables)
    }

    private func updateStatusBarTitle(appName: String) {
        let maxLength = 12
        let displayName = appName.count > maxLength
            ? String(appName.prefix(maxLength - 1)) + "…"
            : appName
        statusItem?.button?.title = displayName
    }

    private func startUpdateTimer() {
        // Update current segment every second
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.appTracker.updateCurrentSegment()
        }
    }

    @objc private func togglePopover() {
        guard let button = statusItem?.button, let popover = popover else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
