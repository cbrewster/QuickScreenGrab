//
//  ScreenGrabManager.swift
//  QuickScreenGrab
//
//  Created by connor on 8/11/15.
//  Copyright © 2015 Double Bit Studios. All rights reserved.
//

import Cocoa
import Carbon
import MASShortcut

class ScreenGrabManager: NSObject, NSWindowDelegate {
    var statusBarButton: NSStatusItem?
    var panels = [NSPanel]()
    var menu: NSMenu?
    
    override init() {
        super.init()
        print("Init")
        
        let statusBar = NSStatusBar.system
        let crosshair = #imageLiteral(resourceName: "StatusIcon")
        crosshair.size = NSSize(width: 15, height: 15)
        
        menu = NSMenu()
        let item = NSMenuItem(title: "Quit", action: #selector(self.quit), keyEquivalent: "")
        item.target = self
        menu?.addItem(item)
        
        statusBarButton = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        statusBarButton?.image = crosshair
        statusBarButton?.highlightMode = true
        statusBarButton?.menu = menu
        
        registerHotkey()
    }
    
    @objc func quit() {
        NSApp.terminate(self)
    }
    
    func registerHotkey() {
        let shortcut = MASShortcut(keyCode: UInt(kVK_ANSI_5), modifierFlags: NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.shift.rawValue)
        MASShortcutMonitor.shared().register(shortcut, withAction: {
            self.takeScreenShot()
        })
    }
    
    func takeScreenShot() {
        guard let screengrab = NSImageFromScreen() else {
            return
        }
        
        let mouseLoc = NSEvent.mouseLocation
        
        let windowLoc = NSRect(x: mouseLoc.x - screengrab.size.width / 2.0, y: mouseLoc.y - screengrab.size.height - 10, width: screengrab.size.width, height: screengrab.size.height)
        let panel = NSPanel(contentRect: windowLoc, styleMask: [.hudWindow, .utilityWindow, .nonactivatingPanel, .closable, .titled], backing: .buffered, defer: false)
        panels.append(panel)
        let imageView = NSImageView(frame: NSRect(origin: CGPoint.zero, size: screengrab.size))
        imageView.image = screengrab
        panel.contentView?.addSubview(imageView)
        panel.delegate = self
        panel.makeKeyAndOrderFront(self)
    }
    
    func NSImageFromScreen() -> NSImage? {
        // Use built in screen capture tool to grab screenshot
        // Copies screenshot to clipboard
        let task = Process()
        task.arguments = ["-ic"]
        task.launchPath = "/usr/sbin/screencapture"
        task.launch()
        task.waitUntilExit()
        
        // If the screen capture was cancelled, the status code will be 1
        if (task.terminationStatus == 1) {
            return nil
        }
        
        // Grab screenshot from clipboard
        let imageFromClipboard = NSImage(pasteboard: NSPasteboard.general)
        
        return imageFromClipboard
    }
    
    func windowShouldClose(sender: AnyObject) -> Bool {
        let index = panels.index(of: sender as! NSPanel)
        if let index = index {
            let _ = panels.remove(at: index)
        }
        
        return true
    }
}
