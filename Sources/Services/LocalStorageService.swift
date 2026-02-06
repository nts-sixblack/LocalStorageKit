//
//  LocalStorageService.swift
//  LocalStorageKit
//
//  Created by LammaTech on 2025.
//

import Combine
import Foundation

/// A base class for creating storage services that automatically publish changes.
///
/// Inherit from this class to create a service that exposes `@UserDefaultsWrapper`,
/// `@CodableUserDefaultsWrapper`, or `@KeychainWrapper` properties. When these properties change,
/// the service will automatically emit `objectWillChange` events, updating any SwiftUI views observing it.
///
/// # Example
/// ```swift
/// final class AppStorage: LocalStorageService {
///     @UserDefaultsWrapper(key: "isFirstLaunch", defaultValue: true)
///     var isFirstLaunch: Bool
/// }
/// ```
open class LocalStorageService: ObservableObject {
  public init() {}
}
