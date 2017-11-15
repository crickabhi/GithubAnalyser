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
}


class ProfileViewController: UIViewController {

    // MARK: - Variables
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
    
    @IBOutlet weak var followersView: UIView?
    @IBOutlet weak var publicRepoView: UIView?
    @IBOutlet weak var publicGistsView: UIView?
    @IBOutlet weak var bottomView: UIView?
    
    var userDetails : [String : Any]?
    var openedFrom : OpenedFrom?
    
    // MARK:- Initialisation
    override func viewDidLoad() {
        super.viewDidLoad()

        if openedFrom == .search {
            let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(close))
            self.navigationItem.rightBarButtonItem  = button
            if let login = userDetails?["login"] as? String {
                if let userDetails = Helper.getUserDetail(searchKey: login) {
                    self.userDetails = userDetails
                    loadViewWithVariables()
                }
                else {
                    apiCall(urlString: Helper.userDetailHomeUrl + login)
                }
            }
            else {
                loadViewWithVariables()
            }
        }
        else {
            let searchbutton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(search))
            let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
            self.navigationItem.rightBarButtonItems = [shareButton,searchbutton]
            loadViewWithVariables()
        }
        navigationItem.title = userDetails?["login"] as? String
        navigationController?.navigationBar.isTranslucent = false

        userImage?.setBorder(width: 2.0, radius: 10, color : .white)

        bottomView?.setBorder(width: 2.0, radius: 5, color : UIColor.init(red: 81/255, green: 146/255, blue: 188/255, alpha: 1.0))
    }
    
    func loadViewWithVariables() {
        
        userName?.text = userDetails?["name"] as? String
        
        if let location = userDetails?["location"] as? String {
            userLocation?.text = "Location :- " + location
        }
        
        if let time = Helper.getLocalFormatdate(dateString: userDetails?["updated_at"] as? String) {
            userLastUpdateTime?.text = "Last Update :- " + time
        }
        
        if let publicRepoCount = userDetails?["public_repos"] {
            userPublicRepoCount?.text = String(describing: publicRepoCount)
        }
        else {
            userPublicRepoCount?.text = "0"
        }

        if let publicGistsCount = userDetails?["public_gists"] {
            userPublicGistsCount?.text = String(describing: publicGistsCount)
        }
        else {
            userPublicGistsCount?.text = "0"
        }
        
        if let followersCount = userDetails?["followers"] {
            userFollowersCount?.text = String(describing: followersCount)
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(openFollowersList))
            followersView?.addGestureRecognizer(tap)
        }
        else {
            userFollowersCount?.text = "0"
        }
        
        if let avatarUrl = userDetails?["avatar_url"] as? String, let url = URL(string: avatarUrl) {
            userImage?.contentMode = .scaleAspectFit
            userImage?.layer.masksToBounds = true
            downloadImage(url: url)
        }
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
    
    @objc func share(sender : UIButton) {
        
        if let name = userDetails?["name"] as? String,
            let location = userDetails?["location"] as? String,
            let publicRepoCount = userDetails?["public_repos"],
            let followersCount = userDetails?["followers"]   {
            
            let title = "Github Profile Details"
            let userName =  "Name :- " + name
            let userLocation = "Location :- " + location
            let userFollowers = "Followers :- " + String(describing: followersCount)
            let userPublicRepo = "Public Repository :- " + String(describing: publicRepoCount)
            
            let objectsToShare = [title, userName, userFollowers, userPublicRepo, userLocation] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            activityVC.popoverPresentationController?.sourceView = sender
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - Image download helper
    func downloadImage(url: URL) {
         //(activityIndicatorStyle: .gray)
        if let image = userImage {
            let indicator = UIActivityIndicatorView(frame: image.bounds)
            indicator.activityIndicatorViewStyle = .gray
            indicator.isHidden = false
            indicator.center = image.center
            userImage?.addSubview(indicator)
            indicator.startAnimating()
            Helper.getDataFromUrl(url: url) { data, response, error in
                guard let data = data, error == nil else { return }
                print(response?.suggestedFilename ?? url.lastPathComponent)
                DispatchQueue.main.async() {
                    defer {
                        indicator.stopAnimating()
                    }
                    self.userImage?.image = UIImage(data: data)
                }
            }
        }
    }
    
    
    // MARK:- Update UI
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "search" {
            if sender != nil {
               let destinationVC = segue.destination as? SearchViewController
                if let user = sender as? [[String : Any]?] {
                    destinationVC?.records = user
                }
            }
        }
    }
    
    
    // MARK:- API Call
    func apiCall(urlString : String?) {
        
        if let urlString = urlString, urlString.isEmpty == false {
            
            if let Url = URL(string:urlString) {
                let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                indicator.center = view.center
                view.addSubview(indicator)
                indicator.startAnimating()
                
                Helper.getDataFromUrl(url: Url) { data, response, error in
                    defer {
                        DispatchQueue.main.async {
                            indicator.stopAnimating()
                        }
                    }
                    guard let data = data, error == nil else {
                        Helper.showError(title: "Error", message: error?.localizedDescription)
                        return
                    }
                    if urlString == self.userDetails?["followers_url"] as? String {
                        let jsonData = try! JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
                        if let records = jsonData, records.isEmpty == true {
                            
                        }
                        else {
                            if let users = jsonData {
                                for userDetail in users {
                                    Helper.addUser(user: userDetail)
                                }
                            }
                            
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "search", sender: jsonData)
                            }
                        }
                    }
                    else {
                        let jsonData = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        if let records = jsonData, records.isEmpty == true {
                            
                        }
                        else {
                            self.userDetails = jsonData
                            DispatchQueue.main.async {
                                self.loadViewWithVariables()
                            }
                        }
                    }
                }
            }
        }
        else {

        }
    }
}
