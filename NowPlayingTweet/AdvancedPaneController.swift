/**
 *  AdvancedPaneController.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa

class AdvancedPaneController: NSViewController {

    @IBOutlet weak var tweetWithImage: NSButton!
    @IBOutlet weak var autoTweet: NSButton!
    @IBOutlet weak var useKeyShortcut: NSButton!

    private let appDelegate: AppDelegate = NSApplication.shared.delegate as! AppDelegate

    private let userDefaults: UserDefaults = UserDefaults.standard

    private let keyEquivalents: GlobalKeyEquivalents = GlobalKeyEquivalents.shared

    static let shared: AdvancedPaneController = {
        let storyboard = NSStoryboard(name: .main, bundle: .main)
        let windowController = storyboard.instantiateController(withIdentifier: .advancedPaneController)
        return windowController as! AdvancedPaneController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do view setup here.
        self.tweetWithImage.set(state: self.userDefaults.bool(forKey: "TweetWithImage"))
        self.autoTweet.set(state: self.userDefaults.bool(forKey: "AutoTweet"))
        self.useKeyShortcut.set(state: self.userDefaults.bool(forKey: "UseKeyShortcut"))

        self.addDisableAutoTweetObserver(state: self.userDefaults.bool(forKey: "AutoTweet"))
    }

    @IBAction private func switchSetting(_ sender: NSButton) {
        let identifier: String = (sender.identifier?.rawValue)!
        self.userDefaults.set(sender.state.toBool(), forKey: identifier)
        self.userDefaults.synchronize()
    }

    @IBAction private func switchAutoTweet(_ sender: NSButton) {
        self.appDelegate.switchAutoTweet(state: sender.state.toBool())
        self.addDisableAutoTweetObserver(state: sender.state.toBool())
    }

    @IBAction private func switchUseKeyShortcut(_ sender: NSButton) {
        let state = sender.state.toBool()

        if state {
            self.keyEquivalents.enable()
        } else {
            self.keyEquivalents.disable()
        }
    }

    private func addDisableAutoTweetObserver(state: Bool) {
        if state {
            let notificationCenter: NotificationCenter = NotificationCenter.default
            var observer: NSObjectProtocol!
            observer = notificationCenter.addObserver(forName: .disableAutoTweet, object: nil, queue: nil, using: { notification in
                self.autoTweet.set(state: false)
                notificationCenter.removeObserver(observer)
            })
        }
    }

}
