/**
 *  AccountsViewController.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa
import SwifterMac

class AccountsViewController: NSViewController, NSTableViewDataSource {

    @IBOutlet weak var accountAvater: NSImageView!
    @IBOutlet weak var accountName: NSTextField!
    @IBOutlet weak var addButton: NSButton!
    @IBOutlet weak var removeButton: NSButton!

    let appDelegate = NSApplication.shared.delegate as! AppDelegate
    var twitterAccount: TwitterAccount?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do view setup here.

        self.twitterAccount = appDelegate.twitterAccount

        if (self.twitterAccount?.isLogin)! {
            self.addButton.disable()
            self.removeButton.enable()
            self.set(screenName: self.twitterAccount?.getScreenName())
            self.set(avater: self.twitterAccount?.getAvaterURL())
        }
    }

    @IBAction func addAccount(_ sender: NSButton) {
        self.twitterAccount?.login()
        self.addButton.disable()
        self.removeButton.enable()

        let notificationCenter: NotificationCenter = NotificationCenter.default
        var observer: NSObjectProtocol!
        observer = notificationCenter.addObserver(forName: .login, object: nil, queue: nil, using: { _ in
            self.set(screenName: self.twitterAccount?.getScreenName())
            self.set(avater: self.twitterAccount?.getAvaterURL())
            notificationCenter.removeObserver(observer)
        })
    }

    @IBAction func removeAccount(_ sender: NSButton) {
        self.twitterAccount?.logout()
        self.addButton.enable()
        self.removeButton.disable()

        self.set(avater: nil)
        self.set(screenName: nil)
    }

    func set(screenName string: String?) {
        if string != nil {
            self.accountName.stringValue = "@\(string!)"
            self.accountName.textColor = NSColor.labelColor
            return
        }

        self.accountName.stringValue = "Account Name"
        self.accountName.textColor = NSColor.disabledControlTextColor
    }

    func set(avater url: URL?) {
        if url != nil {
            self.accountAvater.fetchImage(url: url!)
            self.accountAvater.enable()
            return
        }

        self.accountAvater.image = NSImage.init(named: .user)
        self.accountAvater.disable()
    }

}
