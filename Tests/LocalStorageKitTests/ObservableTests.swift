
import XCTest
import Combine
@testable import LocalStorageKit

final class ObservableTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()

    func testUserDefaultsWrapperObservable() {
        let service = TestUserDefaultsService()
        let expectation = XCTestExpectation(description: "Service should emit change for UserDefaultsWrapper")

        service.objectWillChange
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        service.count += 1
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testCodableWrapperObservable() {
        let service = TestCodableService()
        let expectation = XCTestExpectation(description: "Service should emit change for CodableWrapper")
        
        service.objectWillChange
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
            
        service.user = User(name: "Updated")
        
        wait(for: [expectation], timeout: 1.0)
    }
}

// MARK: - Test Services

final class TestUserDefaultsService: LocalStorageService {
    @UserDefaultsWrapper(key: "test_observable_count", defaultValue: 0)
    var count: Int
}

struct User: Codable, Equatable {
    var name: String
}

final class TestCodableService: LocalStorageService {
    @CodableUserDefaultsWrapper(key: "test_observable_user", defaultValue: User(name: "Test"))
    var user: User
}
