//
//  ViewController.swift
//  TestCoreData
//
//  Created by Mahabali on 18/09/19.
//  Copyright © 2019 Mahabali. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    // Delete All Existing Records
    CoreDataManager.shared.deleteAllRecords(entity: "Owner")
    CoreDataManager.shared.deleteAllRecords(entity: "Car")
    // Start with Cars insert
    insertCars()
  }
  // Inserting 3 cars
  func insertCars(){
    for i in 0...2{
      let car = Car(context: CoreDataManager.privateContext)
      car.name = "car-\(i)"
    }
    CoreDataManager.shared.savePrivateContext(shouldBlock: true)
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2){
      self.insertOwner()
    }
  }
  
  // Insert Owner and Save
  func insertOwner(){
    let owner = Owner(context: CoreDataManager.privateContext)
    owner.name = "Owner-0"
    CoreDataManager.shared.saveAllContext()
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2){
      self.mapOwnerToCar()
    }
  }
  // Map Owner to Car
  func mapOwnerToCar() {
    let predicate = NSPredicate(format: "name == %@", "Owner-0")
    let result = CoreDataManager.shared.getARecord(entityName: "Owner", predicate: predicate)
    let owner = result?.first as! Owner
    print("Owner retrieved was \(String(describing: owner.name!))")
    for j in 0...2{
      let index =  j
      
      let predicate = NSPredicate(format: "name == %@", "car-\(index)")
      let result = CoreDataManager.shared.getARecord(entityName: "Car", predicate: predicate)
      let car = result?.first as! Car
      owner.addToCar(car)
      print("Mapping \(car.name!) to \(owner.name!)")
    }
    print(" Owner \(String(describing: owner.name!)) and his mapped car count  is \(owner.car!.count) before saving to store")
    CoreDataManager.shared.saveAllContext()
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2){
      self.fetchAllOwners()
    }
  }
  
  // Fetch Owner and List his cars
  func fetchAllOwners(){
    let predicate = NSPredicate(format: "name == %@", "Owner-0")
    let result = CoreDataManager.shared.getARecord(entityName: "Owner", predicate: predicate)
    let owner = result?.first as! Owner
    print("Owner name \(String(describing: owner.name!)) his mapped car count  is \(owner.car!.count), from store")
    for cart in owner.car!{
      let car = cart as! Car
      print("Car \(String(describing: car.name!)) is mapped for owner \(owner.name!) in store")
    }
  }
}

