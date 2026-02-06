# LocalStorageKit

A lightweight, protocol-based Swift library for managing local storage using **UserDefaults** and **Keychain**.

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%2015+%20|%20macOS%2012+%20|%20tvOS%2015+%20|%20watchOS%208+-blue.svg)](https://developer.apple.com)
[![SPM Compatible](https://img.shields.io/badge/SPM-Compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## Features

- 🔐 **Keychain Storage** - Secure storage for sensitive data (tokens, passwords, etc.)
- 💾 **UserDefaults Storage** - Simple key-value storage for app preferences
- 🎯 **Protocol-based Design** - Easy to mock and test
- 📦 **Property Wrappers** - Clean, declarative syntax
- 🧩 **Dependency Injection** - No singletons, fully configurable
- 🔄 **Codable Support** - Store any Codable type
- 🛡️ **Type-safe** - Compile-time type checking

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/nts-sixblack/LocalStorageKit.git", from: "1.0.0")
]
```

Or add via Xcode:
1. File → Add Package Dependencies
2. Enter: `https://github.com/nts-sixblack/LocalStorageKit.git`

## Quick Start

### 1. Define Your Storage Keys

```swift
import LocalStorageKit

// UserDefaults keys
enum UserDefaultsKeys {
    static let isFirstLaunch = "isFirstLaunch"
    static let userName = "userName"
    static let appTheme = "appTheme"
}

// Keychain keys
enum KeychainKeys {
    static let authToken = "authToken"
    static let isPremiumUser = "isPremiumUser"
}
```

### 2. Create Your Storage Service
    
Inherit from `LocalStorageService` to get automatic `ObservableObject` support (UI updates).

```swift
import LocalStorageKit

final class AppStorageService: LocalStorageService {
    
    // MARK: - UserDefaults Properties
    
    @UserDefaultsWrapper(key: UserDefaultsKeys.isFirstLaunch, defaultValue: true)
    var isFirstLaunch: Bool
    
    @UserDefaultsWrapper(key: UserDefaultsKeys.userName, defaultValue: "")
    var userName: String
    
    @CodableUserDefaultsWrapper(key: UserDefaultsKeys.appTheme, defaultValue: .light)
    var appTheme: AppTheme
    
    // MARK: - Keychain Properties
    
    @KeychainWrapper(key: KeychainKeys.authToken, defaultValue: "")
    var authToken: String
    
    @KeychainWrapper(key: KeychainKeys.isPremiumUser, defaultValue: false)
    var isPremiumUser: Bool
    
    // Required override to prevent actor isolation mismatch
    nonisolated override init() {
        super.init()
    }
}

enum AppTheme: String, Codable {
    case light, dark, system
}
```

### 3. Use in Your App

```swift
import SwiftUI
import LocalStorageKit

@main
struct MyApp: App {
    @StateObject private var storage = AppStorageService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(storage)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var storage: AppStorageService
    
    var body: some View {
        VStack {
            if storage.isFirstLaunch {
                OnboardingView()
            } else {
                HomeView()
            }
        }
        .onAppear {
            if storage.isFirstLaunch {
                storage.isFirstLaunch = false
            }
        }
    }
}
```

## API Reference

### Property Wrappers

#### `@UserDefaultsWrapper`
For storing primitive types in UserDefaults.

```swift
@UserDefaultsWrapper(key: "myKey", defaultValue: 0)
var myValue: Int

@UserDefaultsWrapper(key: "myString", defaultValue: "default")
var myString: String

@UserDefaultsWrapper(key: "myBool", defaultValue: false)
var myBool: Bool
```

#### `@CodableUserDefaultsWrapper`
For storing Codable types in UserDefaults.

```swift
struct UserSettings: Codable {
    var fontSize: Int
    var theme: String
}

@CodableUserDefaultsWrapper(key: "settings", defaultValue: UserSettings(fontSize: 14, theme: "light"))
var settings: UserSettings
```

#### `@KeychainWrapper`
For storing sensitive data in Keychain.

```swift
@KeychainWrapper(key: "accessToken", defaultValue: "")
var accessToken: String

@KeychainWrapper(key: "userId", defaultValue: 0)
var userId: Int
```

#### `@CodableKeychainWrapper`
For storing Codable types securely in Keychain.

```swift
struct UserCredentials: Codable {
    var token: String
    var expiry: Date
}

@CodableKeychainWrapper(key: "credentials", defaultValue: nil)
var credentials: UserCredentials?
```

### Protocols

#### `UserDefaultsServiceProtocol`
Protocol for UserDefaults operations.

```swift
protocol UserDefaultsServiceProtocol {
    func getValue<T>(for key: String) -> T?
    func setValue<T>(_ value: T?, for key: String)
    func removeValue(for key: String)
    func getCodable<T: Codable>(for key: String, type: T.Type) -> T?
    func setCodable<T: Codable>(_ value: T?, for key: String)
}
```

#### `KeychainServiceProtocol`
Protocol for Keychain operations.

```swift
protocol KeychainServiceProtocol {
    var keychain: Keychain { get }
    func getString(for key: String) -> String?
    func setString(_ value: String?, for key: String)
    func getData(for key: String) -> Data?
    func setData(_ value: Data?, for key: String)
    func remove(key: String)
    func clear()
}
```

### Services

#### `UserDefaultsService`
Default implementation for UserDefaults storage.

```swift
let service = UserDefaultsService()
// or with custom UserDefaults
let service = UserDefaultsService(userDefaults: UserDefaults(suiteName: "group.myapp")!)
```

#### `KeychainService`
Default implementation for Keychain storage.

```swift
let service = KeychainService.shared
// or with custom configuration
let service = KeychainService(service: "com.myapp.keychain", accessGroup: "group.myapp")
```

## Advanced Usage

### Custom UserDefaults Suite

```swift
let appGroupDefaults = UserDefaults(suiteName: "group.com.myapp")!
let service = UserDefaultsService(userDefaults: appGroupDefaults)
```

### Keychain with Access Group (for App Extensions)

```swift
let keychainService = KeychainService(
    service: Bundle.main.bundleIdentifier ?? "com.myapp",
    accessGroup: "group.com.myapp.shared"
)
```

### Observable Storage (SwiftUI)

```swift
final class ObservableStorage: ObservableObject {
    private let keychainService: KeychainServiceProtocol
    
    @Published var coins: Int = 0 {
        didSet {
            keychainService.setInt(coins, for: "coins")
        }
    }
    
    init(keychainService: KeychainServiceProtocol = KeychainService.shared) {
        self.keychainService = keychainService
        self.coins = keychainService.getInt(for: "coins") ?? 0
    }
}

### Integration with SwiftInjected

You can easily use `LocalStorageKit` with `SwiftInjected` for dependency injection.

1. Define dependencies:
```swift
import SwiftInjected

func setupDependencies() {
    let dependencies = Dependencies {
        Dependency { AppStorageService() }
    }
    dependencies.build()
}
```

2. Inject into `ObservableObject`:
```swift
final class HomeViewModel: ObservableObject {
    @Injected var storage: AppStorageService
    
    func updateTheme() {
        storage.appTheme = .dark
    }
}
```

### Integration with SwiftInjected

You can easily use `LocalStorageKit` with `SwiftInjected` for dependency injection.

1. Define dependencies:
```swift
import SwiftInjected

func setupDependencies() {
    let dependencies = Dependencies {
        Dependency { AppStorageService() }
    }
    dependencies.build()
}
```

2. Inject into `ObservableObject`:
```swift
final class HomeViewModel: ObservableObject {
    @Injected var storage: AppStorageService
    
    func updateTheme() {
        storage.appTheme = .dark
    }
}
```

3. Inject into `View`:
```swift
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
```

```

### Testing with Mock

```swift
import XCTest
@testable import LocalStorageKit

final class MyTests: XCTestCase {
    
    func testUserStorage() {
        let mockDefaults = MockUserDefaultsService()
        mockDefaults.storage["userName"] = "Test User"
        
        let storage = AppStorageService(userDefaults: mockDefaults)
        XCTAssertEqual(storage.userName, "Test User")
    }
}

class MockUserDefaultsService: UserDefaultsServiceProtocol {
    var storage: [String: Any] = [:]
    
    func getValue<T>(for key: String) -> T? {
        storage[key] as? T
    }
    
    func setValue<T>(_ value: T?, for key: String) {
        storage[key] = value
    }
    
    func removeValue(for key: String) {
        storage.removeValue(forKey: key)
    }
    
    // ... other protocol methods
}
```

## Migration Guide

### From Direct UserDefaults Usage

**Before:**
```swift
// Old code
UserDefaults.standard.set("John", forKey: "userName")
let name = UserDefaults.standard.string(forKey: "userName")
```

**After:**
```swift
// New code with LocalStorageKit
@UserDefaultsWrapper(key: "userName", defaultValue: "")
var userName: String

// Usage
userName = "John"
print(userName) // "John"
```

### From @AppStorage

**Before:**
```swift
@AppStorage("isDarkMode") var isDarkMode = false
```

**After:**
```swift
@UserDefaultsWrapper(key: "isDarkMode", defaultValue: false)
var isDarkMode: Bool
```

## Thread Safety

- `UserDefaultsService` uses `UserDefaults.standard` which is thread-safe
- `KeychainService` uses KeychainAccess which handles thread safety internally
- Property wrappers are designed for main-thread usage in SwiftUI

## Requirements

- iOS 15.0+ / macOS 12.0+ / tvOS 15.0+ / watchOS 8.0+
- Swift 5.9+
- Xcode 15.0+

## Dependencies

- [KeychainAccess](https://github.com/kishikawakatsumi/KeychainAccess)
- [SwiftInjected](https://github.com/nts-sixblack/SwiftInjected)

## License

LocalStorageKit is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

## Author

SixBlack © 2026
