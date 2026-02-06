//
//  LocalStorageKitTests.swift
//  LocalStorageKitTests
//
//  Created by LammaTech on 2025.
//

import XCTest

@testable import LocalStorageKit

final class LocalStorageKitTests: XCTestCase {

  // MARK: - UserDefaults Tests

  func testUserDefaultsWrapper_setAndGet() {
    // Given
    let defaults = UserDefaults(suiteName: "test.userdefaults")!
    defer { defaults.removePersistentDomain(forName: "test.userdefaults") }

    // When
    defaults.set("TestValue", forKey: "testKey")

    // Then
    XCTAssertEqual(defaults.string(forKey: "testKey"), "TestValue")
  }

  func testUserDefaultsService_setAndGetValue() {
    // Given
    let defaults = UserDefaults(suiteName: "test.service")!
    let service = UserDefaultsService(userDefaults: defaults)
    defer { defaults.removePersistentDomain(forName: "test.service") }

    // When
    service.setValue("Hello", for: "greeting")

    // Then
    let value: String? = service.getValue(for: "greeting")
    XCTAssertEqual(value, "Hello")
  }

  func testUserDefaultsService_codableValue() {
    // Given
    struct TestModel: Codable, Equatable {
      let name: String
      let age: Int
    }

    let defaults = UserDefaults(suiteName: "test.codable")!
    let service = UserDefaultsService(userDefaults: defaults)
    defer { defaults.removePersistentDomain(forName: "test.codable") }

    let model = TestModel(name: "John", age: 30)

    // When
    service.setCodable(model, for: "user")

    // Then
    let retrieved = service.getCodable(for: "user", type: TestModel.self)
    XCTAssertEqual(retrieved, model)
  }

  func testUserDefaultsService_removeValue() {
    // Given
    let defaults = UserDefaults(suiteName: "test.remove")!
    let service = UserDefaultsService(userDefaults: defaults)
    defer { defaults.removePersistentDomain(forName: "test.remove") }

    service.setValue("ToBeRemoved", for: "key")

    // When
    service.removeValue(for: "key")

    // Then
    let value: String? = service.getValue(for: "key")
    XCTAssertNil(value)
  }

  func testUserDefaultsService_hasValue() {
    // Given
    let defaults = UserDefaults(suiteName: "test.hasvalue")!
    let service = UserDefaultsService(userDefaults: defaults)
    defer { defaults.removePersistentDomain(forName: "test.hasvalue") }

    // When
    service.setValue("Exists", for: "existing")

    // Then
    XCTAssertTrue(service.hasValue(for: "existing"))
    XCTAssertFalse(service.hasValue(for: "nonexisting"))
  }

  // MARK: - Keychain Tests

  func testKeychainService_setAndGetString() {
    // Given
    let service = KeychainService(service: "test.keychain.string")
    defer { service.clear() }

    // When
    service.setString("SecretToken", for: "token")

    // Then
    XCTAssertEqual(service.getString(for: "token"), "SecretToken")
  }

  func testKeychainService_setAndGetInt() {
    // Given
    let service = KeychainService(service: "test.keychain.int")
    defer { service.clear() }

    // When
    service.setInt(42, for: "count")

    // Then
    XCTAssertEqual(service.getInt(for: "count"), 42)
  }

  func testKeychainService_setAndGetBool() {
    // Given
    let service = KeychainService(service: "test.keychain.bool")
    defer { service.clear() }

    // When
    service.setBool(true, for: "isPremium")

    // Then
    XCTAssertEqual(service.getBool(for: "isPremium"), true)
  }

  func testKeychainService_setAndGetCodable() {
    // Given
    struct SecureData: Codable, Equatable {
      let id: String
      let secret: String
    }

    let service = KeychainService(service: "test.keychain.codable")
    defer { service.clear() }

    let data = SecureData(id: "user123", secret: "s3cr3t")

    // When
    service.setCodable(data, for: "secureData")

    // Then
    let retrieved = service.getCodable(for: "secureData", type: SecureData.self)
    XCTAssertEqual(retrieved, data)
  }

  func testKeychainService_remove() {
    // Given
    let service = KeychainService(service: "test.keychain.remove")
    defer { service.clear() }

    service.setString("ToBeRemoved", for: "key")

    // When
    service.remove(key: "key")

    // Then
    XCTAssertNil(service.getString(for: "key"))
  }

  func testKeychainService_clear() {
    // Given
    let service = KeychainService(service: "test.keychain.clear")

    service.setString("Value1", for: "key1")
    service.setString("Value2", for: "key2")

    // When
    service.clear()

    // Then
    XCTAssertNil(service.getString(for: "key1"))
    XCTAssertNil(service.getString(for: "key2"))
  }

  func testKeychainService_hasValue() {
    // Given
    let service = KeychainService(service: "test.keychain.hasvalue")
    defer { service.clear() }

    // When
    service.setString("Exists", for: "existing")

    // Then
    XCTAssertTrue(service.hasValue(for: "existing"))
    XCTAssertFalse(service.hasValue(for: "nonexisting"))
  }
}

// MARK: - Mock Tests

final class MockUserDefaultsServiceTests: XCTestCase {

  func testMockUserDefaultsService() {
    // Given
    let mock = MockUserDefaultsService()

    // When
    mock.setValue("Test", for: "key")

    // Then
    let value: String? = mock.getValue(for: "key")
    XCTAssertEqual(value, "Test")
  }
}

// MARK: - Mock Implementation for Testing

class MockUserDefaultsService: UserDefaultsServiceProtocol {
  var storage: [String: Any] = [:]

  func getValue<T>(for key: String) -> T? {
    return storage[key] as? T
  }

  func setValue<T>(_ value: T?, for key: String) {
    if let value = value {
      storage[key] = value
    } else {
      storage.removeValue(forKey: key)
    }
  }

  func removeValue(for key: String) {
    storage.removeValue(forKey: key)
  }

  func getCodable<T: Codable>(for key: String, type: T.Type) -> T? {
    guard let data = storage[key] as? Data else { return nil }
    return try? JSONDecoder().decode(type, from: data)
  }

  func setCodable<T: Codable>(_ value: T?, for key: String) {
    guard let value = value else {
      storage.removeValue(forKey: key)
      return
    }
    guard let data = try? JSONEncoder().encode(value) else { return }
    storage[key] = data
  }

  func hasValue(for key: String) -> Bool {
    return storage[key] != nil
  }

  func clearAll() {
    storage.removeAll()
  }
}
