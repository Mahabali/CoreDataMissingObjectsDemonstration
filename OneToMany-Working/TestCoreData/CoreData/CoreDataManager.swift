//
//  CoreDataManager.swift
//  TestCoreData
//
//  Created by Mahabali on 18/09/19.
//  Copyright © 2019 Mahabali. All rights reserved.
//

import Foundation
import UIKit
import CoreData
typealias CoreDataBackgroundTask = (NSManagedObjectContext) -> Void
class CoreDataManager: NSObject {
  static var shared: CoreDataManager = {
    return CoreDataManager()
  }()
  var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "TestCoreData")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()
  
  static var privateContext: NSManagedObjectContext = CoreDataManager.shared.persistentContainer.newBackgroundContext()
  
  
  public static var mainContext: NSManagedObjectContext = CoreDataManager.shared.persistentContainer.viewContext
}

extension CoreDataManager{
  // Use this for reading. Because changes are written directly to disk and it has no parent context
  static func performBackgroundTask(task:@escaping CoreDataBackgroundTask){
    CoreDataManager.shared.persistentContainer.performBackgroundTask(task)
  }
  
  // MARK: - Core Data Saving support
  func saveAllContext(shouldBlock:Bool = true){
    self.savePrivateContext(shouldBlock: shouldBlock)
    self.saveMainContext(shouldBlock: shouldBlock)
  }
  func savePrivateContext(shouldBlock:Bool){
    self.saveContext(context: CoreDataManager.privateContext,shouldBlock:shouldBlock)
  }
  func saveMainContext(shouldBlock:Bool){
    self.saveContext(context: CoreDataManager.mainContext,shouldBlock:shouldBlock)
  }
  func saveContext(context:NSManagedObjectContext,shouldBlock:Bool){
    if context.hasChanges || true {
      if shouldBlock{
        context.performAndWait {
          self.saveContext(context: context)
        }
      }
      else{
        context.perform {
          self.saveContext(context: context)
        }
      }
    }
  }
  
  func saveContext(context:NSManagedObjectContext){
    do{
      try context.save()
      print("Saved Private context")
    }
    catch{
      print("\nError in saving core data private context. \(error.localizedDescription)\n")
    }
  }
}
