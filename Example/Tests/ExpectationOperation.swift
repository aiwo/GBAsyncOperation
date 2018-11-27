//
//  ExpectationOperation.swift
//  GBAsyncOperation_Example
//
//  Created by Gennady Berezovsky on 28.11.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
import GBAsyncOperation

class ExpectationOperation: GBAsyncOperation {

    let expectation: XCTestExpectation?

    init(expectation: XCTestExpectation?) {
        self.expectation = expectation
    }

    override func main() {
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 2) {
            self.completeOperation()
        }
    }

    func completeOperation() {
        guard !isCancelled else {
            return
        }

        expectation?.fulfill()
        finish()
    }
}
