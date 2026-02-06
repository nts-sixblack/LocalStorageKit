//
//  KeychainServiceProtocol.swift
//  LocalStorageKit
//
//  Created by LammaTech on 2025.
//

import Foundation
import KeychainAccess

/// Protocol defining the interface for Keychain storage operations.
///
/// Use this protocol to abstract Keychain access, making your code
/// easier to test with mock implementations.
///
/// # Example
/// ```swift
/// class SecureStorage {
///     private let keychainService: KeychainServiceProtocol
///
///     init(keychainService: KeychainServiceProtocol = KeychainService.shared) {
///         self.keychainService = keychainService
///     }
///
///     var authToken: String? {
///         get { keychainService.getString(for: "authToken") }
///         set { keychainService.setString(newValue, for: "authToken") }
///     }
/// }
/// ```
public protocol KeychainServiceProtocol: AnyObject {

  /// The underlying Keychain instance.
  var keychain: Keychain { get }

  // MARK: - String Operations

  /// Retrieves a string value from keychain.
  /// - Parameter key: The key to look up
  /// - Returns: The string value if found, nil otherwise
  func getString(for key: String) -> String?

  /// Stores a string value in keychain.
  /// - Parameters:
  ///   - value: The string to store (nil to remove)
  ///   - key: The key to store under
  func setString(_ value: String?, for key: String)

  // MARK: - Data Operations

  /// Retrieves raw data from keychain.
  /// - Parameter key: The key to look up
  /// - Returns: The data if found, nil otherwise
  func getData(for key: String) -> Data?

  /// Stores raw data in keychain.
  /// - Parameters:
  ///   - value: The data to store (nil to remove)
  ///   - key: The key to store under
  func setData(_ value: Data?, for key: String)

  // MARK: - Convenience Operations

  /// Retrieves an integer value from keychain.
  /// - Parameter key: The key to look up
  /// - Returns: The integer value if found, nil otherwise
  func getInt(for key: String) -> Int?

  /// Stores an integer value in keychain.
  /// - Parameters:
  ///   - value: The integer to store
  ///   - key: The key to store under
  func setInt(_ value: Int, for key: String)

  /// Retrieves a boolean value from keychain.
  /// - Parameter key: The key to look up
  /// - Returns: The boolean value if found, nil otherwise
  func getBool(for key: String) -> Bool?

  /// Stores a boolean value in keychain.
  /// - Parameters:
  ///   - value: The boolean to store
  ///   - key: The key to store under
  func setBool(_ value: Bool, for key: String)

  /// Retrieves and decodes a Codable value from keychain.
  /// - Parameters:
  ///   - key: The key to look up
  ///   - type: The type to decode to
  /// - Returns: The decoded value if found, nil otherwise
  func getCodable<T: Codable>(for key: String, type: T.Type) -> T?

  /// Encodes and stores a Codable value in keychain.
  /// - Parameters:
  ///   - value: The value to encode and store
  ///   - key: The key to store under
  func setCodable<T: Codable>(_ value: T?, for key: String)

  // MARK: - Management

  /// Removes the value for the specified key.
  /// - Parameter key: The key to remove
  func remove(key: String)

  /// Removes all items from keychain.
  func clear()

  /// Checks if a key exists in keychain.
  /// - Parameter key: The key to check
  /// - Returns: true if the key exists
  func hasValue(for key: String) -> Bool
}

// MARK: - Default Implementations

extension KeychainServiceProtocol {

  public func getInt(for key: String) -> Int? {
    guard let string = getString(for: key) else { return nil }
    return Int(string)
  }

  public func setInt(_ value: Int, for key: String) {
    setString(String(value), for: key)
  }

  public func getBool(for key: String) -> Bool? {
    guard let string = getString(for: key) else { return nil }
    return string == "true"
  }

  public func setBool(_ value: Bool, for key: String) {
    setString(value ? "true" : "false", for: key)
  }

  public func getCodable<T: Codable>(for key: String, type: T.Type) -> T? {
    guard let data = getData(for: key) else { return nil }
    return try? JSONDecoder().decode(type, from: data)
  }

  public func setCodable<T: Codable>(_ value: T?, for key: String) {
    guard let value = value else {
      remove(key: key)
      return
    }
    guard let data = try? JSONEncoder().encode(value) else { return }
    setData(data, for: key)
  }

  public func hasValue(for key: String) -> Bool {
    return getString(for: key) != nil || getData(for: key) != nil
  }
}
