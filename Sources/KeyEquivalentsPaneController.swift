/**
 *  KeyEquivalentsPaneController.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Cocoa
import Magnet
import KeyHolder

class KeyEquivalentsPaneController: NSViewController, RecordViewDelegate {

    static let shared: KeyEquivalentsPaneController = {
        let windowController = NSStoryboard.main!.instantiateController(withIdentifier: .keyEquivalentsPaneController)
        return windowController as! KeyEquivalentsPaneController
    }()

    private let userDefaults: UserDefaults = UserDefaults.standard

    private let keyEquivalents: GlobalKeyEquivalents = GlobalKeyEquivalents.shared

    @IBOutlet weak var currentRecordView: RecordView!

    @IBOutlet weak var gridView: NSGridView!

    private var selectedRecortView: RecordView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

        self.currentRecordView.tintColor = .systemBlue
        self.currentRecordView.cornerRadius = 12
        self.currentRecordView.delegate = self
        self.currentRecordView.identifier = NSUserInterfaceItemIdentifier(rawValue: "Current")
        self.currentRecordView.keyCombo = self.userDefaults.keyCombo(forKey: "Current")

        self.reloadView()

        let reloadView: (Notification) -> () = { notification in
            self.reloadView()
        }
        NotificationCenter.default.addObserver(forName: .login, object: nil, queue: nil, using: reloadView)
        NotificationCenter.default.addObserver(forName: .logout, object: nil, queue: nil, using: reloadView)
    }

    override func cancelOperation(_ sender: Any?) {
        self.selectedRecortView?.endRecording()
    }

    private func reloadView() {
        for _ in 2..<self.gridView.numberOfRows {
            self.gridView.removeRowWithView(at: 2)
        }

        let accountKeyShortcut = self.gridView.row(at: 1)

        if !Accounts.shared.existAccount {
            if #available(OSX 10.14, *) {
                accountKeyShortcut.isHidden = true
            } else {
                accountKeyShortcut.height = 0
                self.gridView.rowSpacing = 0
            }

            return
        }

        if #available(OSX 10.14, *) {
            accountKeyShortcut.isHidden = false
        } else {
            accountKeyShortcut.height = 21
            self.gridView.rowSpacing = 8
        }

        for accountID in Accounts.shared.accountIDs {
            let accountName: String = Accounts.shared.account(userID: accountID)?.screenName ?? "null"
            let recordLabel: NSTextField = NSTextField(labelWithString: "Tweet with @\(accountName):")

            let recordView = RecordView()
            recordView.tintColor = .systemBlue
            recordView.cornerRadius = 12
            recordView.delegate = self
            recordView.identifier = NSUserInterfaceItemIdentifier(rawValue: accountID)
            recordView.keyCombo = self.userDefaults.keyCombo(forKey: accountID)

            let recordRow = self.gridView.addRow(with: [recordLabel, recordView])
            recordRow.height = 24
            recordRow.cell(at: 0).yPlacement = .center
        }
    }

    func recordViewShouldBeginRecording(_ recordView: RecordView) -> Bool {
        if recordView.identifier == nil { return false }
        recordView.keyCombo = nil
        self.selectedRecortView = recordView
        return true
    }

    func recordView(_ recordView: RecordView, canRecordKeyCombo keyCombo: KeyCombo) -> Bool {
        guard let identifier = recordView.identifier?.rawValue else { return false }
        self.keyEquivalents.unregister(identifier)
        return true
    }

    func recordViewDidClearShortcut(_ recordView: RecordView) {
        guard let identifier = recordView.identifier?.rawValue else { return }
        self.keyEquivalents.unregister(identifier)
    }

    func recordView(_ recordView: RecordView, didChangeKeyCombo keyCombo: KeyCombo) {
        guard let identifier = recordView.identifier?.rawValue else { return }
        self.keyEquivalents.register(identifier, keyCombo: keyCombo)
    }

    func recordViewDidEndRecording(_ recordView: RecordView) {
        self.selectedRecortView = nil
        guard let identifier = recordView.identifier?.rawValue else { return }
        recordView.keyCombo = self.userDefaults.keyCombo(forKey: identifier)
    }

}
