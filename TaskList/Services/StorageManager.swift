//
//  StorageManager.swift
//  TaskList
//
//  Created by Shamkhan Mutuskhanov on 09.08.2023.
//

import Foundation
import CoreData

final class StorageManager {
    static let shared = StorageManager()
    
    var taskList: [Task] = []
    
    private init() {}

    // MARK: - Core Data stack
    private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskList")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
     func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Core Data
     func fetchData() {
        let fetchRequest = Task.fetchRequest()
        let context = persistentContainer.viewContext
        do {
            taskList = try context.fetch(fetchRequest)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
     func saveTask(_ taskName: String) {
        let context = persistentContainer.viewContext
        let task = Task(context: context)
        task.title = taskName
        taskList.append(task)

        viewContextSave()
    }
    
     func deleteTask(at indexPath: IndexPath) {
        let taskToDelete = taskList[indexPath.row]
        let context = persistentContainer.viewContext
        context.delete(taskToDelete)
        taskList.remove(at: indexPath.row)
        
        
        viewContextSave()
    }
    
     func updateTask(_ task: Task, with newTask: String) {
        task.title = newTask
        viewContextSave()
    }
    
    private func viewContextSave() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
}
