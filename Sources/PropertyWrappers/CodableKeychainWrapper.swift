//
//  CodableKeychainWrapper.swift
//  LocalStorageKit
//
//  Created by LammaTech on 2025.
//

import Combine
import Foundation
import KeychainAccess

/// A property wrapper that stores Codable values securely in Keychain.
///
/// Use this wrapper for storing sensitive Codable objects. The value is encoded
/// to JSON Data before storage and decoded when retrieved.
///
/// # Example
/// ```swift
/// struct UserCredentials: Codable {
///     var accessToken: String
///     var refreshToken: String
/// }
///
/// class AuthManager {
///     @CodableKeychainWrapper(key: "credentials", defaultValue: nil)
///     var credentials: UserCredentials?
/// }
/// ```
@propertyWrapper
public struct CodableKeychainWrapper<Value: Codable> {

  private let key: String
  private let defaultValue: Value
  private let keychain: Keychain
  private let encoder: JSONEncoder
  private let decoder: JSONDecoder

  /// Creates a Codable Keychain property wrapper.
  /// - Parameters:
  ///   - key: The key to store the value under
  ///   - defaultValue: The default value if no value exists
  ///   - keychain: The Keychain instance to use (defaults to shared KeychainService)
  ///   - encoder: Custom JSONEncoder (optional)
  ///   - decoder: Custom JSONDecoder (optional)
  public init(
    key: String,
    defaultValue: Value,
    keychain: Keychain? = nil,
    encoder: JSONEncoder = JSONEncoder(),
    decoder: JSONDecoder = JSONDecoder()
  ) {
    self.key = key
    self.defaultValue = defaultValue
    self.keychain = keychain ?? KeychainService.shared.keychain
    self.encoder = encoder
    self.decoder = decoder
  }

  public var wrappedValue: Value {
    get {
      guard let data = try? keychain.getData(key) else {
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
      if let optional = newValue as? AnyOptional, optional.isNil {
        try? keychain.remove(key)
        return
      }

      do {
        let data = try encoder.encode(newValue)
        try keychain.set(data, key: key)
      } catch {
        #if DEBUG
          print("[LocalStorageKit] Failed to encode \(Value.self) for key '\(key)': \(error)")
        #endif
      }
    }
  }

  /// The projected value provides access to the wrapper itself.
  public var projectedValue: CodableKeychainWrapper<Value> {
    return self
  }

  /// Removes the stored value, resetting to default.
  public func remove() {
    try? keychain.remove(key)
  }

  /// Checks if a value has been explicitly set.
  public var hasValue: Bool {
    return (try? keychain.getData(key)) != nil
  }

  public static subscript<EnclosingSelf: ObservableObject>(
    _enclosingInstance object: EnclosingSelf,
    wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Value>,
    storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, CodableKeychainWrapper>
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
