// Copyright © 2022 Rangeproof Pty Ltd. All rights reserved.

import Foundation
import GRDB
import DifferenceKit
import SignalUtilitiesKit

public class MessageRequestsViewModel {
    /// This value is the current state of the view
    public private(set) var viewData: [SessionThreadViewModel] = []
    
    /// This is all the data the screen needs to populate itself, please see the following link for tips to help optimise
    /// performance https://github.com/groue/GRDB.swift#valueobservation-performance
    ///
    /// **Note:** The 'trackingConstantRegion' is optimised in such a way that the request needs to be static
    /// otherwise there may be situations where it doesn't get updates, this means we can't have conditional queries
    public lazy var observableViewData = ValueObservation
        .trackingConstantRegion { db -> [SessionThreadViewModel] in
            let userPublicKey: String = getUserHexEncodedPublicKey(db)
            
            return try SessionThreadViewModel
                .messageRequestsQuery(userPublicKey: userPublicKey)
                .fetchAll(db)
        }
        .removeDuplicates()
    
    // MARK: - Functions
    
    public func updateData(_ updatedData: [SessionThreadViewModel]) {
        self.viewData = updatedData
    }
}
