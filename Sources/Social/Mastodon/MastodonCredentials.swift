/**
 *  MastodonCredentials.swift
 *  NowPlayingTweet
 *
 *  © 2019 kPherox.
**/

import Foundation

struct MastodonCredentials: D14nCredentials, OAuth2, Codable {

    let base: String

    let apiKey: String
    let apiSecret: String

    let oauthToken: String

}