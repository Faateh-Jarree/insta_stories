//
//  instaApp.swift
//  insta
//
//  Created by Faateh Jarree on 31.08.25.
//

import SwiftUI

@main
struct instaApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
