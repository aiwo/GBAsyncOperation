import XCTest
import GBAsyncOperation

class TestOperation: GBAsyncOperation {

    let expectation: XCTestExpectation

    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }

    override func main() {
        sleep(2)
        expectation.fulfill()
        finish()
    }
}

class Tests: XCTestCase {

    let operationQueue = OperationQueue()
    
    func testSubclassedOperation() {
        let expectation = XCTestExpectation(description: "Operation must finish")

        let operation = TestOperation(expectation: expectation)
        operationQueue.addOperation(operation)

        wait(for: [expectation], timeout: 5)
    }

    func testBlockOperation() {
        let expectation = XCTestExpectation(description: "Operation must finish")

        let operation = GBAsyncBlockOperation(block: {
            sleep(2)
            expectation.fulfill()
        })
        operationQueue.addOperation(operation)

        wait(for: [expectation], timeout: 5)
    }
    
}
