//
//  LoginViewModel.swift
//  Messenger-App
//
//  Created by MacBook on 14.02.2021.
//

import Foundation
import Firebase
import FirebaseAuth

protocol LoginViewModelProtocol {
    func showAlert(title: String, message: String)
    func goToConversationPage()
    func errorEmpty()
    
}

class LoginViewModel {
    
    var delegate: LoginViewModelProtocol?
    
    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            
            if email == "" && password == ""  {
                
                self.delegate?.showAlert(title: "Error", message: "Please fill in your full information")
                
            } else if error == nil && result != nil {
                
                self.delegate?.goToConversationPage()
                
            } else {
                switch (error! as NSError).code {
                case 17011:
                    self.delegate?.showAlert(title: "User Not Found", message: "Check Your Email and Password")
                    self.delegate?.errorEmpty()
                case 17009:
                    self.delegate?.showAlert(title: "Wrong Password", message: "Please Check Your Password")
                    self.delegate?.errorEmpty()
                default:
                    self.delegate?.showAlert(title: "Error", message: "Please Check Your Information")
                    self.delegate?.errorEmpty()
                }
            }
        }
    }
}
