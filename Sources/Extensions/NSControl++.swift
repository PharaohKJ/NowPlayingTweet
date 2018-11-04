/**
 *  NSControl++.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa

extension NSControl {

    func enable() {
        self.isEnabled = true
    }

    func disable() {
        self.isEnabled = false
    }

}

extension NSControl.StateValue {
    
    func toBool() -> Bool {
        if self == .off {
            return false
        }
        
        // Is state on/mixed
        return true
    }
    
}
