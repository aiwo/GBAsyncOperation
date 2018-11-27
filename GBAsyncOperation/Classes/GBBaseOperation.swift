//
//  GBBaseOperation.swift
//  GBAsyncOperation
//
//  Created by Gennady Berezovsky on 27.11.18.
//

import Foundation

open class GBBaseOperation: Operation {

    public var cancellationBlock: (() -> Void)?

    private let stateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! + "base.rw.state", attributes: .concurrent)

    private var cancellableDependencies = NSHashTable<GBBaseOperation>(options: [NSPointerFunctions.Options.weakMemory])

    public func addCancellableDependency(operation: GBBaseOperation) {
        addDependency(operation)
        cancellableDependencies.add(operation)
    }

    open override func cancel() {
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
