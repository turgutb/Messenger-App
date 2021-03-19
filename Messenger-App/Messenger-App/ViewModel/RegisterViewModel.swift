//
//  RegisterViewModel.swift
//  Messenger-App
//
//  Created by MacBook on 14.02.2021.
//

import Foundation
import Firebase
import FirebaseAuth

protocol RegisterViewModelProtocol {
    
    func showAlert(title: String, message: String)
    func goToConversationPage()
    func errorEmpty()
}


class RegisterViewModel {
    
    var delegate: RegisterViewModelProtocol?
    
    func register (name: String, surname: String, email: String, password: String, profilePicture: UIImage) {
        
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { authResult, error in
            guard authResult != nil, error == nil else {
                switch (error! as NSError).code {
                case 17007:
                    self.delegate?.showAlert(title: "Check Your Password", message: "Registration was created with this email address.")
                    self.delegate?.errorEmpty()
                case 17026:
                    self.delegate?.showAlert(title: "Insufficient number of password characters", message: "Make sure that your password consists of at least 6 characters.")
                    self.delegate?.errorEmpty()
                case 17008:
                    self.delegate?.showAlert(title: "Incorrect email address", message: "Make sure your email address is in the correct format.")
                    self.delegate?.errorEmpty()
                default:
                    self.delegate?.showAlert(title: "Error", message: "Please Check Your Information")
                    self.delegate?.errorEmpty()
                }
                return
            }
            
            self.delegate?.goToConversationPage()
            UserDefaults.standard.setValue(email, forKey: "email")
            UserDefaults.standard.setValue( "\(name)\(surname)", forKey: "name")
            
            let chatUser = ChatAppUser(firstName: name, lastName: surname, emailAddress: email)
            DatabaseManager.shared.insertUser(with: chatUser, completion: { success in
                if success {
                    
                    let data = profilePicture.pngData()
                    
                    let filename = chatUser.profilePictureFileName
                    
                    StorageManager.shared.uploadProfilePicture(with: data!, fileName: filename, completion: { result in
                        switch result {
                        case .success(let downloadUrl):
                            UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                            print(downloadUrl)
                        case .failure(let error):
                            print("Storage maanger error: \(error)")
                        }
                    })
                }
            })
            self.delegate?.goToConversationPage()
        }
        )}
}


