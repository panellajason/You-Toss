//
//  You_TossApp.swift
//  You-Toss
//
//  Created by Panella, Jason on 12/31/25.
//

import FirebaseCore
import SwiftUI

@main
struct You_TossApp: App {
    
    init() {
        FirebaseApp.configure()
      }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
