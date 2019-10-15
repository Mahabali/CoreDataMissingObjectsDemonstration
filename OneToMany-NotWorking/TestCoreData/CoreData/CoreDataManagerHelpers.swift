//
//  CoreDataManagerHelpers.swift
//  TestCoreData
//
//  Created by Mahabali on 18/09/19.
//  Copyright © 2019 Mahabali. All rights reserved.
//

import Foundation
import CoreData
extension CoreDataManager{
    func create(entityName : String,context:NSManagedObjectContext = CoreDataManager.privateContext) -> NSManagedObject{
        return NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
    }
    func getAllRecords(entityName: String, predicate : NSPredicate?) -> [NSManagedObject]?{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        if let predicate = predicate{
            fetchRequest.predicate = predicate
        }
        do{
            guard let records = try CoreDataManager.privateContext.fetch(fetchRequest) as? [NSManagedObject] else {
                return nil
            }
            return records
        }
        catch{
            return nil
        }
    }
  func getARecord(entityName: String, predicate : NSPredicate?) -> [NSManagedObject]?{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        if let predicate = predicate{
            fetchRequest.predicate = predicate
          fetchRequest.fetchLimit = 1
        }
        do{
            guard let records = try CoreDataManager.privateContext.fetch(fetchRequest) as? [NSManagedObject] else {
                return nil
            }
            return records
        }
        catch{
            return nil
        }
    }
    func getCountOfRecords(entityName: String, predicate : NSPredicate?) -> Int?{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        if let predicate = predicate{
            fetchRequest.predicate = predicate
        }
        do{
           let recordsCount = try CoreDataManager.mainContext.count(for: fetchRequest)
            return recordsCount
            
        }
        catch{
            return nil
        }
    }
    
    func deleteData(entityName:String,predicate:NSPredicate) {
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = predicate
        let objects = try! CoreDataManager.privateContext.fetch(fetchRequest)
        for obj in objects {
            CoreDataManager.privateContext.delete(obj)
        }
    }
    func deleteAllRecords(entity : String)
    {
        
        let context = CoreDataManager.privateContext
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do
        {
            try context.execute(deleteRequest)
            CoreDataManager.shared.saveAllContext()
        }
        catch
        {
            print ("There was an error")
        }
    }
}
