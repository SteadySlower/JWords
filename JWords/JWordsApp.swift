//
//  JWordsApp.swift
//  JWords
//
//  Created by JW Moon on 2022/06/25.
//

import SwiftUI
import FirebaseCore

#if os(iOS)
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct JWordsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    private let dependency: Dependency = DependencyImpl()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView(dependency)
            }
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
    
    private let dependency: Dependency = DependencyImpl()
    
    var body: some Scene {
        WindowGroup {
            ContentView(dependency)
                // TODO: mac 앱 만들 때 화면 사이즈 조절하는 방법
                .frame(minWidth: 800, maxWidth: .infinity, minHeight: 800, maxHeight: .infinity, alignment: .center)
        }
    }
}
#endif


