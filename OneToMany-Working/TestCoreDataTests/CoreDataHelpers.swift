//
//  CoreDataHelpers.swift
//  TestCoreDataTests
//
//  Created by Mahabali on 19/09/19.
//  Copyright © 2019 Mahabali. All rights reserved.
//

import Foundation
@testable import TestCoreData
class CoreDataHelpers{
    static func deleteAllRecords(){
        CoreDataManager.shared.deleteAllRecords(entity:"Car")
        CoreDataManager.shared.deleteAllRecords(entity:"Owner")
        CoreDataManager.shared.saveAllContext()
    }
    
}

