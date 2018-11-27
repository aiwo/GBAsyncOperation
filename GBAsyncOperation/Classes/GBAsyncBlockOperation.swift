//
//  GBBlockOperation.swift
//  Tangem
//
//  Created by Gennady Berezovsky on 03.10.18.
//  Copyright © 2018 Smart Cash AG. All rights reserved.
//

import Foundation

open class GBBlockOperation: GBAsyncOperation {

    let block: () -> Void

    public init(block: @escaping () -> Void) {
        self.block = block
    }

    open override func main() {
        DispatchQueue.global().async {
            self.block()
            self.finish()
        }
    }
}
