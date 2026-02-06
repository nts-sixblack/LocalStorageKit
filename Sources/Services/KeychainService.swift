//
//  KeychainService.swift
//  LocalStorageKit
//
//  Created by LammaTech on 2025.
//

import Foundation
import KeychainAccess

/// Default implementation of KeychainServiceProtocol.
///
/// Provides secure storage for sensitive data using the iOS Keychain.
///
/// # Example
/// ```swift
/// // Using shared instance
/// let service = KeychainService.shared
/// service.setString("secret_token", for: "authToken")
/// let token = service.getString(for: "authToken")
///
/// // Using custom service identifier
/// let customService = KeychainService(service: "com.myapp.secure")
///
/// // Using with access group (for sharing between apps)
/// let sharedService = KeychainService(
///     service: "com.myapp.secure",
///     accessGroup: "TEAM_ID.com.myapp.shared"
/// )
/// ```
public final class KeychainService: KeychainServiceProtocol {

  /// Shared instance using bundle identifier as service name.
  public static let shared = KeychainService()

  /// The underlying Keychain instance.
  public let keychain: Keychain

  /// Creates a Keychain service with default settings.
  ///
  /// Uses the bundle identifier as the service name.
  public init() {
    let bundleId = Bundle.main.bundleIdentifier ?? "com.localstoragekit.default"
    self.keychain = Keychain(service: bundleId)
  }

  /// Creates a Keychain service with a custom service identifier.
  /// - Parameter service: The service identifier for the keychain
  public init(service: String) {
    self.keychain = Keychain(service: service)
  }

  /// Creates a Keychain service with custom service and access group.
  /// - Parameters:
  ///   - service: The service identifier for the keychain
  ///   - accessGroup: The access group for sharing between apps
  public init(service: String, accessGroup: String) {
    self.keychain = Keychain(service: service, accessGroup: accessGroup)
  }

  /// Creates a Keychain service with an existing Keychain instance.
  /// - Parameter keychain: The Keychain instance to use
  public init(keychain: Keychain) {
    self.keychain = keychain
  }

  // MARK: - String Operations

  public func getString(for key: String) -> String? {
    return try? keychain.get(key)
  }

  public func setString(_ value: String?, for key: String) {
    if let value = value {
      try? keychain.set(value, key: key)
    } else {
      try? keychain.remove(key)
    }
  }

  // MARK: - Data Operations

  public func getData(for key: String) -> Data? {
    return try? keychain.getData(key)
  }

  public func setData(_ value: Data?, for key: String) {
    if let value = value {
      try? keychain.set(value, key: key)
    } else {
      try? keychain.remove(key)
    }
  }

  // MARK: - Management

  public func remove(key: String) {
    try? keychain.remove(key)
  }

  public func clear() {
    try? keychain.removeAll()
  }

  // MARK: - Additional Convenience Methods

  /// Gets all keys stored in the keychain.
  public var allKeys: [String] {
    return keychain.allKeys()
  }

  /// Checks if a key exists in the keychain.
  public func contains(_ key: String) -> Bool {
    return (try? keychain.contains(key)) ?? false
  }

  /// Sets a string value with accessibility options.
  /// - Parameters:
  ///   - value: The string value to store
  ///   - key: The key to store under
  ///   - accessibility: When the keychain item is accessible
  public func setString(
    _ value: String,
    for key: String,
    accessibility: Accessibility
  ) {
    try? keychain
      .accessibility(accessibility)
      .set(value, key: key)
  }

  /// Sets a data value with accessibility options.
  /// - Parameters:
  ///   - value: The data value to store
  ///   - key: The key to store under
  ///   - accessibility: When the keychain item is accessible
  public func setData(
    _ value: Data,
    for key: String,
    accessibility: Accessibility
  ) {
    try? keychain
      .accessibility(accessibility)
      .set(value, key: key)
  }
}

// MARK: - Accessibility Typealias

/// Re-export KeychainAccess Accessibility for convenience.
public typealias Accessibility = KeychainAccess.Accessibility
