//
//  UserDefaultsServiceProtocol.swift
//  LocalStorageKit
//
//  Created by LammaTech on 2025.
//

import Foundation

/// Protocol defining the interface for UserDefaults storage operations.
///
/// Conform to this protocol to create custom UserDefaults services
/// or mock implementations for testing.
///
/// # Example
/// ```swift
/// class MockUserDefaultsService: UserDefaultsServiceProtocol {
///     var storage: [String: Any] = [:]
///
///     func getValue<T>(for key: String) -> T? {
///         return storage[key] as? T
///     }
///
///     func setValue<T>(_ value: T?, for key: String) {
///         storage[key] = value
///     }
/// }
/// ```
public protocol UserDefaultsServiceProtocol: AnyObject {

  /// Retrieves a value from storage for the specified key.
  /// - Parameter key: The key to look up
  /// - Returns: The value if found and matches type T, nil otherwise
  func getValue<T>(for key: String) -> T?

  /// Stores a value for the specified key.
  /// - Parameters:
  ///   - value: The value to store (nil to remove)
  ///   - key: The key to store under
  func setValue<T>(_ value: T?, for key: String)

  /// Removes the value for the specified key.
  /// - Parameter key: The key to remove
  func removeValue(for key: String)

  /// Retrieves and decodes a Codable value from storage.
  /// - Parameters:
  ///   - key: The key to look up
  ///   - type: The type to decode to
  /// - Returns: The decoded value if found, nil otherwise
  func getCodable<T: Codable>(for key: String, type: T.Type) -> T?

  /// Encodes and stores a Codable value.
  /// - Parameters:
  ///   - value: The value to encode and store
  ///   - key: The key to store under
  func setCodable<T: Codable>(_ value: T?, for key: String)

  /// Checks if a key exists in storage.
  /// - Parameter key: The key to check
  /// - Returns: true if the key exists
  func hasValue(for key: String) -> Bool

  /// Removes all values from storage.
  func clearAll()
}

// MARK: - Default Implementations

extension UserDefaultsServiceProtocol {

  public func hasValue(for key: String) -> Bool {
    let value: Any? = getValue(for: key)
    return value != nil
  }

  public func clearAll() {
    // Default implementation does nothing
    // Subclasses should override
  }
}
