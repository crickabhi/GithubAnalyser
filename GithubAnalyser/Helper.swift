//
//  Helper.swift
//  GithubAnalyser
//
//  Created by Abhinav Mathur on 12/11/17.
//  Copyright © 2017 crickabhi. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class Helper : NSObject {
    
    static let userDetailHomeUrl = "https://api.github.com/users/"
    static let searchUrl = "https://api.github.com/search/users?q="

    class func addUser(user : [String:Any]?) {
        let managedContext = CoreDataStack.getInstance().managedObjectContext
        if Helper().checkIfUserDetailPresent(user: user) == false {
            if let entity =  NSEntityDescription.entity(forEntityName: "User",in:managedContext) {
                let msgupdate = NSManagedObject(entity: entity,insertInto: managedContext)
                do {
                    msgupdate.setValue(user,forKey: "detail")
                    msgupdate.setValue(user?["login"] as? String,forKey: "login")
                    msgupdate.setValue(user?["name"]  as? String,forKey: "name")
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
    
    class func showError(title : String?, message : String?) {
        DispatchQueue.main.async(execute: {
            // update the view
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert);
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        })
    }
    
    class func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    class func getLocalFormatdate(dateString: String?)-> String? {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        if let dateString = dateString, let date  = formatter.date(from: dateString)  {
            formatter.dateFormat = "d MMM''yy 'at' HH:mm"
            return formatter.string(from: date)
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

extension UIButton {
    
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}

extension UIView {
    
    func applyGradient(colours: [UIColor]) -> Void {
        
        self.applyGradient(colours: colours, locations: nil)
    }
    
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> Void {
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func setBorder(width : CGFloat, radius : CGFloat, color : UIColor) {
        
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
        self.layer.cornerRadius = radius
    }
    
    func dropShadow(offsetWidth:CGFloat, offsetHeight : CGFloat) {
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: offsetWidth, height: offsetHeight)
        self.layer.shadowOpacity = 0.3
    }
}
