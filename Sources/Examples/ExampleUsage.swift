//
//  ExampleUsage.swift
//  LocalStorageKit
//
//  Created by LammaTech on 2025.
//
//  This file demonstrates how to use LocalStorageKit in your app.
//  Copy and adapt these examples for your own use case.
//

import Foundation
import LocalStorageKit
import SwiftInjected
import SwiftUI

// MARK: - Example 1: Simple App Settings

/// A simple settings class using property wrappers.
///
/// Usage:
/// ```swift
/// let settings = AppSettings()
/// settings.isDarkMode = true
/// print(settings.userName)
/// ```
/// settings.isDarkMode = true
/// print(settings.userName)
/// ```
final class AppSettings: LocalStorageService {

  @UserDefaultsWrapper(key: "isDarkMode", defaultValue: false)
  var isDarkMode: Bool

  @UserDefaultsWrapper(key: "userName", defaultValue: "")
  var userName: String

  @UserDefaultsWrapper(key: "fontSize", defaultValue: 14)
  var fontSize: Int

  @UserDefaultsWrapper(key: "isFirstLaunch", defaultValue: true)
  var isFirstLaunch: Bool

  @CodableUserDefaultsWrapper(key: "lastOpenDate", defaultValue: nil)
  var lastOpenDate: Date?
}

// MARK: - Example 2: Secure Storage for Tokens

/// Secure storage for authentication tokens.
///
/// Usage:
/// ```swift
/// let auth = AuthStorage()
/// auth.accessToken = "your_token_here"
/// if auth.isLoggedIn {
///     // User is authenticated
/// }
/// ```
///     // User is authenticated
/// }
/// ```
final class AuthStorage: LocalStorageService {

  @KeychainWrapper(key: "accessToken", defaultValue: "")
  var accessToken: String

  @KeychainWrapper(key: "refreshToken", defaultValue: "")
  var refreshToken: String

  @KeychainWrapper(key: "userId", defaultValue: 0)
  var userId: Int

  var isLoggedIn: Bool {
    return !accessToken.isEmpty
  }

  func logout() {
    $accessToken.remove()
    $refreshToken.remove()
    $userId.remove()
  }
}

// MARK: - Example 3: Complex Codable Storage

/// Store complex data structures.
struct UserProfile: Codable {
  var id: String
  var name: String
  var email: String
  var preferences: Preferences

  struct Preferences: Codable {
    var notifications: Bool
    var newsletter: Bool
    var language: String
  }
}

/// Profile storage with Codable support.
///
/// Usage:
/// ```swift
/// let storage = ProfileStorage()
/// storage.currentProfile = UserProfile(...)
/// ```
/// let storage = ProfileStorage()
/// storage.currentProfile = UserProfile(...)
/// ```
final class ProfileStorage: LocalStorageService {

  @CodableUserDefaultsWrapper(
    key: "currentProfile",
    defaultValue: nil
  )
  var currentProfile: UserProfile?

  @CodableUserDefaultsWrapper(
    key: "recentProfiles",
    defaultValue: []
  )
  var recentProfiles: [UserProfile]
}

// MARK: - Example 4: App Group Storage (for Widgets/Extensions)

/// Storage shared with app extensions via App Group.
///
/// Usage:
/// ```swift
/// let shared = SharedStorage()
/// shared.widgetData = "Updated from main app"
/// ```
/// shared.widgetData = "Updated from main app"
/// ```
final class SharedStorage: LocalStorageService {

  private static let appGroupId = "group.com.yourapp.shared"
  private static let appGroupDefaults = UserDefaults(suiteName: appGroupId)!

  @UserDefaultsWrapper(
    key: "widgetData",
    defaultValue: "",
    userDefaults: SharedStorage.appGroupDefaults
  )
  var widgetData: String

  @UserDefaultsWrapper(
    key: "lastSyncTime",
    defaultValue: 0,
    userDefaults: SharedStorage.appGroupDefaults
  )
  var lastSyncTime: TimeInterval
}

// MARK: - Example 5: SwiftUI Observable Storage

/// Observable storage for SwiftUI apps.
///
/// Usage in SwiftUI:
/// ```swift
/// @StateObject var wallet = WalletStorage()
///
/// Text("Coins: \(wallet.coins)")
///
/// Button("Add Coin") {
///     wallet.addCoins(10)
/// }
/// ```
final class WalletStorage: ObservableObject {

  private let keychainService: KeychainServiceProtocol

  @Published private(set) var coins: Int = 0

  init(keychainService: KeychainServiceProtocol = KeychainService.shared) {
    self.keychainService = keychainService
    self.coins = keychainService.getInt(for: "wallet_coins") ?? 0
  }

  func addCoins(_ amount: Int) {
    guard amount > 0 else { return }
    coins += amount
    keychainService.setInt(coins, for: "wallet_coins")
  }

  @discardableResult
  func spendCoins(_ amount: Int) -> Bool {
    guard amount > 0, coins >= amount else { return false }
    coins -= amount
    keychainService.setInt(coins, for: "wallet_coins")
    return true
  }

  func setCoins(_ amount: Int) {
    coins = max(0, amount)
    keychainService.setInt(coins, for: "wallet_coins")
  }
}

// MARK: - Example 6: Feature Flags

/// Feature flag storage with remote config support.
///
/// Usage:
/// ```swift
/// let flags = FeatureFlags()
/// if flags.isNewUIEnabled {
///     // Show new UI
/// }
/// ```
///     // Show new UI
/// }
/// ```
final class FeatureFlags: LocalStorageService {

  @UserDefaultsWrapper(key: "feature_new_ui", defaultValue: false)
  var isNewUIEnabled: Bool

  @UserDefaultsWrapper(key: "feature_dark_mode", defaultValue: true)
  var isDarkModeAvailable: Bool

  @UserDefaultsWrapper(key: "feature_premium", defaultValue: false)
  var isPremiumEnabled: Bool

  @UserDefaultsWrapper(key: "ab_test_group", defaultValue: "control")
  var abTestGroup: String

  /// Update flags from remote config
  func updateFromRemote(_ config: [String: Any]) {
    if let newUI = config["new_ui"] as? Bool {
      isNewUIEnabled = newUI
    }
    if let darkMode = config["dark_mode"] as? Bool {
      isDarkModeAvailable = darkMode
    }
    if let premium = config["premium"] as? Bool {
      isPremiumEnabled = premium
    }
    if let group = config["ab_group"] as? String {
      abTestGroup = group
    }
  }
}

// MARK: - Example 7: Using Services Directly

/// Example of using services directly without property wrappers.
final class DirectServiceUsage {

  private let userDefaults: UserDefaultsServiceProtocol
  private let keychain: KeychainServiceProtocol

  init(
    userDefaults: UserDefaultsServiceProtocol = UserDefaultsService.shared,
    keychain: KeychainServiceProtocol = KeychainService.shared
  ) {
    self.userDefaults = userDefaults
    self.keychain = keychain
  }

  func saveUserPreferences(_ theme: String, fontSize: Int) {
    userDefaults.setValue(theme, for: "theme")
    userDefaults.setValue(fontSize, for: "fontSize")
  }

  func loadUserPreferences() -> (theme: String, fontSize: Int) {
    let theme: String = userDefaults.getValue(for: "theme") ?? "light"
    let fontSize: Int = userDefaults.getValue(for: "fontSize") ?? 14
    return (theme, fontSize)
  }

  func saveSecureCredentials(token: String, userId: Int) {
    keychain.setString(token, for: "auth_token")
    keychain.setInt(userId, for: "user_id")
  }

  func loadSecureCredentials() -> (token: String?, userId: Int?) {
    return (
      keychain.getString(for: "auth_token"),
      keychain.getInt(for: "user_id")
    )
  }

  func clearAllData() {
    userDefaults.clearAll()
    keychain.clear()
  }
}

// MARK: - Example 8: Integration with SwiftInjected

/// Define your dependencies.
/// It's recommended to do this at app launch (e.g., in AppDelegate or App init).
func setupDependencies() {
  let dependencies = Dependencies {
    Dependency { AppSettings() }
    Dependency { AuthStorage() }
  }
  dependencies.build()
}

/// Verify usage in a View Model.
final class LoginViewModel: ObservableObject {
  @Injected var auth: AuthStorage
  @Injected var settings: AppSettings

  func login() {
    auth.accessToken = "new_token"
    settings.lastOpenDate = Date()
  }
}

/// Verify usage in a View.
struct SettingsView: View {
  @InjectedObservable var settings: AppSettings

  var body: some View {
    VStack {
      Text("Username: \(settings.userName)")
      Button("Toggle Dark Mode") {
        settings.isDarkMode.toggle()
      }
    }
  }
}
