//
//  MyChatAppApp.swift
//  MyChatApp
//
//  Created by David Owen on 5/24/23.
//

import SwiftUI
import UserNotifications
import FirebaseCore
import Firebase
import FirebaseMessaging

@main
struct MyChatAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var routerManager = NavigationRouter()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $routerManager.routes) {
                ProgressView()
                    .navigationDestination(for: Route.self) { $0 }
                    .onTapGesture(count: 5) {
                        do {
                            try FirebaseManager.shared.auth.signOut()
                            print("Signed out")
                        } catch {
                            print("error signing out")
                        }
                    }
            }
            .preferredColorScheme(.light)
            .environmentObject(routerManager)
            .task {
                if let _ = FirebaseManager.shared.auth.currentUser {
                    await FirebaseManager.getUserInformation()
                    if let user = FirebaseManager.shared.loggedInUser {
                        routerManager.push(to: .messageHome(loggedInUser: user))
                    }
                } else {
                    routerManager.push(to: .login)
                }
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    let gcmMessageIDKey = "gcm.message_id"
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        //Setting up messaging...
        Messaging.messaging().delegate = self
        
        //Setting up remote notifications
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async
    -> UIBackgroundFetchResult {
        
        // Do something with message data here
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        return UIBackgroundFetchResult.newData
    }
    
    //In order to receive messages you must implement these methods...
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
    }
}

//Cloud Messaging
extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        
        //Store token in firestore for sending notifications from server in future
        FirebaseManager.shared.fcmToken = dataDict["token"]
        print(dataDict)
        
    }
    
}

//User Notifications
extension AppDelegate: UNUserNotificationCenterDelegate {
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async
    -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo

        //Do something with msg data
        
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        print(userInfo)
        
        
        // Change this to your preferred presentation option
        return [.sound, .badge, .banner]
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        
        //Do something with msg data
        
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        
        // Print full message.
        print(userInfo)
    }
}
