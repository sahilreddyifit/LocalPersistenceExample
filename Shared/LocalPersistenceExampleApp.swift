//
//  LocalPersistenceExampleApp.swift
//  Shared
//
//  Created by Sahil Reddy on 6/16/21.
//

import SwiftUI

@main
struct LocalPersistenceExampleApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
