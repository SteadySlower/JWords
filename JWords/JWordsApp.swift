//
//  JWordsApp.swift
//  JWords
//
//  Created by JW Moon on 2022/06/25.
//

import SwiftUI
import ComposableArchitecture
import FirebaseCore
#if os(iOS)
import GoogleMobileAds
#endif

#if os(iOS)
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      FirebaseApp.configure()
      GADMobileAds.sharedInstance().start(completionHandler: nil)
    return true
  }
}

@main
struct JWordsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            iOSAppView(
                store: Store(
                    initialState: iOSApp.State(),
                    reducer: iOSApp()._printChanges()
                )
            )
        }
    }
}

#elseif os(macOS)
class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        FirebaseApp.configure()
    }
}

@main
struct JWordsApp: App {
    @NSApplicationDelegateAdaptor private var delegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            MacAppView(
                store: Store(
                    initialState: MacApp.State(),
                    reducer: MacApp()._printChanges()
                )
            )
        }
    }
}
#endif


