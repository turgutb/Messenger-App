//
//  LogInViewController.swift
//  Messenger-App
//
//  Created by MacBook on 12.02.2021.
//

import UIKit
import Firebase
import FirebaseAuth
import JGProgressHUD

class LogInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var loginViewModel = LoginViewModel()
    private let spinner = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool){
       super.viewWillAppear(animated)
       self.navigationController?.isNavigationBarHidden = true
      }
    
    override func viewWillDisappear(_ animated: Bool){
       super.viewWillDisappear(animated)
       self.navigationController?.isNavigationBarHidden = false
        emailTextField.text = ""
        passwordTextField.text = ""
      }
    
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        
        DispatchQueue.main.async {
            if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegisterViewController") as? RegisterViewController {
                if let navigator = self.navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        }
    }
    
    @IBAction func loginTapped (sender: AnyObject) {
        
        loginViewModel.login(email: emailTextField.text!, password: passwordTextField.text!)
        spinner.dismiss()

    }
    
    private func configureUI() {
        
        loginViewModel.delegate = self
        passwordTextField.isSecureTextEntry = true
        self.hideKeyboardWhenTappedAround()
        navigationController?.isNavigationBarHidden = true
    }
    
}

extension LogInViewController: LoginViewModelProtocol {
    func goToConversationPage() {
        
        DispatchQueue.main.async {
            if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ConversationViewController") as? ConversationViewController {
                if let navigator = self.navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let doneAction = UIAlertAction(title: "Done", style: .default, handler: nil)
            alert.addAction(doneAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func errorEmpty()  {
        emailTextField.text = ""
        passwordTextField.text = ""
    }
}


extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
