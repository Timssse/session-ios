// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import Foundation

extension Data{
    var hexEncoded: String {
        return self.hex().add0x
    }
    
    func hex(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
    
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }
}
