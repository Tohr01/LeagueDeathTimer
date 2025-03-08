//
// LeagueDeathTimer.swift
// LeagueDeathTimer
//
// Created by Tohr01 on 03.11.24
// Copyright © 2024 Tohr01. All rights reserved.
//

import Cocoa
import LaunchAtLogin
import SwiftUI

var appDelegate = AppDelegate()

class AppDelegate: NSObject, NSApplicationDelegate {
    // Window containing DeathTimer view
    private var deathtimerwindow: NSWindow?

    // Status item displayed in top bar
    private var statusItem: NSStatusItem?

    static var leagueLocale: String = "en_GB"
    private var leagueAppPath: String?
    static var gameClientBundleID = "com.riotgames.LeagueofLegends.GameClient"
    static var leagueClientUxBundleID = "com.riotgames.LeagueofLegends.LeagueClientUx"

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        leagueAppPath = UserDefaults.standard.value(forKey: "leagueAppPath") as? String

        let leagueCustomPathPlaceholderText = "Override this with the path to your League of Legends app"
        let defaultLeagueAppPath = "/Applications/League of Legends.app"

        if leagueAppPath == nil {
            UserDefaults.standard.setValue(leagueCustomPathPlaceholderText, forKey: "leagueAppPath")
            leagueAppPath = defaultLeagueAppPath
        } else if let leagueAppPathStr = leagueAppPath, leagueAppPathStr == leagueCustomPathPlaceholderText {
            leagueAppPath = defaultLeagueAppPath
        }

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem?.button {
            button.image = NSImage(named: "menubaricon")
            let aspectRatio = button.image!.size.height / button.image!.size.width

            button.image?.size.height = 16
            button.image?.size.width = 16 / aspectRatio
        }
        let menu = NSMenu()

        let versionItem = NSMenuItem()
        versionItem.title = "Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "1.0")"
        versionItem.isEnabled = false
        menu.addItem(versionItem)

        menu.addItem(.separator())

        let launchAtLoginItem = NSMenuItem(title: "Launch at login", action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
        launchAtLoginItem.tag = 1
        launchAtLoginItem.state = LaunchAtLogin.isEnabled ? .on : .off
        menu.addItem(launchAtLoginItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "")
        menu.addItem(quitItem)

        statusItem?.menu = menu

        let notificationCenter = NSWorkspace.shared.notificationCenter
        // Add listener that fires when gameclient has been launched
        notificationCenter.addObserver(forName: NSWorkspace.didLaunchApplicationNotification, object: nil, queue: OperationQueue.main) { notification in
            if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
                if app.bundleIdentifier == AppDelegate.gameClientBundleID {
                    // League gameclient has been started
                    self.waitForGameClientReady()
                } else if app.bundleIdentifier == AppDelegate.leagueClientUxBundleID {
                    self.waitForLCUApi()
                }
            }
        }

        // Add listener that fires when gameclient has been terminated
        notificationCenter.addObserver(forName: NSWorkspace.didTerminateApplicationNotification, object: nil, queue: OperationQueue.main) { notification in
            if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication, app.bundleIdentifier == AppDelegate.gameClientBundleID {
                // League gameclient has been started
                self.closeMainWindow()
            }
        }
        if gameClientRunning() {
            waitForGameClientReady()
        }

        if leagueUxRunning() {
            waitForLCUApi()
        }
    }

    func waitForGameClientReady() {
        // Wait for api to return information
        Task {
            while await getActivePlayerRiotID() == nil {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
            DispatchQueue.main.sync {
                self.openMainWindow()
            }
        }
    }

    func waitForLCUApi() {
        // Wait for LCU api to become available
        Task {
            while true {
                if let lcuCreds = fetchLCUCredentials(mainAppPackagePath: URL(string: leagueAppPath!)!), let locale = await getClientLocale(lcuCreds: lcuCreds) {
                    AppDelegate.leagueLocale = locale
                    break
                }
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
        }
    }

    @objc private func toggleLaunchAtLogin() {
        if let launchAtLoginItem = statusItem?.menu?.item(withTag: 1) {
            LaunchAtLogin.isEnabled.toggle()
            launchAtLoginItem.state = LaunchAtLogin.isEnabled ? .on : .off
        }
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(self)
    }

    private func openMainWindow() {
        if deathtimerwindow != nil { return }
        let contentView = DeathTimer()

        deathtimerwindow = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 517, height: 138), styleMask: [], backing: .buffered, defer: false)
        deathtimerwindow?.backgroundColor = NSColor.clear
        deathtimerwindow?.isMovableByWindowBackground = true
        deathtimerwindow?.isReleasedWhenClosed = false
        deathtimerwindow?.center()
        deathtimerwindow?.setIsVisible(false)
        deathtimerwindow?.makeKeyAndOrderFront(nil)
        deathtimerwindow?.contentView = NSHostingView(rootView: contentView)
        deathtimerwindow?.level = NSWindow.Level.screenSaver
        if let winOriginX = UserDefaults.standard.value(forKey: "winOriginX") as? CGFloat, let winOriginY = UserDefaults.standard.value(forKey: "winOriginY") as? CGFloat {
            let frameOrigin = CGPoint(x: winOriginX, y: winOriginY)
            deathtimerwindow?.setFrameOrigin(frameOrigin)
        }
    }

    private func closeMainWindow() {
        if let deathtimerwindow = deathtimerwindow {
            let winOrigin = deathtimerwindow.frame.origin
            UserDefaults.standard.set(winOrigin.x, forKey: "winOriginX")
            UserDefaults.standard.set(winOrigin.y, forKey: "winOriginY")
        }

        deathtimerwindow?.close()
        deathtimerwindow = nil
    }
}

@main
enum LolDeathTimer {
    static func main() {
        NSApplication.shared.setActivationPolicy(.regular)
        NSApp.delegate = appDelegate
        NSApp.run()
    }
}
