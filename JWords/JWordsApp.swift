//
//  JWordsApp.swift
//  JWords
//
//  Created by JW Moon on 2022/06/25.
//

import SwiftUI
import ComposableArchitecture
#if os(iOS)
import GoogleMobileAds
#endif

#if os(iOS)
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      GADMobileAds.sharedInstance().start(completionHandler: nil)
    return true
  }
}

@main
struct JWordsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            MainTabView(
                store: Store(
                    initialState: MainTab.State(),
                    reducer: { MainTab()._printChanges() }
                )
            )
        }
    }
}

#elseif os(macOS)
@main
struct JWordsApp: App {    
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


