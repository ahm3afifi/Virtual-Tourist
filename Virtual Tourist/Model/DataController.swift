//
//  DataController.swift
//  Virtual Tourist
//
//  Created by Ahmed Afifi on 7/28/19.
//  Copyright © 2019 Ahmed Afifi. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
    let container: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    init(modelName: String) {
        container = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: ( () -> Void)? = nil ) {
        container.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
}
