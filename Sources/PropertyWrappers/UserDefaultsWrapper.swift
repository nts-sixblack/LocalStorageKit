//
//  UserDefaultsWrapper.swift
//  LocalStorageKit
//
//  Created by LammaTech on 2025.
//

import Combine
import Foundation

/// A property wrapper that stores values in UserDefaults.
///
/// Use this wrapper for storing primitive types that UserDefaults natively supports:
/// `Bool`, `Int`, `Double`, `Float`, `String`, `Data`, `Date`, `URL`, `Array`, `Dictionary`.
///
/// # Example
/// ```swift
/// class Settings {
///     @UserDefaultsWrapper(key: "isDarkMode", defaultValue: false)
///     var isDarkMode: Bool
///
///     @UserDefaultsWrapper(key: "fontSize", defaultValue: 14)
///     var fontSize: Int
///
///     @UserDefaultsWrapper(key: "username", defaultValue: "")
///     var username: String
/// }
/// ```
///
/// # Custom UserDefaults Suite
/// ```swift
/// let appGroupDefaults = UserDefaults(suiteName: "group.com.myapp")!
///
/// @UserDefaultsWrapper(key: "sharedValue", defaultValue: 0, userDefaults: appGroupDefaults)
/// var sharedValue: Int
/// ```
@propertyWrapper
public struct UserDefaultsWrapper<Value> {

  private let key: String
  private let defaultValue: Value
  private let userDefaults: UserDefaults

  /// Creates a UserDefaults property wrapper.
  /// - Parameters:
  ///   - key: The key to store the value under
  ///   - defaultValue: The default value if no value exists
  ///   - userDefaults: The UserDefaults instance to use (defaults to .standard)
  public init(
    key: String,
    defaultValue: Value,
    userDefaults: UserDefaults = .standard
  ) {
    self.key = key
    self.defaultValue = defaultValue
    self.userDefaults = userDefaults
  }

  public var wrappedValue: Value {
    get {
      return userDefaults.object(forKey: key) as? Value ?? defaultValue
    }
    set {
      if let optional = newValue as? AnyOptional, optional.isNil {
        userDefaults.removeObject(forKey: key)
      } else {
        userDefaults.set(newValue, forKey: key)
      }
    }
  }

  /// The projected value provides access to the wrapper itself.
  public var projectedValue: UserDefaultsWrapper<Value> {
    return self
  }

  /// Removes the stored value, resetting to default.
  public func reset() {
    userDefaults.removeObject(forKey: key)
  }

  /// Checks if a value has been explicitly set.
  public var hasValue: Bool {
    return userDefaults.object(forKey: key) != nil
  }

  public static subscript<EnclosingSelf: ObservableObject>(
    _enclosingInstance object: EnclosingSelf,
    wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Value>,
    storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, UserDefaultsWrapper>
  ) -> Value {
    get {
      return object[keyPath: storageKeyPath].wrappedValue
    }
    set {
      (object.objectWillChange as? ObservableObjectPublisher)?.send()
      object[keyPath: storageKeyPath].wrappedValue = newValue
    }
  }
}

// MARK: - Optional Support

/// Protocol to check for nil in Any type
private protocol AnyOptional {
  var isNil: Bool { get }
}

extension Optional: AnyOptional {
  fileprivate var isNil: Bool {
    return self == nil
  }
}
