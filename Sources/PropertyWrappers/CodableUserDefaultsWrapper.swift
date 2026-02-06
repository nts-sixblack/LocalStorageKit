//
//  CodableUserDefaultsWrapper.swift
//  LocalStorageKit
//
//  Created by LammaTech on 2025.
//

import Combine
import Foundation

/// A property wrapper that stores Codable values in UserDefaults.
///
/// Use this wrapper for storing custom Codable types. The value is encoded
/// to JSON Data before storage and decoded when retrieved.
///
/// # Example
/// ```swift
/// struct UserSettings: Codable {
///     var theme: String
///     var fontSize: Int
///     var notifications: Bool
/// }
///
/// class AppSettings {
///     @CodableUserDefaultsWrapper(
///         key: "userSettings",
///         defaultValue: UserSettings(theme: "light", fontSize: 14, notifications: true)
///     )
///     var settings: UserSettings
/// }
/// ```
///
/// # With Custom Encoder/Decoder
/// ```swift
/// let customEncoder = JSONEncoder()
/// customEncoder.keyEncodingStrategy = .convertToSnakeCase
///
/// @CodableUserDefaultsWrapper(
///     key: "settings",
///     defaultValue: Settings(),
///     encoder: customEncoder
/// )
/// var settings: Settings
/// ```
@propertyWrapper
public struct CodableUserDefaultsWrapper<Value: Codable> {

  private let key: String
  private let defaultValue: Value
  private let userDefaults: UserDefaults
  private let encoder: JSONEncoder
  private let decoder: JSONDecoder

  /// Creates a Codable UserDefaults property wrapper.
  /// - Parameters:
  ///   - key: The key to store the value under
  ///   - defaultValue: The default value if no value exists
  ///   - userDefaults: The UserDefaults instance to use (defaults to .standard)
  ///   - encoder: Custom JSONEncoder (optional)
  ///   - decoder: Custom JSONDecoder (optional)
  public init(
    key: String,
    defaultValue: Value,
    userDefaults: UserDefaults = .standard,
    encoder: JSONEncoder = JSONEncoder(),
    decoder: JSONDecoder = JSONDecoder()
  ) {
    self.key = key
    self.defaultValue = defaultValue
    self.userDefaults = userDefaults
    self.encoder = encoder
    self.decoder = decoder
  }

  public var wrappedValue: Value {
    get {
      guard let data = userDefaults.data(forKey: key) else {
        return defaultValue
      }
      do {
        return try decoder.decode(Value.self, from: data)
      } catch {
        #if DEBUG
          print("[LocalStorageKit] Failed to decode \(Value.self) for key '\(key)': \(error)")
        #endif
        return defaultValue
      }
    }
    set {
      do {
        let data = try encoder.encode(newValue)
        userDefaults.set(data, forKey: key)
      } catch {
        #if DEBUG
          print("[LocalStorageKit] Failed to encode \(Value.self) for key '\(key)': \(error)")
        #endif
      }
    }
  }

  /// The projected value provides access to the wrapper itself.
  public var projectedValue: CodableUserDefaultsWrapper<Value> {
    return self
  }

  /// Removes the stored value, resetting to default.
  public func reset() {
    userDefaults.removeObject(forKey: key)
  }

  /// Checks if a value has been explicitly set.
  public var hasValue: Bool {
    return userDefaults.data(forKey: key) != nil
  }

  public static subscript<EnclosingSelf: ObservableObject>(
    _enclosingInstance object: EnclosingSelf,
    wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Value>,
    storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, CodableUserDefaultsWrapper>
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
