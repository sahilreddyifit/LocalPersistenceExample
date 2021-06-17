//
//  RealmView.swift
//  LocalPersistenceExample
//
//  Created by Sahil Reddy on 6/16/21.
//

import SwiftUI
import RealmSwift

struct RealmView: View {
    var body: some View {
        VStack {
            Text(getAllTasks())
        }.onAppear(perform: {
            runLocalOnlyExample()
        })
    }
    
    
    // MARK: - Realm
    
    func getAllTasks() -> String {
        let localRealm = try! Realm()
        let tasks = localRealm.objects(LocalOnlyQsTask.self)
        var result = ""
        for i in tasks {
            result.append(i.name)
            print(tasks.count)
        }
        return result
    }
    
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

struct RealmView_Previews: PreviewProvider {
    static var previews: some View {
        RealmView()
    }
}
