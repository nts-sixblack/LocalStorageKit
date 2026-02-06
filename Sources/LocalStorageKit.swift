//
//  LocalStorageKit.swift
//  LocalStorageKit
//
//  Created by LammaTech on 2025.
//

/// LocalStorageKit - A lightweight library for local storage management
///
/// # Overview
/// LocalStorageKit provides easy-to-use property wrappers and services for
/// storing data in UserDefaults and Keychain.
///
/// # Quick Start
/// ```swift
/// import LocalStorageKit
///
/// class MyStorage {
///     @UserDefaultsWrapper(key: "username", defaultValue: "")
///     var username: String
///
///     @KeychainWrapper(key: "token", defaultValue: "")
///     var authToken: String
/// }
/// ```

// MARK: - Public Exports

// Protocols
@_exported import Foundation
// Re-export KeychainAccess for convenience
@_exported import KeychainAccess
