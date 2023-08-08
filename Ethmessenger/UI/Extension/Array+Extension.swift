// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import Foundation

extension Array{
    func toData() -> Data?{
        let arr = self
        return (try?JSONSerialization.data(withJSONObject: arr, options: []))
    }
}
