//
//  DaysyApp.swift
//  Daysy
//
//  Created by Alexander Eischeid on 10/19/23.
//

import SwiftUI

@main
struct DaysyApp: App {
    
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            //             DebugView()
            // /*
            if defaults.bool(forKey: "completedTutorial") {
                //                WelcomeView()
                ContentView()
            } else {
                WelcomeView()
            }
            // */
        }
        .onChange(of: scenePhase) { newScenePhase in
            if newScenePhase == .active {
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
        }
    }
}
