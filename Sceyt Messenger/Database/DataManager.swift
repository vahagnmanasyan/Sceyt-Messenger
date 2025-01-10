//
//  DataManager.swift
//  Sceyt Messenger
//
//  Created by Vahagn Manasyan on 10.01.25.
//

import CoreData

class DataManager {
    static let shared = DataManager()

    private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Database")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func save() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    func saveMessage(body: String?, id: String, senderName: String, senderId: String, date: Date, url: String? = nil) {
        do {
            let message = CDMessage(context: context)
            message.body = body
            message.id = id
            message.senderName = senderName
            message.senderId = senderId
            message.date = date
            message.photoUrl = url
            try context.save()
        } catch {
            print(error)
        }
    }
    
    func fetchMessages() -> [CDMessage] {
        let request: NSFetchRequest<CDMessage> = CDMessage.fetchRequest()
        var fetchedMessages: [CDMessage] = []
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        do {
            fetchedMessages = try persistentContainer.viewContext.fetch(request)
        } catch {
            print("Error fetching messages \(error)")
        }

        return fetchedMessages
    }

    func deleteMessage(message: CDMessage) {
        let context = persistentContainer.viewContext
        context.delete(message)
        save()
    }
}
