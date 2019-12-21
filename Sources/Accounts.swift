/**
 *  Accounts.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Foundation
import KeychainAccess

class Accounts {

    static let shared = Accounts()

    private let userDefaults = UserDefaults.standard

    private var storage: [Provider : ProviderAccounts] = [:]

    var availableProviders: [Provider] {
        return .init(self.storage.keys)
    }

    var sortedAccounts: [Account] {
        var result: [Account] = []

        for provider in self.availableProviders {
            if let accounts = self.storage[provider] {
                result += accounts.storage.keys.sorted().map { accounts.storage[$0]!.0 }
            }
        }

        return result
    }

    var existsAccounts: Bool {
        return self.sortedAccounts.count > 0
    }

    var current: Account? {
        get {
            guard let provider = self.userDefaults.provider(forKey: "CurrentProvider")
                , let id = self.userDefaults.string(forKey: "CurrentAccountID")
                , let (account, _) = self.storage[provider]?.storage[id] else {
                    return nil
            }

            return account
        }

        set {
            guard let current = newValue else {
                self.userDefaults.removeObject(forKey: "CurrentProvider")
                self.userDefaults.removeObject(forKey: "CurrentAccountID")
                return
            }

            self.userDefaults.set(type(of: current).provider, forKey: "CurrentProvider")
            self.userDefaults.set(current.id, forKey: "CurrentAccountID")
        }
    }

    private init() {
        var providers: [Provider] = Provider.allCases

        var observer: NSObjectProtocol!
        observer = NotificationCenter.default.addObserver(forName: .socialAccountsInitialize, object: nil, queue: nil, using: { notification in
            guard let initalizedProvider = notification.userInfo?["provider"] as? Provider else {
                return
            }

            providers.removeAll { $0 == initalizedProvider }

            if providers.count > 0 {
                return
            }

            if self.current == nil {
                self.current = self.sortedAccounts.first
            }

            NotificationQueue.default.enqueue(.init(name: .alreadyAccounts, object: nil), postingStyle: .whenIdle)

            NotificationCenter.default.removeObserver(observer!)
        })

        for provider in providers {
            if let providerAccounts = provider.accounts?.init(keychainPrefix: "com.kr-kp.NowPlayingTweet.Accounts") {
                self.storage[provider] = providerAccounts
                continue
            }

            providers.removeAll { $0 == provider }

            if providers.count > 0 {
                continue
            }

            if self.current == nil {
                self.current = self.sortedAccounts.first
            }

            NotificationQueue.default.enqueue(.init(name: .alreadyAccounts, object: nil), postingStyle: .whenIdle)

            NotificationCenter.default.removeObserver(observer!)
        }
    }

    func client(for account: Account) -> Client? {
        let provider = type(of: account).provider
        guard let client = provider.client
            , let (_, credentials) = self.storage[provider]?.storage[account.id] else {
            return nil
        }

        return client.init(credentials)
    }

    func login(provider: Provider, base: String = "") {
        guard let accounts = self.storage[provider] else {
            return
        }

        let handler: (Account?, Error?) -> Void = { account, error in
            if let error = error {
                NSLog(error.localizedDescription)
                return
            }

            guard let account = account else {
                return
            }

            if self.current == nil {
                self.current = self.sortedAccounts.first
            }

            NotificationCenter.default.post(name: .login,
                                            object: nil,
                                            userInfo: ["account" : account])
        }

        if let accounts = accounts as? D14nProviderAccounts {
            accounts.authorize(base: base, handler: handler)
        } else {
            accounts.authorize(handler: handler)
        }
    }

    func logout(account: Account) {
        let provider = type(of: account).provider
        guard let accounts = self.storage[provider] else {
            return
        }

        accounts.revoke(id: account.id) { error in
            if let error = error {
                NSLog(error.localizedDescription)
                return
            }

            if self.current == nil {
                self.current = self.sortedAccounts.first
            }
            NotificationCenter.default.post(name: .logout,
                                            object: nil)
        }
    }

}
