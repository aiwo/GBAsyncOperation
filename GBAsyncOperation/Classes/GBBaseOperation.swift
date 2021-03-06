//
//  GBBaseOperation.swift
//  GBAsyncOperation
//
//  Created by Gennady Berezovsky on 27.11.18.
//

import Foundation

/// A class that extends Swift Operation with a block executed upon operation cancellation and a cancellation chain for dependant GBBaseOperation classes

open class GBBaseOperation: Operation {

    /// Block that is executed upon operation cancellation
    public var cancellationBlock: (() -> Void)?
    
    var isCancellationInProgress = false

    /// Queue used for synchronisation purposes
    private let stateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! + "base.rw.state", attributes: .concurrent)

    /// Collection of operations that are dependant on the successful completion
    /// of the current operation
    private var cancellableDependencies = NSHashTable<GBBaseOperation>(options: [NSPointerFunctions.Options.weakMemory])

    /**
     Adds a cancellable dependency

     - Parameter operation: The operation that will be dependant on the successful completion of the receiver.
     */
    public func addCancellableDependency(operation: GBBaseOperation) {
        addDependency(operation)
        operation.cancellableDependencies.add(self)
    }

    open override func cancel() {
        guard !isCancellationInProgress else {
            return
        }
        
        isCancellationInProgress = true
        
        stateQueue.sync(flags: .barrier) {
            for object in cancellableDependencies.objectEnumerator() {
                guard let operation = object as? Operation else {
                    return
                }
                operation.cancel()
            }
            cancellationBlock?()
            super.cancel()
        }
    }

}
