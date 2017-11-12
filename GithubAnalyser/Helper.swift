//
//  Helper.swift
//  GithubAnalyser
//
//  Created by Abhinav Mathur on 12/11/17.
//  Copyright © 2017 crickabhi. All rights reserved.
//

import Foundation
import CoreData

class Helper : NSObject {
    
//    // If user detail present then send those values else add the new values
//    func returnUserDetailHelper(user : [String: Any]) -> [String:Any]?
//    {
//        let managedContext = CoreDataStack.getInstance().managedObjectContext
//        let entity =  NSEntityDescription.entity(forEntityName: "User",in:managedContext)
//
//        if let id = user["id"] as? String, let entity = entity {
//
//            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
//            fetchRequest.predicate = NSPredicate(format:"id = %@", id)
//
//            do {
//                let results = try managedContext.fetch(fetchRequest)
//                if results.isEmpty == true {
//                    let msgupdate = NSManagedObject(entity: entity,insertInto: managedContext)
//                    msgupdate.setValue(user,forKey: "detail")
//                    msgupdate.setValue(id,forKey: "id")
//                    try managedContext.save()
//                }
//                else {
//                    return results[0] as? [String:Any]
//                }
//            } catch let error as NSError {
//                print("Could not fetch \(error), \(error.userInfo)")
//            }
//        }
//        else {
//            if let id = user["id"] as? String, let entity = entity {
//                let msgupdate = NSManagedObject(entity: entity,insertInto: managedContext)
//                msgupdate.setValue(user,forKey: "detail")
//                msgupdate.setValue(id,forKey: "id")
//                do {
//                    try managedContext.save()
//                }
//                catch let error as NSError {
//                    print("Could not fetch \(error), \(error.userInfo)")
//                }
//            }
//        }
//        return nil
//    }
    
    class func addUser(user : [String:Any]?) {
        let managedContext = CoreDataStack.getInstance().managedObjectContext
        if Helper().checkIfUserDetailPresent(user: user) == false {
            if let entity =  NSEntityDescription.entity(forEntityName: "User",in:managedContext) {
                let msgupdate = NSManagedObject(entity: entity,insertInto: managedContext)
                do {
                    msgupdate.setValue(user,forKey: "detail")
                    msgupdate.setValue(user?["login"],forKey: "login")
                    msgupdate.setValue(user?["name"],forKey: "name")
                    msgupdate.setValue(user?["id"],forKey: "id")

                    try managedContext.save()
                }
                catch let error as NSError {
                    print("Could not fetch \(error), \(error.userInfo)")
                }
            }
        }
    }
    
    class func getUserDetail(searchKey : String) -> [String:Any]? {
        
        let managedContext = CoreDataStack.getInstance().managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        let p1 = NSPredicate(format:"login = %@", searchKey)
        let p2 = NSPredicate(format:"name = %@", searchKey)

        fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [p1,p2])
        
        do {
            let results = try managedContext.fetch(fetchRequest) as? [NSManagedObject]
            if results?.isEmpty == false {
                return (results?[0] as? User)?.value(forKey: "detail") as? [String:Any]
            }
        }
        catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return nil
    }
    
    private func checkIfUserDetailPresent(user : [String:Any]?) -> Bool {
        
        if let id = user?["id"] as? Int64 {
            
            let managedContext = CoreDataStack.getInstance().managedObjectContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")

            fetchRequest.predicate = NSPredicate(format:"id = %d", id)
            
            do {
                let results = try managedContext.fetch(fetchRequest)
                if results.isEmpty == false {
                    return true
                }
            }
            catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }
        }
        return false
    }
    
}
