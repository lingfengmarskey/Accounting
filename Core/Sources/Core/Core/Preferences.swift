//
//  Preferences.swift
//  Userdefaults warper
//
//  Created by Marcos Meng on 2022/08/31.
//

import Foundation
import ComposableArchitecture

public protocol PreferencesProtocol {
    func set(_ obj: Any?, forKey: String)
    func value(forKey: String) -> Any?
}

public struct Preferences: PreferencesProtocol {
    public init() {}

    public func set(_ obj: Any?, forKey: String) {
        UserDefaults.standard.set(obj, forKey: forKey)
    }

    public func value(forKey: String) -> Any? {
        UserDefaults.standard.value(forKey: forKey)
    }
}

public class MockPreferences: PreferencesProtocol {
    var userInfo: [String: Any?] = [:]

    public init(_ userInfo: [String: Any?] = [:]) {
        self.userInfo = userInfo
    }

    public func set(_ obj: Any?, forKey: String) {
        self.userInfo[forKey] = obj
    }

    public func value(forKey: String) -> Any? {
        if let value = userInfo[forKey] {
            return value
        }
        return nil
    }
}

private enum PreferencesKey: DependencyKey {
    static let liveValue :PreferencesProtocol = Preferences()
}

public extension DependencyValues {
  var preferences: PreferencesProtocol {
    get { self[PreferencesKey.self] }
    set { self[PreferencesKey.self] = newValue }
  }
}
