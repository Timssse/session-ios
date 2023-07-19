// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import Foundation

protocol EMJSONProtocol {
    func jsonToData(json:Any) -> Data?
}

extension EMJSONProtocol{
    func jsonToData(json:Any) -> Data?{
        if (!JSONSerialization.isValidJSONObject(json)){
            return nil
        }
        let data = try? JSONSerialization.data(withJSONObject: json)
        return data
    }
}
