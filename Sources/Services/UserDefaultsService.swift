//
//  UserDefaultsService.swift
//  LocalStorageKit
//
//  Created by LammaTech on 2025.
//

import Foundation

/// Default implementation of UserDefaultsServiceProtocol.
///
/// Provides a clean interface for working with UserDefaults while
/// supporting dependency injection and testing.
///
/// # Example
/// ```swift
/// // Using standard UserDefaults
/// let service = UserDefaultsService()
///
/// // Using App Group UserDefaults
/// let appGroupDefaults = UserDefaults(suiteName: "group.com.myapp")!
/// let service = UserDefaultsService(userDefaults: appGroupDefaults)
///
/// // Store and retrieve values
/// service.setValue("John", for: "userName")
/// let name: String? = service.getValue(for: "userName")
/// ```
public final class UserDefaultsService: UserDefaultsServiceProtocol {

  /// Shared instance using standard UserDefaults.
  public static let shared = UserDefaultsService()

  private let userDefaults: UserDefaults

  /// Creates a UserDefaults service.
  /// - Parameter userDefaults: The UserDefaults instance to use (defaults to .standard)
  public init(userDefaults: UserDefaults = .standard) {
    self.userDefaults = userDefaults
  }

  // MARK: - UserDefaultsServiceProtocol

  public func getValue<T>(for key: String) -> T? {
    return userDefaults.object(forKey: key) as? T
  }

  public func setValue<T>(_ value: T?, for key: String) {
    if value == nil {
      userDefaults.removeObject(forKey: key)
    } else {
      userDefaults.set(value, forKey: key)
    }
  }

  public func removeValue(for key: String) {
    userDefaults.removeObject(forKey: key)
  }

  public func getCodable<T: Codable>(for key: String, type: T.Type) -> T? {
    guard let data = userDefaults.data(forKey: key) else { return nil }
    return try? JSONDecoder().decode(type, from: data)
  }

  public func setCodable<T: Codable>(_ value: T?, for key: String) {
    guard let value = value else {
      userDefaults.removeObject(forKey: key)
      return
    }
    guard let data = try? JSONEncoder().encode(value) else { return }
    userDefaults.set(data, forKey: key)
  }

  public func hasValue(for key: String) -> Bool {
    return userDefaults.object(forKey: key) != nil
  }

  public func clearAll() {
    guard let bundleId = Bundle.main.bundleIdentifier else { return }
    userDefaults.removePersistentDomain(forName: bundleId)
    userDefaults.synchronize()
  }

  // MARK: - Convenience Methods

  /// Gets a string value for the specified key.
  public func getString(for key: String) -> String? {
    return userDefaults.string(forKey: key)
  }

  /// Gets an integer value for the specified key.
  public func getInt(for key: String) -> Int {
    return userDefaults.integer(forKey: key)
  }

  /// Gets a double value for the specified key.
  public func getDouble(for key: String) -> Double {
    return userDefaults.double(forKey: key)
  }

  /// Gets a boolean value for the specified key.
  public func getBool(for key: String) -> Bool {
    return userDefaults.bool(forKey: key)
  }

  /// Gets a Data value for the specified key.
  public func getData(for key: String) -> Data? {
    return userDefaults.data(forKey: key)
  }

  /// Gets an array value for the specified key.
  public func getArray<T>(for key: String) -> [T]? {
    return userDefaults.array(forKey: key) as? [T]
  }

  /// Gets a dictionary value for the specified key.
  public func getDictionary(for key: String) -> [String: Any]? {
    return userDefaults.dictionary(forKey: key)
  }

  /// Gets a Date value for the specified key.
  public func getDate(for key: String) -> Date? {
    return userDefaults.object(forKey: key) as? Date
  }

  /// Gets a URL value for the specified key.
  public func getURL(for key: String) -> URL? {
    return userDefaults.url(forKey: key)
  }
}
