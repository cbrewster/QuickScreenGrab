//
//  AppDelegate.swift
//  QuickScreenGrab
//
//  Created by connor on 8/11/15.
//  Copyright © 2015 Double Bit Studios. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var screenGrabManager: ScreenGrabManager?
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        screenGrabManager = ScreenGrabManager()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}

