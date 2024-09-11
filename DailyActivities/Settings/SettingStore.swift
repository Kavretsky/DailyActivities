//
//  SettingStore.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 10.09.2024.
//

import Foundation
import Observation
import UserNotifications

protocol KeyValueStorage {
    func value<T>(for key: SettingKey) -> T?
    func saveValue<T>(_ value: T, for key: SettingKey)
}

enum SettingKey: String {
    case notification = "notification"
}

@Observable
final class SettingStore<T: KeyValueStorage> {
    private(set) var notifications: NotificationSettings
    private let storage: T
    
    init(keyValueStorage: T) {
        self.storage = keyValueStorage
        
        if let storedValue: NotificationSettings = storage.value(for: .notification) {
            self.notifications = storedValue
        } else {
            self.notifications = .init()
        }
    }
    
    func switchNotification() {
        notifications.isEnabled.toggle()
    }
    
    func updateNotificationInterval(_ value: Int) {
        if value >= SettingsStoreConstants.minTimeInterval, value <= SettingsStoreConstants.maxTimeInterval {
            notifications.intervalMin = value
        }
    }
}

fileprivate struct SettingsStoreConstants {
    static let minTimeInterval = 30
    static let maxTimeInterval = 60
}
