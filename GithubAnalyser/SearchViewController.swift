//
//  SearchViewController.swift
//  GithubAnalyser
//
//  Created by Abhinav Mathur on 12/11/17.
//  Copyright © 2017 crickabhi. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    // MARK: - Variables
    @IBOutlet weak var searchBar: UISearchBar?
    @IBOutlet weak var tableView: UITableView?
    
    var records             : [[String:Any]?] = []
    var totalRecords        : Int?
    var searchKey           : String?
    var currentPageCount    : Int = 0
    

    // MARK:- Initialisation
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.tableFooterView = UIView()

        searchBar?.delegate = self
        searchBar?.showsCancelButton = false

        navigationController?.navigationBar.isTranslucent = false
        navigationItem.title = "Search"
    }
    
    @objc func dismissKeyboard()
    {
        self.view.endEditing(true)
    }
    
    
    // MARK:- API Call
    func searchUser(queryString: String?, pageCount : String?) {
        
        if let queryString = queryString, queryString.isEmpty == false {
            
            var urlString = Helper.searchUrl
            let queryItems = [URLQueryItem(name: "q", value: queryString), URLQueryItem(name: "page", value: pageCount)]
            var searchUrl = URLComponents(string: Helper.searchUrl)
            searchUrl?.queryItems = queryItems

            if let Url = searchUrl?.url {
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
                    let jsonData = try! JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable : Any]
                    if let json = jsonData, let records = json["items"] as? [[String : Any]], records.isEmpty == true {
                        self.currentPageCount = 1
                    }
                    else {
                        if let json = jsonData, let users = json["items"] as? [[String : Any]]  {
                            
                            for userDetail in users {
                                Helper.addUser(user: userDetail)
                                self.records.append(userDetail)
                            }
                            
                            if let totalCount = json["total_count"] as? Int {
                                self.totalRecords = totalCount
                            }

                            if queryString == self.searchKey && self.totalRecords == json["total_count"] as? Int {
                                self.currentPageCount = self.currentPageCount + 1
                            }
                            
                            DispatchQueue.main.async {
                                self.tableView?.reloadData()
                            }
                        }
                        else {
                            if let json = jsonData, let message = json["message"] as? String, message.isEmpty == false {
                                Helper.showError(title: "Error", message: message)
                            }
                        }
                    }
                }
            }
        }
        else {

            self.tableView?.reloadData()
        }
    }
}


// MARK: - SearchBar Delegate
extension SearchViewController : UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchKey = searchText
        records.removeAll()
        tableView?.reloadData()
        currentPageCount = 1
        searchUser(queryString: searchText, pageCount: String(currentPageCount))
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
}


// MARK: - TableView delegate and datasource
extension SearchViewController : UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileInfo")
        
        if let cell = cell {
            cell.textLabel?.text = records[indexPath.row]?["login"] as? String
            cell.textLabel?.textColor = .white
            
            return cell
        }
        else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        // Load Next Page Results If Required
        if let totalRecords = totalRecords, indexPath.row == tableView.numberOfRows(inSection: 0) - 1 && records.count < totalRecords
        {
            searchUser(queryString: searchKey, pageCount: String(currentPageCount))
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let VC = storyboard?.instantiateViewController(withIdentifier: "profileVC") as? ProfileViewController {
            let navVC = UINavigationController(rootViewController: VC)
            VC.userDetails = records[indexPath.row]
            VC.openedFrom = .search
            self.present(navVC, animated: true, completion: nil)
        }
    }
}
