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
        
        let statusBar = NSStatusBar.systemStatusBar()
        let crosshair = NSImage(named: "StatusIcon")
        crosshair?.size = NSSize(width: 15, height: 15)
        
        menu = NSMenu()
        let item = NSMenuItem(title: "Quit", action: Selector("quit"), keyEquivalent: "")
        item.target = self
        menu?.addItem(item)
        
        statusBarButton = statusBar.statusItemWithLength(NSVariableStatusItemLength)
        statusBarButton?.image = crosshair
        statusBarButton?.highlightMode = true
        statusBarButton?.menu = menu
        
        registerHotkey()
    }
    
    func quit() {
        NSApp.terminate(self)
    }
    
    func registerHotkey() {
        
        let shortcut = MASShortcut(keyCode: UInt(kVK_ANSI_5), modifierFlags: NSEventModifierFlags.CommandKeyMask.rawValue | NSEventModifierFlags.ShiftKeyMask.rawValue)
        MASShortcutMonitor.sharedMonitor().registerShortcut(shortcut, withAction: {
            self.takeScreenShot()
        })
    }
    
    func takeScreenShot() {
        guard let screengrab = NSImageFromScreen() else {
            print("Failed to get screenshot")
            return
        }
        
        let mouseLoc = NSEvent.mouseLocation()
        
        let windowLoc = NSRect(x: mouseLoc.x - screengrab.size.width / 2.0, y: mouseLoc.y - screengrab.size.height - 10, width: screengrab.size.width, height: screengrab.size.height)
        
        let panel = NSPanel(contentRect: windowLoc, styleMask: NSHUDWindowMask | NSUtilityWindowMask | NSNonactivatingPanelMask | NSClosableWindowMask | NSTitledWindowMask, backing: NSBackingStoreType.Buffered, `defer`: false)
        
        panels.append(panel)
        let imageView = NSImageView(frame: NSRect(origin: CGPointZero, size: screengrab.size))
        imageView.image = screengrab
        panel.contentView.addSubview(imageView)
        panel.delegate = self
        panel.makeKeyAndOrderFront(self)
    }
    
    func NSImageFromScreen() -> NSImage? {
        // Use built in screen capture tool to grab screenshot
        // Copies screenshot to clipboard
        let task = NSTask()
        task.arguments = ["-ic"]
        task.launchPath = "/usr/sbin/screencapture"
        task.launch()
        task.waitUntilExit()
        
        // Grab screenshot from clipboard
        let imageFromClipboard = NSImage(pasteboard: NSPasteboard.generalPasteboard())
        
        return imageFromClipboard
    }
    
    func windowShouldClose(sender: AnyObject) -> Bool {
        let index = panels.indexOf(sender as! NSPanel)
        if let index = index {
            panels.removeAtIndex(index)
        }
        
        return true
    }
}