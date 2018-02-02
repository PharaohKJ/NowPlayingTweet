/**
 *  NotificationObserver.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Foundation

class NotificationObserver {

    let notificationCenter: NotificationCenter = NotificationCenter.default

    let distNotificationCenter: DistributedNotificationCenter = DistributedNotificationCenter.default()

    func addObserver(_ distributed: Bool = false, _ observer: Any, name: Notification.Name, selector: Selector, object: Any? = nil) {
        if distributed {
            distNotificationCenter.addObserver(observer, selector: selector, name: name, object: object as? String)
        } else {
            notificationCenter.addObserver(observer, selector: selector, name: name, object: object)
        }
    }

    func removeObserver(_ distributed: Bool = false, _ observer: Any, name: Notification.Name, object: Any? = nil) {
        if distributed {
            distNotificationCenter.removeObserver(observer, name: name, object: object as? String)
        } else {
            notificationCenter.removeObserver(observer, name: name, object: object)
        }
    }

}
