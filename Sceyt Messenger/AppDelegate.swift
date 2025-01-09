//
//  AppDelegate.swift
//  Sceyt Messenger
//
//  Created by Vahagn Manasyan on 06.01.25.
//

import UIKit

let mockMessage = "Lorem ipsum odor amet, consectetuer adipiscing elit. Consectetur tincidunt fermentum at himenaeos dictumst? Massa auctor lobortis curae taciti amet commodo, vulputate praesent lorem. Gravida nisl dapibus gravida mus penatibus eros. Condimentum elementum torquent lobortis quis pretium ultricies ad. Pellentesque leo nam nisi elementum neque massa vulputate mus taciti. Bibendum felis mollis; ridiculus nascetur dapibus est ipsum molestie."

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Create a mock userId once to initiate the logged-in user
        if UserDefaults.standard.value(forKey: "userId") == nil {
            UserDefaults.standard.set(UUID().uuidString, forKey: "userId")
        }
        
        if UserDefaults.standard.value(forKey: "isMockDataGenerated") == nil {
            UserDefaults.standard.set(true, forKey: "isMockDataGenerated")
            
            for _ in 0..<2000 {
                let randomId = (1000...10000).randomElement()!
                DataManager.shared.saveMessage(
                    body: mockMessage,
                    id: UUID().uuidString,
                    senderName: "User\(randomId)",
                    senderId: UUID().uuidString,
                    date: Date()
                )
            }
            
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
