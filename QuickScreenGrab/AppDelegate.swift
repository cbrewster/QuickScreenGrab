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
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        screenGrabManager = ScreenGrabManager()
    }
}

