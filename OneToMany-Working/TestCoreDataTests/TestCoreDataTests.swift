//
//  TestCoreDataTests.swift
//  TestCoreDataTests
//
//  Created by Mahabali on 18/09/19.
//  Copyright © 2019 Mahabali. All rights reserved.
//

import XCTest
@testable import TestCoreData

class TestCoreDataTests: XCTestCase {

    override func setUp() {
        CoreDataHelpers.deleteAllRecords()
    }

    override func tearDown() {
    }
    // This is a simple test case to run insertion, with private and main contexts blocked during save
    // Result - Will Pass
    // Inference - Our DB can handle 10000 inserts
    func testSimpleInsert() {
        
        CoreDataHelpers.deleteAllRecords()
        let exp = expectation(description: "executing core data simple insert")
        DispatchQueue.global().async {
            CoreDataManager.privateContext.perform {
                for i in 0..<10000{
                    let car = CoreDataManager.shared.create(entityName: "Car") as! Car
                    car.name = "car-\(i)"
                    let owner = CoreDataManager.shared.create(entityName: "Owner") as! Owner
                    owner.name = "owner-\(i)"
                    
                }
                //CoreDataManager.shared.savePrivateContext(shouldBlock: true)
                //CoreDataManager.shared.saveMainContext(shouldBlock: true)
                CoreDataManager.shared.saveAllContext()
                exp.fulfill()
            }
        }
        waitForExpectations(timeout: 2)
        let count = CoreDataManager.shared.getCountOfRecords(entityName: "Car", predicate: nil)
        XCTAssertEqual(count!, 10000)
    }
    // This is a simple test case to run insertion from different threads, with private and main contexts blocked during save
    // Result - Will Pass
    // Inference - Our DB can handle 10000 inserts from different threads
    func testInsertFromMutipleThreads() {
        
        CoreDataManager.shared.persistentContainer.performBackgroundTask { (newContext) in
             // Do All Operations ( Insert, Delete,Access and Save) within this block
        }
       
        
        
        CoreDataHelpers.deleteAllRecords()
        let expectation1 = expectation(description: "insert first 5000")
        let expectation2 = expectation(description: "insert second 5000")
        DispatchQueue.global(qos:.default).async {
            CoreDataManager.privateContext.perform {
                for i in 0..<5000{
                    let car = CoreDataManager.shared.create(entityName: "Car") as! Car
                    car.name = "car-\(i)"
                    let owner = CoreDataManager.shared.create(entityName: "Owner") as! Owner
                    owner.name = "owner-\(i)"
                    car.owner = owner
                    owner.car = car
                }
            
                 CoreDataManager.shared.saveAllContext()
                expectation1.fulfill()
            }
        }
        DispatchQueue.global(qos:.userInteractive).async {
            CoreDataManager.privateContext.perform {
                for i in 0..<5000{
                    let car = CoreDataManager.shared.create(entityName: "Car") as! Car
                    car.name = "car-\(i)"
                    let owner = CoreDataManager.shared.create(entityName: "Owner") as! Owner
                    owner.name = "owner-\(i)"
                    car.owner = owner
                    owner.car = car
                    
                }
                CoreDataManager.shared.saveAllContext()
                expectation2.fulfill()
            }
        }
 
        
        waitForExpectations(timeout: 2)
        let count = CoreDataManager.shared.getCountOfRecords(entityName: "Car", predicate: nil)
        XCTAssertEqual(count!, 10000)
    }
    // This is a simple test case to demonstrate that you can insert and access from different threads without blocking. Since its non blocking save, main context has not received changes
    // Result - Will Fail
    // Inference - Non blocking save will not provide latest value
    func testInsertAndAccessFromMutipleThreadsWithoutBlocking() {
        
        CoreDataHelpers.deleteAllRecords()
        let expectation1 = expectation(description: "insert first 5000")
        let expectation2 = expectation(description: "access from second 5000")
        DispatchQueue.global(qos:.default).async {
            CoreDataManager.privateContext.perform {
                for i in 0..<5000{
                    let car = CoreDataManager.shared.create(entityName: "Car") as! Car
                    car.name = "car-\(i)"
                    let owner = CoreDataManager.shared.create(entityName: "Owner") as! Owner
                    owner.name = "owner-\(i)"
                    car.owner = owner
                    owner.car = car
                }
                
                CoreDataManager.shared.saveAllContext(shouldBlock: false)
                expectation1.fulfill()
            }
        }
        DispatchQueue.global(qos:.userInteractive).async {
            
            CoreDataManager.privateContext.perform {
               let carObjects = CoreDataManager.shared.getAllRecords(entityName: "Car", predicate: nil) as? [Car]
                if let cars = carObjects {
                    for _ in 0..<cars.count {
                    //print("\(String(describing: cars[i].name))")
                }
                print("\(cars.count)")
                XCTAssertEqual(cars.count, 5000)
                expectation2.fulfill()
                }
                else {
                    XCTAssertNotNil(carObjects)
                }
            }
        }
        waitForExpectations(timeout: 2)
    }
    // This is a simple test case to demonstrate that you can insert and access from different threads without blocking. Since its non blocking save but with a delay, main context will receive changes, since they changes are small. NOT RECOMMENDED, this is just for demonstration
    // Result - Will Pass
    // Inference - Non blocking save  with delay will provide latest value
    func testInsertAndAccessFromMutipleThreadsWithoutBlockingAndAfterADelay() {
        
        CoreDataHelpers.deleteAllRecords()
        let expectation1 = expectation(description: "insert first 5000")
        let expectation2 = expectation(description: "access from second 5000")
        DispatchQueue.global(qos:.default).async {
            CoreDataManager.privateContext.perform {
                for i in 0..<5000{
                    let car = CoreDataManager.shared.create(entityName: "Car") as! Car
                    car.name = "car-\(i)"
                    let owner = CoreDataManager.shared.create(entityName: "Owner") as! Owner
                    owner.name = "owner-\(i)"
                    car.owner = owner
                    owner.car = car
                }
                
                CoreDataManager.shared.saveAllContext(shouldBlock: false)
                expectation1.fulfill()
            }
        }
        DispatchQueue.global(qos:.userInteractive).asyncAfter(deadline: DispatchTime.now() + 1.0, execute: {
            CoreDataManager.privateContext.perform {
                let carObjects = CoreDataManager.shared.getAllRecords(entityName: "Car", predicate: nil) as? [Car]
                if let cars = carObjects {
                    for _ in 0..<cars.count {
                        //print("\(String(describing: cars[i].name))")
                    }
                    print("\(cars.count)")
                    XCTAssertEqual(cars.count, 5000)
                    expectation2.fulfill()
                }
                else {
                    XCTAssertNotNil(carObjects)
                }
            }
        })
        waitForExpectations(timeout: 3)
    }
    // You can block and save either in first/second thread. Result will be consistent
    // Result - Will Pass
    // Inference - Sync is guaranteed, with blocked syncing
    func testInsertAndAccessFromMutipleThreadsWithBlocking() {
        
        CoreDataHelpers.deleteAllRecords()
        let expectation1 = expectation(description: "insert first 5000")
        let expectation2 = expectation(description: "access from second 5000")
        DispatchQueue.global(qos:.default).async {
            CoreDataManager.privateContext.perform {
                for i in 0..<5000{
                    let car = CoreDataManager.shared.create(entityName: "Car") as! Car
                    car.name = "car-\(i)"
                    let owner = CoreDataManager.shared.create(entityName: "Owner") as! Owner
                    owner.name = "owner-\(i)"
                    car.owner = owner
                    owner.car = car
                }
                
                CoreDataManager.shared.saveAllContext(shouldBlock: true)
                expectation1.fulfill()
            }
        }
        DispatchQueue.global(qos:.userInteractive).async {
            CoreDataManager.privateContext.perform {
                let cars = CoreDataManager.shared.getAllRecords(entityName: "Car", predicate: nil) as? [Car]
                if let cars = cars {
                    for _ in 0..<cars.count {
                        //print("\(String(describing: cars[i].name))")
                    }
                    expectation2.fulfill()
                    XCTAssertEqual(cars.count, 5000)
                }
                else {
                    XCTAssertNotNil(cars)
                }
            }
        }
        waitForExpectations(timeout: 2)
    }
    
    // You have to block and save either in first/second thread else result will be inconsistent
    // Result - Will Fail
    // Inference - Sync is not guaranteed, with blocked syncing and will fail
    func testInsertAndRandomSaveFromMutipleThreadsWithoutBlocking() {
        
        CoreDataHelpers.deleteAllRecords()
        let expectation1 = expectation(description: "insert first 5000")
        let expectation2 = expectation(description: "save")
        DispatchQueue.global(qos:.default).async {
            CoreDataManager.privateContext.perform {
                for i in 0..<5000{
                    let car = CoreDataManager.shared.create(entityName: "Car") as! Car
                    car.name = "car-\(i)"
                    let owner = CoreDataManager.shared.create(entityName: "Owner") as! Owner
                    owner.name = "owner-\(i)"
                    car.owner = owner
                    owner.car = car
                }
                CoreDataManager.shared.saveAllContext(shouldBlock: false)
                expectation1.fulfill()
            }
        }
        DispatchQueue.global(qos:.background).async {
            CoreDataManager.shared.saveAllContext(shouldBlock: true)
        }
        DispatchQueue.global(qos:.userInteractive).async {
            CoreDataManager.privateContext.perform {
               // CoreDataManager.shared.saveAllContext(shouldBlock: true)
                let count = CoreDataManager.shared.getCountOfRecords(entityName: "Car", predicate: nil) ?? 0
                XCTAssertEqual(count, 5000)
                    expectation2.fulfill()
                
                }
        }
        waitForExpectations(timeout: 3)
    }
    
    // Insert, Delete and Access is done randomly from different threads. Without proper save, result is not consistent and may fail/pass depending on thread. It will pass likely on unserinteractive qos
    // Result - Will Fail
    // Inference - Fetch records is from main thread and queue, so it will not have data
    func testInsertDeleteAndAccessWithoutProperSaveFromMutipleThreadsWithBlocking() {
        CoreDataHelpers.deleteAllRecords()
        let expectation1 = expectation(description: "insert first 5000")
        let expectation2 = expectation(description: "delete")
        let expectation3 = expectation(description: "access")
        DispatchQueue.global(qos:.default).async {
            CoreDataManager.privateContext.perform {
                for i in 0..<5000{
                    let car = CoreDataManager.shared.create(entityName: "Car") as! Car
                    car.name = "car-\(i)"
                    let owner = CoreDataManager.shared.create(entityName: "Owner") as! Owner
                    owner.name = "owner-\(i)"
                    car.owner = owner
                    owner.car = car
                }
                CoreDataManager.shared.saveAllContext(shouldBlock: true)
                expectation1.fulfill()
            }
        }
        DispatchQueue.global(qos:.background).async {
            CoreDataManager.privateContext.perform {
                for i in 0..<5000{
                    let carName = "car-\(i)"
                    CoreDataManager.shared.deleteData(entityName: "Car", predicate: NSPredicate(format: "name == %@",carName))
                }
                
                DispatchQueue.main.async {
                    let count = CoreDataManager.shared.getCountOfRecords(entityName: "Car", predicate: nil) ?? -1
                    XCTAssertEqual(count, 0)
                    expectation3.fulfill()
                }
                 CoreDataManager.shared.saveAllContext(shouldBlock: true)
                 expectation2.fulfill()
                
            }
        }
        waitForExpectations(timeout: 15)
    }
    
    // Insert, Delete and Access is done randomly from different threads. With proper save, result will be consistent
    // Result - Will Pass
    // Inference - Save and then Fetch records is from main thread and queue, to have consistent data
    func testInsertDeleteAndAccessWithtProperSaveFromMutipleThreadsWithBlocking() {
        CoreDataHelpers.deleteAllRecords()
        let expectation1 = expectation(description: "insert first 5000")
        let expectation2 = expectation(description: "delete")
        let expectation3 = expectation(description: "access")
        DispatchQueue.global(qos:.default).async {
            CoreDataManager.privateContext.perform {
                for i in 0..<5000{
                    let car = CoreDataManager.shared.create(entityName: "Car") as! Car
                    car.name = "car-\(i)"
                    let owner = CoreDataManager.shared.create(entityName: "Owner") as! Owner
                    owner.name = "owner-\(i)"
                    car.owner = owner
                    owner.car = car
                }
                CoreDataManager.shared.saveAllContext(shouldBlock: true)
                expectation1.fulfill()
            }
        }
        DispatchQueue.global(qos:.userInteractive).async {
            CoreDataManager.privateContext.perform {
                for i in 0..<5000{
                    let carName = "car-\(i)"
                    CoreDataManager.shared.deleteData(entityName: "Car", predicate: NSPredicate(format: "name == %@",carName))
                }
                
                DispatchQueue.main.async {
                     CoreDataManager.shared.saveAllContext(shouldBlock: true)
                    let count = CoreDataManager.shared.getCountOfRecords(entityName: "Car", predicate: nil) ?? -1
                    XCTAssertEqual(count, 0)
                    expectation3.fulfill()
                }
                CoreDataManager.shared.saveAllContext(shouldBlock: true)
                expectation2.fulfill()
                
            }
        }
        waitForExpectations(timeout: 15)
    }
    // Insert, Delete from different threads and Access is done randomly from different threads. With proper save, result will be consistent
    // Result - Will Pass
    // Inference - Save and then Fetch records is from main thread and queue, to have consistent data
    func testDeleteAndAccessWithProperSaveFromMutipleThreadsWithBlocking() {
        CoreDataHelpers.deleteAllRecords()
        let expectation1 = expectation(description: "insert first 5000")
        let expectation2 = expectation(description: "delete")
        let expectation3 = expectation(description: "access")
        DispatchQueue.global(qos:.default).async {
            CoreDataManager.privateContext.perform {
                for i in 0..<5000{
                    let car = CoreDataManager.shared.create(entityName: "Car") as! Car
                    car.name = "car-\(i)"
                    let owner = CoreDataManager.shared.create(entityName: "Owner") as! Owner
                    owner.name = "owner-\(i)"
                    car.owner = owner
                    owner.car = car
                }
                CoreDataManager.shared.saveAllContext(shouldBlock: true)
                expectation1.fulfill()
            }
        }
        DispatchQueue.global(qos:.background).async {
            CoreDataManager.privateContext.perform {
                for i in 0..<2500{
                    let carName = "car-\(i)"
                    CoreDataManager.shared.deleteData(entityName: "Car", predicate: NSPredicate(format: "name == %@",carName))
                }
            }
        }
        DispatchQueue.global(qos:.userInteractive).async {
            CoreDataManager.privateContext.perform {
                for i in 2500..<5000{
                    let carName = "car-\(i)"
                    CoreDataManager.shared.deleteData(entityName: "Car", predicate: NSPredicate(format: "name == %@",carName))
                }
                
                DispatchQueue.main.async {
                    CoreDataManager.shared.saveAllContext(shouldBlock: true)
                    let count = CoreDataManager.shared.getCountOfRecords(entityName: "Car", predicate: nil) ?? -1
                    XCTAssertEqual(count, 0)
                    expectation3.fulfill()
                }
                CoreDataManager.shared.saveAllContext(shouldBlock: true)
                expectation2.fulfill()
                
            }
        }
        waitForExpectations(timeout: 15)
    }
    
    
}
