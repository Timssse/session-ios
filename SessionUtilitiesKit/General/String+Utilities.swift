// Copyright © 2022 Rangeproof Pty Ltd. All rights reserved.

import SignalCoreKit

public extension String {
    var glyphCount: Int {
        let richText = NSAttributedString(string: self)
        let line = CTLineCreateWithAttributedString(richText)
        
        return CTLineGetGlyphCount(line)
    }
    
    var isSingleAlphabet: Bool {
        return (glyphCount == 1 && isAlphabetic)
    }
    
    var isAlphabetic: Bool {
        return !isEmpty && range(of: "[^a-zA-Z]", options: .regularExpression) == nil
    }

    var isSingleEmoji: Bool {
        return (glyphCount == 1 && containsEmoji)
    }

    var containsEmoji: Bool {
        return unicodeScalars.contains { $0.isEmoji }
    }

    var containsOnlyEmoji: Bool {
        return (
            !isEmpty &&
            !unicodeScalars.contains(where: {
                !$0.isEmoji &&
                !$0.isZeroWidthJoiner
            })
        )
    }
    
    func localized() -> String {
//        // If the localized string matches the key provided then the localisation failed
//        let localizedString = NSLocalizedString(self, comment: "")
//        owsAssertDebug(localizedString != self, "Key \"\(self)\" is not set in Localizable.strings")
//
//        return localizedString
        return EMLocalizationTool.shared.valueWithKey(key: self)
    }
    
    func ranges(of substring: String, options: CompareOptions = [], locale: Locale? = nil) -> [Range<Index>] {
        var ranges: [Range<Index>] = []
        
        while
            (ranges.last.map({ $0.upperBound < self.endIndex }) ?? true),
            let range = self.range(
                of: substring,
                options: options,
                range: (ranges.last?.upperBound ?? self.startIndex)..<self.endIndex,
                locale: locale
            )
        {
            ranges.append(range)
        }
        
        return ranges
    }
    
    static func filterNotificationText(_ text: String?) -> String? {
        guard let text = text?.filterStringForDisplay() else { return nil }

        // iOS strips anything that looks like a printf formatting character from
        // the notification body, so if we want to dispay a literal "%" in a notification
        // it must be escaped.
        // see https://developer.apple.com/documentation/uikit/uilocalnotification/1616646-alertbody
        // for more details.
        return text.replacingOccurrences(of: "%", with: "%%")
    }
}

// MARK: - Formatting

public extension String {
    static func formattedDuration(_ duration: TimeInterval, format: TimeInterval.DurationFormat = .short) -> String {
        let secondsPerMinute: TimeInterval = 60
        let secondsPerHour: TimeInterval = (secondsPerMinute * 60)
        let secondsPerDay: TimeInterval = (secondsPerHour * 24)
        let secondsPerWeek: TimeInterval = (secondsPerDay * 7)
        
        switch format {
            case .videoDuration:
                let seconds: Int = Int(duration.truncatingRemainder(dividingBy: 60))
                let minutes: Int = Int((duration / 60).truncatingRemainder(dividingBy: 60))
                let hours: Int = Int(duration / 3600)
                
                guard hours > 0 else { return String(format: "%02ld:%02ld", minutes, seconds) }
                
                return String(format: "%ld:%02ld:%02ld", hours, minutes, seconds)
            
            case .hoursMinutesSeconds:
                let seconds: Int = Int(duration.truncatingRemainder(dividingBy: 60))
                let minutes: Int = Int((duration / 60).truncatingRemainder(dividingBy: 60))
                let hours: Int = Int(duration / 3600)
                
                guard hours > 0 else { return String(format: "%ld:%02ld", minutes, seconds) }
                
                return String(format: "%ld:%02ld:%02ld", hours, minutes, seconds)
                
            case .short:
                switch duration {
                    case 0..<secondsPerMinute:  // Seconds
                        return String(
                            format: "TIME_AMOUNT_SECONDS_SHORT_FORMAT".localized(),
                            NumberFormatter.localizedString(
                                from: NSNumber(floatLiteral: floor(duration)),
                                number: .none
                            )
                        )
                    
                    case secondsPerMinute..<secondsPerHour:   // Minutes
                        return String(
                            format: "TIME_AMOUNT_MINUTES_SHORT_FORMAT".localized(),
                            NumberFormatter.localizedString(
                                from: NSNumber(floatLiteral: floor(duration / secondsPerMinute)),
                                number: .none
                            )
                        )
                        
                    case secondsPerHour..<secondsPerDay:   // Hours
                        return String(
                            format: "TIME_AMOUNT_HOURS_SHORT_FORMAT".localized(),
                            NumberFormatter.localizedString(
                                from: NSNumber(floatLiteral: floor(duration / secondsPerHour)),
                                number: .none
                            )
                        )
                        
                    case secondsPerDay..<secondsPerWeek:   // Days
                        return String(
                            format: "TIME_AMOUNT_DAYS_SHORT_FORMAT".localized(),
                            NumberFormatter.localizedString(
                                from: NSNumber(floatLiteral: floor(duration / secondsPerDay)),
                                number: .none
                            )
                        )
                        
                    default:   // Weeks
                        return String(
                            format: "TIME_AMOUNT_WEEKS_SHORT_FORMAT".localized(),
                            NumberFormatter.localizedString(
                                from: NSNumber(floatLiteral: floor(duration / secondsPerWeek)),
                                number: .none
                            )
                        )
                }
                
            case .long:
                switch duration {
                    case 0..<secondsPerMinute:  // XX Seconds
                        return String(
                            format: "TIME_AMOUNT_SECONDS".localized(),
                            NumberFormatter.localizedString(
                                from: NSNumber(floatLiteral: floor(duration)),
                                number: .none
                            )
                        )
                    
                    case secondsPerMinute..<(secondsPerMinute * 1.5):   // 1 Minute
                        return String(
                            format: "TIME_AMOUNT_SINGLE_MINUTE".localized(),
                            NumberFormatter.localizedString(
                                from: NSNumber(floatLiteral: floor(duration / secondsPerMinute)),
                                number: .none
                            )
                        )
                        
                    case (secondsPerMinute * 1.5)..<secondsPerHour:   // Multiple Minutes
                        return String(
                            format: "TIME_AMOUNT_MINUTES".localized(),
                            NumberFormatter.localizedString(
                                from: NSNumber(floatLiteral: floor(duration / secondsPerMinute)),
                                number: .none
                            )
                        )
                        
                    case secondsPerHour..<(secondsPerHour * 1.5):   // 1 Hour
                        return String(
                            format: "TIME_AMOUNT_SINGLE_HOUR".localized(),
                            NumberFormatter.localizedString(
                                from: NSNumber(floatLiteral: floor(duration / secondsPerHour)),
                                number: .none
                            )
                        )
                        
                    case (secondsPerHour * 1.5)..<secondsPerDay:   // Multiple Hours
                        return String(
                            format: "TIME_AMOUNT_HOURS".localized(),
                            NumberFormatter.localizedString(
                                from: NSNumber(floatLiteral: floor(duration / secondsPerHour)),
                                number: .none
                            )
                        )
                        
                    case secondsPerDay..<(secondsPerDay * 1.5):   // 1 Day
                        return String(
                            format: "TIME_AMOUNT_SINGLE_DAY".localized(),
                            NumberFormatter.localizedString(
                                from: NSNumber(floatLiteral: floor(duration / secondsPerDay)),
                                number: .none
                            )
                        )
                        
                    case (secondsPerDay * 1.5)..<secondsPerWeek:   // Multiple Days
                        return String(
                            format: "TIME_AMOUNT_DAYS".localized(),
                            NumberFormatter.localizedString(
                                from: NSNumber(floatLiteral: floor(duration / secondsPerDay)),
                                number: .none
                            )
                        )
                        
                    case secondsPerWeek..<(secondsPerWeek * 1.5):   // 1 Week
                        return String(
                            format: "TIME_AMOUNT_SINGLE_WEEK".localized(),
                            NumberFormatter.localizedString(
                                from: NSNumber(floatLiteral: floor(duration / secondsPerWeek)),
                                number: .none
                            )
                        )
                        
                    default:   // Multiple Weeks
                        return String(
                            format: "TIME_AMOUNT_WEEKS".localized(),
                            NumberFormatter.localizedString(
                                from: NSNumber(floatLiteral: floor(duration / secondsPerWeek)),
                                number: .none
                            )
                        )
                }
        }
    }
}

extension String {
    var fullRange: Range<Index> {
        return startIndex..<endIndex
    }
    
    var fullNSRange: NSRange {
        return NSRange(fullRange, in: self)
    }
    
    func index(of char: Character) -> Index? {
        guard let range = range(of: String(char)) else {
            return nil
        }
        return range.lowerBound
    }

    func split(intoChunksOf chunkSize: Int) -> [String] {
        var output = [String]()
        let splittedString = self
            .map { $0 }
            .split(intoChunksOf: chunkSize)
        splittedString.forEach {
            output.append($0.map { String($0) }.joined(separator: ""))
        }
        return output
    }
    
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(self.startIndex, offsetBy: bounds.lowerBound)
        let end = index(self.startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }
    
    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(self.startIndex, offsetBy: bounds.lowerBound)
        let end = index(self.startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
    
    subscript (bounds: CountablePartialRangeFrom<Int>) -> String {
        let start = index(self.startIndex, offsetBy: bounds.lowerBound)
        let end = self.endIndex
        return String(self[start..<end])
    }
    
    func leftPadding(toLength: Int, withPad character: Character) -> String {
        let stringLength = self.count
        if stringLength < toLength {
            return String(repeatElement(character, count: toLength - stringLength)) + self
        } else {
            return String(self.suffix(toLength))
        }
    }
    
    func interpretAsBinaryData() -> Data? {
        let padded = self.padding(toLength: ((self.count + 7) / 8) * 8, withPad: "0", startingAt: 0)
        let byteArray = padded.split(intoChunksOf: 8).map { UInt8(strtoul($0, nil, 2)) }
        return Data(byteArray)
    }
    
    func hasHexPrefix() -> Bool {
        return self.hasPrefix("0x")
    }
    
    func stripHexPrefix() -> String {
        if self.hasPrefix("0x") {
            let indexStart = self.index(self.startIndex, offsetBy: 2)
            return String(self[indexStart...])
        }
        return self
    }
    
    func addHexPrefix() -> String {
        if !self.hasPrefix("0x") {
            return "0x" + self
        }
        return self
    }
    
    
    func matchingStrings(regex: String) -> [[String]] {
        guard let regex = try? NSRegularExpression(pattern: regex, options: []) else { return [] }
        let nsString = self as NSString
        let results  = regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length))
        return results.map { result in
            (0..<result.numberOfRanges).map { result.range(at: $0).location != NSNotFound
                ? nsString.substring(with: result.range(at: $0))
                : ""
            }
        }
    }
    
    func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location + nsRange.length, limitedBy: utf16.endIndex),
            let from = from16.samePosition(in: self),
            let to = to16.samePosition(in: self)
            else { return nil }
        return from ..< to
    }
    
    var asciiValue: Int {
        get {
            let s = self.unicodeScalars
            return Int(s[s.startIndex].value)
        }
    }
}

extension Character {
    var asciiValue: Int {
        get {
            let s = String(self).unicodeScalars
            return Int(s[s.startIndex].value)
        }
    }
}

