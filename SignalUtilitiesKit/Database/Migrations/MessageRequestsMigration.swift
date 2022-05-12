// Copyright © 2022 Rangeproof Pty Ltd. All rights reserved.

import Foundation
import SessionMessagingKit

@objc(SNMessageRequestsMigration)
public class MessageRequestsMigration : OWSDatabaseMigration {

    @objc
    class func migrationId() -> String {
        return "002"
    }

    override public func runUp(completion: @escaping OWSDatabaseMigrationCompletion) {
        self.doMigrationAsync(completion: completion)
    }

    private func doMigrationAsync(completion: @escaping OWSDatabaseMigrationCompletion) {
        var contacts: Set<SMKLegacy._Contact> = Set()
        var threads: [TSThread] = []

        TSThread.enumerateCollectionObjects { object, _ in
            guard let thread: TSThread = object as? TSThread else { return }
            
            Storage.read { transaction in
                if let contactThread: TSContactThread = thread as? TSContactThread {
                    let sessionId: String = contactThread.contactSessionID()
                    
                    if let contact: SMKLegacy._Contact = transaction.object(forKey: sessionId, inCollection: Legacy.contactCollection) as? SMKLegacy._Contact {
                        contact.isApproved = true
                        contact.didApproveMe = true
                        contacts.insert(contact)
                    }
                }
                else if let groupThread: TSGroupThread = thread as? TSGroupThread, groupThread.isClosedGroup {
                    let groupAdmins: [String] = groupThread.groupModel.groupAdminIds
                    
                    groupAdmins.forEach { sessionId in
                        if let contact: SMKLegacy._Contact = transaction.object(forKey: sessionId, inCollection: Legacy.contactCollection) as? SMKLegacy._Contact {
                            contact.isApproved = true
                            contact.didApproveMe = true
                            contacts.insert(contact)
                        }
                    }
                }
            }
            
            threads.append(thread)
        }
        
        let userPublicKey: String = getUserHexEncodedPublicKey()
        
        Storage.read { transaction in
            if let user = transaction.object(forKey: userPublicKey, inCollection: Legacy.contactCollection) as? SMKLegacy._Contact {
                user.isApproved = true
                user.didApproveMe = true
                contacts.insert(user)
            }
        }
        
        Storage.write(with: { transaction in
            contacts.forEach { contact in
                transaction.setObject(contact, forKey: contact.sessionID, inCollection: Legacy.contactCollection)
            }
            threads.forEach { thread in
                thread.save(with: transaction)
            }
            self.save(with: transaction) // Intentionally capture self
        }, completion: {
            completion(true, true)
        })
    }
}
