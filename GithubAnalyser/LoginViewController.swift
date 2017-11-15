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
    
    // MARK: - Variables
    @IBOutlet weak var usernameInput: UITextField?
    @IBOutlet weak var loginButton: UIButton?
    @IBOutlet weak var viewWithShadow: UIView!
    
    // MARK: - Initialisation
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)

        navigationController?.navigationBar.isTranslucent = false
        loginButton?.layer.masksToBounds = true
        loginButton?.layer.cornerRadius = 10.0
        
        viewWithShadow.dropShadow(offsetWidth: 20, offsetHeight:10)

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @objc func dismissKeyboard()
    {
        self.view.endEditing(true)
    }
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        
        // Animate button on click
        loginButton?.transform = CGAffineTransform(scaleX: 0, y: 0)
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.loginButton?.transform = .identity
        }, completion: nil)
        
        if let input = usernameInput?.text, let userDetails = Helper.getUserDetail(searchKey: input) {
            self.performSegue(withIdentifier: "profile", sender: userDetails)
        }
        else {
            getApiCallResults(username: usernameInput?.text)
        }
    }
    
    
    // MARK:- Update UI
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "profile" {
            let destinationVC = segue.destination as? ProfileViewController
            destinationVC?.userDetails = sender as? [String: Any]
            destinationVC?.openedFrom = .login
        }
    }
    
    
    // MARK:- API Call
    func getApiCallResults(username: String?) {
        
        if let username = username?.trimmingCharacters(in: .whitespaces), username.isEmpty == false {
            
            let urlString = Helper.userDetailHomeUrl + username
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
                        DispatchQueue.main.async {
                            self.loginButton?.shake()
                        }
                        Helper.showError(title: "Error", message: error?.localizedDescription)
                        return
                    }
                    let jsonData = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let errorMessage = jsonData?["message"] as? String {
                        DispatchQueue.main.async {
                            self.loginButton?.shake()
                        }
                        Helper.showError(title: "Login Error", message: errorMessage)
                    }
                    else {
                        Helper.addUser(user: jsonData)
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "profile", sender: jsonData)
                        }
                    }
                }
            }
        }
        else {
            loginButton?.shake()
            Helper.showError(title: "Login Error", message: "Please enter a username")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

