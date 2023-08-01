import CryptoSwift

/// Based on [mnemonic.js](https://github.com/loki-project/loki-messenger/blob/development/libloki/modules/mnemonic.js) .
public enum Mnemonic {
    
    public struct Language : Hashable {
        fileprivate let filename: String
        fileprivate let prefixLength: UInt
        
        public static let english = Language(filename: "english", prefixLength: 0)
        public static let old = Language(filename: "english_old", prefixLength: 3)
//        public static let portuguese = Language(filename: "portuguese", prefixLength: 4)
//        public static let spanish = Language(filename: "spanish", prefixLength: 4)
        
        private static var wordSetCache: [Language:[String]] = [:]
        private static var truncatedWordSetCache: [Language:[String]] = [:]
        
        private init(filename: String, prefixLength: UInt) {
            self.filename = filename
            self.prefixLength = prefixLength
        }
        
        fileprivate func loadWordSet() -> [String] {
            if let cachedResult = Language.wordSetCache[self] {
                return cachedResult
            } else {
                let url = Bundle.main.url(forResource: filename, withExtension: "txt")!
                let contents = try! String(contentsOf: url)
                let result = contents.split(separator: ",").map { String($0) }
                Language.wordSetCache[self] = result
                return result
            }
        }
        
        fileprivate func loadTruncatedWordSet() -> [String] {
            if let cachedResult = Language.truncatedWordSetCache[self] {
                return cachedResult
            } else {
                let result = loadWordSet().map { $0.prefix(length: prefixLength) }
                Language.truncatedWordSetCache[self] = result
                return result
            }
        }
    }
    
    public enum DecodingError : LocalizedError {
        case generic, inputTooShort, missingLastWord, invalidWord, verificationFailed
        
        public var errorDescription: String? {
            switch self {
                case .generic: return "RECOVERY_PHASE_ERROR_GENERIC".localized()
                case .inputTooShort: return "RECOVERY_PHASE_ERROR_LENGTH".localized()
                case .missingLastWord: return "RECOVERY_PHASE_ERROR_LAST_WORD".localized()
                case .invalidWord: return "RECOVERY_PHASE_ERROR_INVALID_WORD".localized()
                case .verificationFailed: return "RECOVERY_PHASE_ERROR_FAILED".localized()
            }
        }
    }
    
//    public static func hash(hexEncodedString string: String, language: Language = .english) -> String {
//        return encode(hexEncodedString: string).split(separator: " ")[0..<3].joined(separator: " ")
//    }
    
//    public static func encode(hexEncodedString string: String, language: Language = .english) -> String {
//        var string = string
//        let wordSet = language.loadWordSet()
//        var result: [String] = []
//        let n = wordSet.count
//        let characterCount = string.indices.count // Safe for this particular case
//        for chunkStartIndexAsInt in stride(from: 0, to: characterCount, by: 8) {
//            let chunkStartIndex = string.index(string.startIndex, offsetBy: chunkStartIndexAsInt)
//            let chunkEndIndex = string.index(chunkStartIndex, offsetBy: 8)
//            let p1 = string[string.startIndex..<chunkStartIndex]
//            let p2 = swap(String(string[chunkStartIndex..<chunkEndIndex]))
//            let p3 = string[chunkEndIndex..<string.endIndex]
//            string = String(p1 + p2 + p3)
//        }
//        for chunkStartIndexAsInt in stride(from: 0, to: characterCount, by: 8) {
//            let chunkStartIndex = string.index(string.startIndex, offsetBy: chunkStartIndexAsInt)
//            let chunkEndIndex = string.index(chunkStartIndex, offsetBy: 8)
//            let x = Int(string[chunkStartIndex..<chunkEndIndex], radix: 16)!
//            let w1 = x % n
//            let w2 = ((x / n) + w1) % n
//            let w3 = (((x / n) / n) + w2) % n
//            result += [ wordSet[w1], wordSet[w2], wordSet[w3] ]
//        }
//        return result.joined(separator: " ")
//    }
    
    public static func encode(entropy : Data, language: Language = .english) -> String {
        guard entropy.count >= 16, entropy.count & 4 == 0 else {return ""}
        let checksum = entropy.sha256()
        let checksumBits = entropy.count*8/32
        var fullEntropy = Data()
        fullEntropy.append(entropy)
        fullEntropy.append(checksum[0 ..< (checksumBits+7)/8 ])
        var wordList = [String]()
        let wordSet = language.loadWordSet()
        for i in 0 ..< fullEntropy.count*8/11 {
            guard let bits = fullEntropy.bitsInRange(i*11, 11) else {return ""}
            let index = Int(bits)
            guard wordSet.count > index else {return ""}
            let word = wordSet[index]
            wordList.append(word)
        }
        return wordList.joined(separator: " ")
    }
    
    public static func decode(mnemonic: String, language: Language = .english) throws -> String {
        var words = mnemonic.split(separator: " ").map { String($0) }
        let truncatedWordSet = language.loadWordSet()
        let prefixLength = language.prefixLength
        var result = ""
        let n = truncatedWordSet.count
        // Check preconditions
        if words.count == 13{
            SNLog("=========2222225")
            return try oldDecode(mnemonic: mnemonic)
        }
        var bitString = ""
        for word in words {
//            let idx = language.words.index(of: word)
            let idx = truncatedWordSet.firstIndex(of: word)
            if (idx == nil) {
                
                SNLog("=========1111111\(word)")
                throw DecodingError.invalidWord
            }
            let idxAsInt = truncatedWordSet.startIndex.distance(to: idx!)
            let stringForm = String(UInt16(idxAsInt), radix: 2).leftPadding(toLength: 11, withPad: "0")
            bitString.append(stringForm)
        }
        let stringCount = bitString.count
        if !stringCount.isMultiple(of: 33) {
            SNLog("=========2222222")
            throw DecodingError.invalidWord
        }
        let entropyBits = bitString[0 ..< (bitString.count - bitString.count/33)]
        let checksumBits = bitString[(bitString.count - bitString.count/33) ..< bitString.count]
        guard let entropy = entropyBits.interpretAsBinaryData() else {
            SNLog("=========22222223")
            throw DecodingError.invalidWord
        }
        let checksum = String(entropy.sha256().bitsInRange(0, checksumBits.count)!, radix: 2).leftPadding(toLength: checksumBits.count, withPad: "0")
        SNLog("=========checksumBits==\(checksumBits)")
        SNLog("=========checksum==\(checksum)")
        if checksum != checksumBits {
            SNLog("=========22222224")
            throw DecodingError.invalidWord
        }
        return entropy.toHexString()
    }
    
    public static func oldDecode(mnemonic: String, language: Language = .old) throws -> String {
        var words = mnemonic.split(separator: " ").map { String($0) }
        let truncatedWordSet = language.loadTruncatedWordSet()
        let prefixLength = language.prefixLength
        var result = ""
        let n = truncatedWordSet.count
        // Check preconditions
        guard words.count >= 12 else { throw DecodingError.inputTooShort }
        guard !words.count.isMultiple(of: 3) else { throw DecodingError.missingLastWord }
        // Get checksum word
        let checksumWord = words.popLast()!
        // Decode
        for chunkStartIndex in stride(from: 0, to: words.count, by: 3) {
            guard let w1 = truncatedWordSet.firstIndex(of: words[chunkStartIndex].prefix(length: prefixLength)),
                let w2 = truncatedWordSet.firstIndex(of: words[chunkStartIndex + 1].prefix(length: prefixLength)),
                let w3 = truncatedWordSet.firstIndex(of: words[chunkStartIndex + 2].prefix(length: prefixLength)) else { throw DecodingError.invalidWord }
            let x = w1 + n * ((n - w1 + w2) % n) + n * n * ((n - w2 + w3) % n)
            guard x % n == w1 else { throw DecodingError.generic }
            let string = "0000000" + String(x, radix: 16)
            result += swap(String(string[string.index(string.endIndex, offsetBy: -8)..<string.endIndex]))
        }
        // Verify checksum
        let checksumIndex = determineChecksumIndex(for: words, prefixLength: prefixLength)
        let expectedChecksumWord = words[checksumIndex]
        guard expectedChecksumWord.prefix(length: prefixLength) == checksumWord.prefix(length: prefixLength) else { throw DecodingError.verificationFailed }
        // Return
        return result
    }
    
    private static func swap(_ x: String) -> String {
        func toStringIndex(_ indexAsInt: Int) -> String.Index {
            return x.index(x.startIndex, offsetBy: indexAsInt)
        }
        let p1 = x[toStringIndex(6)..<toStringIndex(8)]
        let p2 = x[toStringIndex(4)..<toStringIndex(6)]
        let p3 = x[toStringIndex(2)..<toStringIndex(4)]
        let p4 = x[toStringIndex(0)..<toStringIndex(2)]
        return String(p1 + p2 + p3 + p4)
    }
    
    private static func determineChecksumIndex(for x: [String], prefixLength: UInt) -> Int {
        let checksum = Array(x.map { $0.prefix(length: prefixLength) }.joined().utf8).crc32()
        return Int(checksum) % x.count
    }
}

private extension String {
    
    func prefix(length: UInt) -> String {
        return String(self[startIndex..<index(startIndex, offsetBy: Int(length))])
    }
}

//@objc(SNMnemonic)
//public final class ObjCMnemonic : NSObject {
//    
//    override private init() { }
//    
//    @objc(hashHexEncodedString:)
//    public static func hash(hexEncodedString string: String) -> String {
//        return Mnemonic.hash(hexEncodedString: string)
//    }
//    
//    @objc(encodeHexEncodedString:)
//    public static func encode(hexEncodedString string: String) -> String {
//        return Mnemonic.encode(hexEncodedString: string)
//    }
//}
