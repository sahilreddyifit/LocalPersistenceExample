//
//  ContentView.swift
//  Shared
//
//  Created by Sahil Reddy on 6/16/21.
//

import SwiftUI
import CoreData
import RealmSwift

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        List {
            ForEach(items) { item in
                Text("Item at \(item.timestamp!, formatter: itemFormatter)")
            }
            .onDelete(perform: deleteItems)
        }
        .toolbar {
            #if os(iOS)
            EditButton()
            #endif

            Button(action: addItem) {
                Label("Add Item", systemImage: "plus")
            }
        }.onAppear(perform: {
            /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Code@*/ /*@END_MENU_TOKEN@*/
        })
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // MARK: - Realm
    
    // Entrypoint. Call this to run the example.
    func runLocalOnlyExample() {
        // Open the local-only default realm
        let localRealm = try! Realm()
        // Get all tasks in the realm
        let tasks = localRealm.objects(LocalOnlyQsTask.self)

        // Retain notificationToken as long as you want to observe
        let notificationToken = tasks.observe { (changes) in
            switch changes {
            case .initial: break
                // Results are now populated and can be accessed without blocking the UI
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed.
                print("Deleted indices: ", deletions)
                print("Inserted indices: ", insertions)
                print("Modified modifications: ", modifications)
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
        }

        // Delete all from the realm
        try! localRealm.write {
            localRealm.deleteAll()
        }

        // Add some tasks
        let task = LocalOnlyQsTask(name: "Do laundry")
        try! localRealm.write {
            localRealm.add(task)
        }
        let anotherTask = LocalOnlyQsTask(name: "App design")
        try! localRealm.write {
            localRealm.add(anotherTask)
        }

        // You can also filter a collection
        let tasksThatBeginWithA = tasks.filter("name beginsWith 'A'")
        print("A list of all tasks that begin with A: \(tasksThatBeginWithA)")

        // All modifications to a realm must happen in a write block.
        let taskToUpdate = tasks[0]
        try! localRealm.write {
            taskToUpdate.status = "InProgress"
        }

        let tasksInProgress = tasks.filter("status = %@", "InProgress")
        print("A list of all tasks in progress: \(tasksInProgress)")

        // All modifications to a realm must happen in a write block.
        let taskToDelete = tasks[0]
        try! localRealm.write {
            // Delete the LocalOnlyQsTask.
            localRealm.delete(taskToDelete)
        }

        print("A list of all tasks after deleting one: \(tasks)")

        // Invalidate notification tokens when done observing
        notificationToken.invalidate()
    }

}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
