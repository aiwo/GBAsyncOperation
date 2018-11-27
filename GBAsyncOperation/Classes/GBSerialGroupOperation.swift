//
//  GBSerialGroupOperation.swift
//  GBAsyncOperation
//
//  Created by Gennady Berezovsky on 27.11.18.
//

import Foundation

open class GBSerialGroupOperation: GBAsyncOperation {

    let internalQueue = OperationQueue()

    public init(operations: [GBBaseOperation]) {
        internalQueue.isSuspended = true

        super.init()

        operations.forEach({ self.addOperation(operation: $0) })
    }

    public func addOperation(operation: GBBaseOperation) {
        guard !isExecuting, !isCancelled else {
            assertionFailure("You cannot add operations to already running or cancelled group")
            return
        }

        if !internalQueue.operations.isEmpty {
            guard let lastOperation = internalQueue.operations.last as? GBBaseOperation else {
                assertionFailure("Only `GBBaseOperation` instances are allowed to be running in the internal queue")
                return
            }
            operation.addCancellableDependency(operation: lastOperation)
        }

        internalQueue.addOperation(operation)
    }

    open override func start() {
        guard !isCancelled else {
            return
        }

        let completionOperation = GBBlockOperation {
            self.finish()
        }
        completionOperation.cancellationBlock = {
            self.cancel()
        }
        addOperation(operation: completionOperation)

        super.start()
    }

    open override func main() {
        guard !isCancelled else {
            return
        }

        internalQueue.isSuspended = false
    }

    open override func cancel() {
        internalQueue.cancelAllOperations()
        super.cancel()
    }
}
