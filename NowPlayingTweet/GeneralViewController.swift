/**
 *  GeneralViewController.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa

class GeneralViewController: NSViewController {

    @IBOutlet weak var tweetFormatView: NSScrollView!
    @IBOutlet var tweetFormat: NSTextView!
    @IBOutlet weak var editButton: NSButton!

    var userDefaults: UserDefaults = UserDefaults.standard

    static let shared: GeneralViewController = {
        let storyboard = NSStoryboard(name: .main, bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: .generalViewController)
        return windowController as! GeneralViewController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self.updateTweetFormatLabel()
    }

    @IBAction func editFormat(_ sender: NSButton) {
        let isEditable = self.tweetFormat.isEditable
        
        self.editButton.keyEquivalent = isEditable ? "" : "\r"
        self.tweetFormatView.borderType = isEditable ? .noBorder : .bezelBorder
        self.tweetFormat.textColor = isEditable ? .labelColor : .textColor
        self.tweetFormat.drawsBackground = isEditable ? false : true

        if isEditable {
            self.change(format: self.tweetFormat.string)
            self.tweetFormat.isSelectable = false
        } else {
            self.tweetFormat.isEditable = true
        }
    }

    @IBAction func resetFormat(_ sender: NSButton) {
        self.userDefaults.removeObject(forKey: "TweetFormat")
        self.userDefaults.synchronize()
        self.updateTweetFormatLabel()
    }

    func change(format: String) {
        self.userDefaults.set(format, forKey: "TweetFormat")
        self.userDefaults.synchronize()
        self.updateTweetFormatLabel()
    }

    private func updateTweetFormatLabel() {
        self.tweetFormat.string = (self.userDefaults.string(forKey: "TweetFormat"))!
    }

}
