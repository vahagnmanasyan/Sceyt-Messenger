//
//  CDMessage+CoreDataProperties.swift
//  Sceyt Messenger
//
//  Created by Vahagn Manasyan on 10.01.25.
//
//

import Foundation
import CoreData


extension CDMessage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDMessage> {
        return NSFetchRequest<CDMessage>(entityName: "CDMessage")
    }

    @NSManaged public var body: String?
    @NSManaged public var date: Date?
    @NSManaged public var photoUrl: String?
    @NSManaged public var id: String?
    @NSManaged public var senderName: String?
    @NSManaged public var senderId: String?

}

extension CDMessage : Identifiable {

}
