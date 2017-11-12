//
//  LoginViewController.swift
//  GithubAnalyser
//
//  Created by Abhinav Mathur on 12/11/17.
//  Copyright © 2017 crickabhi. All rights reserved.
//

import UIKit
import Foundation

class LoginViewController: UIViewController {
    @IBOutlet weak var usernameInput: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @objc func dismissKeyboard()
    {
        self.view.endEditing(true)
    }
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        
        getApiCallResults(username: usernameInput.text)
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
    
    // MARK:- API Call
    func getApiCallResults(username: String?) {
        
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
                                self.showError(title: "Login Error", message: errorMessage)
                            }
                            else {
                                DispatchQueue.main.async {
                                    self.performSegue(withIdentifier: "profile", sender: jsonData)
                                }
                                
                            }

                        }
                    }
                }
                task.resume()
            }
        }
        else {
            showError(title: "Login Error", message: "Please enter a username")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "profile" {
            let destinationVC = segue.destination as? ProfileViewController
            destinationVC?.userDetails = sender as? [String: Any]
            destinationVC?.openedFrom = .login
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

