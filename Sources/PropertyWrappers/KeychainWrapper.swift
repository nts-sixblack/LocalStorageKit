//
//  KeychainWrapper.swift
//  LocalStorageKit
//
//  Created by LammaTech on 2025.
//

import Combine
import Foundation
import KeychainAccess

/// A property wrapper that stores values securely in Keychain.
///
/// Use this wrapper for storing sensitive data like tokens, passwords,
/// or any information that should be stored securely.
///
/// Supports: `String`, `Bool`, `Int`, `Double`, and any `Codable` type.
///
/// # Example
/// ```swift
/// class SecureStorage {
///     @KeychainWrapper(key: "authToken", defaultValue: "")
///     var authToken: String
///
///     @KeychainWrapper(key: "isPremium", defaultValue: false)
///     var isPremium: Bool
///
///     @KeychainWrapper(key: "userId", defaultValue: 0)
///     var userId: Int
/// }
/// ```
///
/// # Custom Keychain Service
/// ```swift
/// let customKeychain = Keychain(service: "com.myapp.secure")
///
/// @KeychainWrapper(key: "secret", defaultValue: "", keychain: customKeychain)
/// var secret: String
/// ```
@propertyWrapper
public struct KeychainWrapper<Value> {

  private let key: String
  private let defaultValue: Value
  private let keychain: Keychain

  /// Creates a Keychain property wrapper.
  /// - Parameters:
  ///   - key: The key to store the value under
  ///   - defaultValue: The default value if no value exists
  ///   - keychain: The Keychain instance to use (defaults to shared KeychainService)
  public init(
    key: String,
    defaultValue: Value,
    keychain: Keychain? = nil
  ) {
    self.key = key
    self.defaultValue = defaultValue
    self.keychain = keychain ?? KeychainService.shared.keychain
  }

  public var wrappedValue: Value {
    get {
      return getValue() ?? defaultValue
    }
    set {
      setValue(newValue)
    }
  }

  /// The projected value provides access to the wrapper itself.
  public var projectedValue: KeychainWrapper<Value> {
    return self
  }

  /// Removes the stored value from Keychain.
  public func remove() {
    try? keychain.remove(key)
  }

  /// Checks if a value exists in Keychain.
  public var hasValue: Bool {
    return (try? keychain.get(key)) != nil
  }

  public static subscript<EnclosingSelf: ObservableObject>(
    _enclosingInstance object: EnclosingSelf,
    wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Value>,
    storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, KeychainWrapper>
  ) -> Value {
    get {
      object[keyPath: storageKeyPath].wrappedValue
    }
    set {
      (object.objectWillChange as? ObservableObjectPublisher)?.send()
      object[keyPath: storageKeyPath].wrappedValue = newValue
    }
  }

  // MARK: - Private Methods

  private func getValue() -> Value? {
    // Handle String
    if Value.self == String.self {
      return try? keychain.get(key) as? Value
    }

    // Handle Bool
    if Value.self == Bool.self {
      guard let string = try? keychain.get(key) else { return nil }
      return (string == "true") as? Value
    }

    // Handle Int
    if Value.self == Int.self {
      guard let string = try? keychain.get(key) else { return nil }
      return Int(string) as? Value
    }

    // Handle Double
    if Value.self == Double.self {
      guard let string = try? keychain.get(key) else { return nil }
      return Double(string) as? Value
    }

    // Handle Codable
    if let codableType = Value.self as? Codable.Type {
      guard let data = try? keychain.getData(key) else { return nil }
      return try? JSONDecoder().decode(codableType, from: data) as? Value
    }

    return nil
  }

  private func setValue(_ newValue: Value) {
    // Handle String
    if let string = newValue as? String {
      try? keychain.set(string, key: key)
      return
    }

    // Handle Bool
    if let bool = newValue as? Bool {
      try? keychain.set(bool ? "true" : "false", key: key)
      return
    }

    // Handle Int
    if let int = newValue as? Int {
      try? keychain.set(String(int), key: key)
      return
    }

    // Handle Double
    if let double = newValue as? Double {
      try? keychain.set(String(double), key: key)
      return
    }

    // Handle Codable
    if let codable = newValue as? Codable {
      guard let data = try? JSONEncoder().encode(codable) else { return }
      try? keychain.set(data, key: key)
      return
    }
  }
}

// MARK: - ObservableKeychain Wrapper (for SwiftUI)

/// A property wrapper that stores values in Keychain and publishes changes.
///
/// Use this in ObservableObject classes for automatic UI updates.
///
/// # Example
/// ```swift
/// class UserStorage: ObservableObject {
///     @ObservableKeychainWrapper(key: "coins", defaultValue: 0)
///     var coins: Int
/// }
///
/// struct ContentView: View {
///     @ObservedObject var storage = UserStorage()
///
///     var body: some View {
///         Text("Coins: \(storage.coins)")
///     }
/// }
/// ```
@propertyWrapper
public class ObservableKeychainWrapper<Value>: ObservableObject {

  private let key: String
  private let defaultValue: Value
  private let keychain: Keychain

  @Published private var _value: Value

  public init(
    key: String,
    defaultValue: Value,
    keychain: Keychain? = nil
  ) {
    self.key = key
    self.defaultValue = defaultValue
    self.keychain = keychain ?? KeychainService.shared.keychain
    self._value = defaultValue

    // Load initial value
    self._value = loadValue() ?? defaultValue
  }

  public var wrappedValue: Value {
    get { _value }
    set {
      objectWillChange.send()
      _value = newValue
      saveValue(newValue)
    }
  }

  public var projectedValue: ObservableKeychainWrapper<Value> { self }

  // MARK: - Private Methods

  private func loadValue() -> Value? {
    if Value.self == String.self {
      return try? keychain.get(key) as? Value
    }
    if Value.self == Bool.self {
      guard let string = try? keychain.get(key) else { return nil }
      return (string == "true") as? Value
    }
    if Value.self == Int.self {
      guard let string = try? keychain.get(key) else { return nil }
      return Int(string) as? Value
    }
    if Value.self == Double.self {
      guard let string = try? keychain.get(key) else { return nil }
      return Double(string) as? Value
    }
    return nil
  }

  private func saveValue(_ newValue: Value) {
    if let string = newValue as? String {
      try? keychain.set(string, key: key)
    } else if let bool = newValue as? Bool {
      try? keychain.set(bool ? "true" : "false", key: key)
    } else if let int = newValue as? Int {
      try? keychain.set(String(int), key: key)
    } else if let double = newValue as? Double {
      try? keychain.set(String(double), key: key)
    }
  }
}
