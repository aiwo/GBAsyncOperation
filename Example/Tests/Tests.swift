import XCTest
import GBAsyncOperation

class Tests: XCTestCase {

    let operationQueue = OperationQueue()
    
    func testSubclassedOperation() {
        let expectation = XCTestExpectation(description: "Operation must finish")

        let operation = ExpectationOperation(expectation: expectation)
        operationQueue.addOperation(operation)

        wait(for: [expectation], timeout: 5)
    }

    func testCancelledOperation() {
        let expectation = XCTestExpectation(description: "Operation must not finish")
        expectation.isInverted = true

        let cancelationExpectation = XCTestExpectation(description: "Operation must be cancelled")

        let operation = ExpectationOperation(expectation: expectation)
        operation.cancellationBlock = {
            cancelationExpectation.fulfill()
        }
        operationQueue.addOperation(operation)

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            operation.cancel()
        }

        wait(for: [expectation, cancelationExpectation], timeout: 5)
    }

    func testCancellableDependencyOperation() {
        let expectation = XCTestExpectation(description: "Operation must not finish")
        expectation.isInverted = true

        let firstOperation = ExpectationOperation(expectation: nil)
        let secondOperation = ExpectationOperation(expectation: expectation)

        firstOperation.addCancellableDependency(operation: secondOperation)

        operationQueue.addOperation(firstOperation)
        operationQueue.addOperation(secondOperation)

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            firstOperation.cancel()
        }

        wait(for: [expectation], timeout: 5)

    }

    func testSerialGroupOperation() {
        let firstExpectation = XCTestExpectation(description: "First operation must finish")
        let secondExpectation = XCTestExpectation(description: "Second operation must finish")

        let firstOperation = ExpectationOperation(expectation: firstExpectation)
        let secondOperation = ExpectationOperation(expectation: secondExpectation)

        let serialGroupOperation = GBSerialGroupOperation(operations: [firstOperation, secondOperation])

        operationQueue.addOperation(serialGroupOperation)

        wait(for: [firstExpectation, secondExpectation], timeout: 10)
    }
    
}
