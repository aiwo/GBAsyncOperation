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
    
    func testSerialGroupSubclass() {
        let expectation = XCTestExpectation()
        
        let serialGroupOperation = MySerialGroupOperation()
        serialGroupOperation.completionBlock = {
            expectation.fulfill()
        }
        
        operationQueue.addOperation(serialGroupOperation)
        
        wait(for: [expectation], timeout: 10)
    }
    
    func testSerialGroupSubclassFailing() {
        let expectation = XCTestExpectation()
        
        let serialGroupOperation = MySerialGroupOperationFailing()
        serialGroupOperation.completionBlock = {
            XCTFail()
        }
        serialGroupOperation.cancellationBlock = {
            expectation.fulfill()
        }
        
        operationQueue.addOperation(serialGroupOperation)
        
        wait(for: [expectation], timeout: 60)
    }
    
}

class MyAsyncOperation: GBAsyncOperation {
    
    var completion: () -> Void
    var shouldFail: Bool
    
    init(shouldFail: Bool = false, completion: @escaping () -> Void) {
        self.shouldFail = shouldFail
        self.completion = completion
    }
    
    override func main() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            if self.shouldFail {
                self.cancel() // No need to call finish()
            } else {
                self.completion()
                self.finish()
            }
        }
    }

}

class MySerialGroupOperation: GBSerialGroupOperation {
    
    override init() {
        let operation = MyAsyncOperation { 
            print("First MyAsyncOperation finish")
        }
        let oneMoreOperation = MyAsyncOperation { 
            print("Second MyAsyncOperation finish")
        }
        super.init(operations: [operation, oneMoreOperation])
    }
    
}

class MySerialGroupOperationFailing: GBSerialGroupOperation {
    
    override init() {
        let operation = MyAsyncOperation { 
            print("I should pass")
        }
        
        let failingOperation = MyAsyncOperation(shouldFail: true) { 
            print("MyAsyncOperation finish")
        }
        failingOperation.cancellationBlock = {
            print("I am cancelled")
        }
        
        let oneMoreOperation = MyAsyncOperation { 
            XCTFail()
        }
        oneMoreOperation.cancellationBlock = {
            print("I was forced to cancel")
        }
        
        super.init(operations: [operation, failingOperation, oneMoreOperation])
    }
    
}
