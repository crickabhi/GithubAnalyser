//
//  ProfileViewController.swift
//  GithubAnalyser
//
//  Created by Abhinav Mathur on 12/11/17.
//  Copyright © 2017 crickabhi. All rights reserved.
//

import UIKit

enum OpenedFrom: Int {
    case login = 0
    case search
    case followers
}


class ProfileViewController: UIViewController {

    @IBOutlet weak var userImage: UIImageView?
    @IBOutlet weak var userName: UILabel?
    @IBOutlet weak var userLocation: UILabel?
    @IBOutlet weak var userLastUpdateTime: UILabel?
    @IBOutlet weak var userPublicRepoCount: UILabel?
    @IBOutlet weak var publicRepoLabel: UILabel?
    @IBOutlet weak var userPublicGistsCount: UILabel?
    @IBOutlet weak var publicGistsLabel: UILabel?
    @IBOutlet weak var userFollowersCount: UILabel?
    @IBOutlet weak var followersLabel: UILabel?
    
    var userDetails : [String : Any]?
    var openedFrom : OpenedFrom?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if openedFrom == .search {
            let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(close))
            self.navigationItem.rightBarButtonItem  = button
            loadViewWithVariables()
        }
        else {
            let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(search))
            self.navigationItem.rightBarButtonItem  = button
            if openedFrom == .followers {
                if let login = userDetails?["login"] as? String {
                    apiCall(urlString: "https://api.github.com/users/" + login)
                }
            }
            else {
                loadViewWithVariables()
            }
        }
        
        navigationItem.title = userDetails?["login"] as? String
        
    }
    
    func loadViewWithVariables() {
        userName?.text = userDetails?["name"] as? String
        userLocation?.text = userDetails?["location"] as? String
        userLastUpdateTime?.text = getLocalFormatdate(dateString: userDetails?["updated_at"] as? String)
        if let publicRepoCount = userDetails?["public_repos"] {
            userPublicRepoCount?.text = String(describing: publicRepoCount)
        }
        else {
            userPublicRepoCount?.text = "0"
        }
        publicRepoLabel?.text = "Public Repository"
        if let publicGistsCount = userDetails?["public_gists"] {
            userPublicGistsCount?.text = String(describing: publicGistsCount)
        }
        else {
            userPublicGistsCount?.text = "0"
        }
        publicGistsLabel?.text = "Public Gists"
        if let followersCount = userDetails?["followers"] {
            userFollowersCount?.text = String(describing: followersCount)
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(openFollowersList))
            userFollowersCount?.addGestureRecognizer(tap)
            followersLabel?.addGestureRecognizer(tap)
        }
        else {
            userFollowersCount?.text = "0"
        }
        followersLabel?.text = "Followers"
        
        if let avatarUrl = userDetails?["avatar_url"] as? String, let url = URL(string: avatarUrl) {
            userImage?.contentMode = .scaleAspectFit
            downloadImage(url: url)
        }
    }

    func downloadImage(url: URL) {
        print("Download Started")
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                self.userImage?.image = UIImage(data: data)
            }
        }
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    func getLocalFormatdate(dateString: String?)-> String? {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        let date1  = formatter.date(from: dateString!)
        print("date:\(String(describing: date1))")
        formatter.dateFormat = "HH:mm 'on' d MMM''yy"
        return formatter.string(from: date1!)
    }
    
    @objc func search() {
        self.performSegue(withIdentifier: "search", sender: nil)
    }
    
    @objc func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func openFollowersList() {
        apiCall(urlString: userDetails?["followers_url"] as? String)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "search" {
            if sender != nil {
               let destinationVC = segue.destination as? SearchViewController
                destinationVC?.records = sender as? [[String : Any]?]
                destinationVC?.openedFrom = .followers
            }
            else {
                let destinationVC = segue.destination as? SearchViewController
                destinationVC?.openedFrom = .search
            }
        }
    }
    
    func apiCall(urlString : String?) {
        
        if let urlString = urlString, urlString.isEmpty == false {
            
            if let Url = URL(string:urlString) {
                let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                indicator.center = view.center
                view.addSubview(indicator)
                indicator.startAnimating()
                
                let task = URLSession.shared.dataTask(with: Url) { (data, response, error) in
                    
                    defer {
                        DispatchQueue.main.async {
                            indicator.stopAnimating()
                        }
                    }
                    if error != nil {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert);
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                        }
                    } else {
                        if let usableData = data {
                            
                            if self.openedFrom == .followers {
                                let jsonData = try! JSONSerialization.jsonObject(with: usableData, options: []) as? [String: Any]
                                if let records = jsonData, records.isEmpty == true {
//                                self.showError(title: "Login Error", message: errorMessage)
                                }
                                else {
                                    self.userDetails = jsonData
                                    DispatchQueue.main.async {
                                        self.loadViewWithVariables()
                                        self.openedFrom = .search
                                    }
                                }
                            }
                            else {
                                let jsonData = try! JSONSerialization.jsonObject(with: usableData, options: []) as? [[String: Any]]
                                if let records = jsonData, records.isEmpty == true {
//                                self.showError(title: "Login Error", message: errorMessage)
                                }
                                else {
                                    DispatchQueue.main.async {
                                        self.performSegue(withIdentifier: "search", sender: jsonData)
                                    }
                                }
                            }
                        }
                    }
                }
                task.resume()
            }
        }
        else {
//            showError(title: "Login Error", message: "Please enter a username")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
