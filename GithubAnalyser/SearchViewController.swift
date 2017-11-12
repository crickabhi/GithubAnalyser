//
//  SearchViewController.swift
//  GithubAnalyser
//
//  Created by Abhinav Mathur on 12/11/17.
//  Copyright © 2017 crickabhi. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var records : [[String:Any]?]?
    var openedFrom : OpenedFrom?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()

        searchBar.delegate = self
        searchBar.showsCancelButton = false
        searchBar.returnKeyType = .default
    }
    
    @objc func dismissKeyboard()
    {
        self.view.endEditing(true)
    }
    
    // MARK:- API Call
    func searchUser(username: String?) {
        
        if let username = username, username.isEmpty == false {
            
            let urlString = "https://api.github.com/users/" + username
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
                            
                            let jsonData = try! JSONSerialization.jsonObject(with: usableData, options: []) as? [String: Any]
                            if let errorMessage = jsonData?["message"] as? String {
//                                self.showError(title: "Login Error", message: errorMessage)
                            }
                            else {
                                Helper.addUser(user: jsonData)
                                self.records = [jsonData]
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    }
                }
                task.resume()
            }
        }
        else {
            self.records = nil
            self.tableView.reloadData()
//            showError(title: "Login Error", message: "Please enter a username")
        }
    }
    
    // MARK:- Update UI
    func showError(title : String, message : String) {
        DispatchQueue.main.async(execute: {
            // update the view
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert);
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        })
    }
}

extension SearchViewController : UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchUser(username: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
}

extension SearchViewController : UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let records = records, records.isEmpty == false {
            return records.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileInfo") as? ProfileInfoTableViewCell
        
        if let cell = cell {
            
            cell.name?.text = records?[indexPath.row]?["login"] as? String
            cell.location?.text = records?[indexPath.row]?["location"] as? String
            if let publicRepoCount = records?[indexPath.row]?["public_repos"] {
                cell.publicRepoCount?.text = String(describing: publicRepoCount)
            }
            else {
                cell.publicRepoCount?.text = "0"
            }
            cell.publicRepoLabel?.text = "Public Repo"
            if let followersCount = records?[indexPath.row]?["followers"] {
                cell.followersCount?.text = String(describing: followersCount)
            }
            else {
                cell.followersCount?.text = "0"
            }
            cell.followersLabel?.text = "Followers"
            return cell
        }
        else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let VC = storyboard?.instantiateViewController(withIdentifier: "profileVC") as? ProfileViewController {
            let navVC = UINavigationController(rootViewController: VC)
            VC.userDetails = records?[indexPath.row]
            VC.openedFrom = .search
            self.present(navVC, animated: true, completion: nil)
        }
    }
}
