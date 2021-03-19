//
//  RegisterViewController.swift
//  Messenger-App
//
//  Created by MacBook on 12.02.2021.
//

import UIKit
import Firebase
import FirebaseAuth

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    
    
    
    var registerViewModel = RegisterViewModel()
    
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
        nameTextField.text = ""
        surnameTextField.text = ""
        profileImage.image = nil
        
      }
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        
        registerViewModel.register(name: nameTextField.text!, surname: surnameTextField.text!, email: emailTextField.text!, password: passwordTextField.text!, profilePicture: profileImage.image!)
        
    }
    
    @objc private func didTapChangeProfilePic() {
        presentPhotoActionSheet()
    }
    
    
    
    private func configureUI() {
        
        registerViewModel.delegate = self
        passwordTextField.isSecureTextEntry = true
        
        self.hideKeyboardWhenTappedAround()
        profileImage.isUserInteractionEnabled = true
        profileImage.layer.masksToBounds = true
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
     
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(didTapChangeProfilePic))
        profileImage.addGestureRecognizer(gesture)
    }

}

extension RegisterViewController: RegisterViewModelProtocol {
    
    func showAlert(title: String, message: String) {
        
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let doneAction = UIAlertAction(title: "Done", style: .default, handler: nil)
            alert.addAction(doneAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func goToConversationPage() {
        
        DispatchQueue.main.async {
            if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ConversationViewController") as? ConversationViewController {
                if let navigator = self.navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        }
    }
    
    func errorEmpty() {
        nameTextField.text = ""
        surnameTextField.text = ""
        emailTextField.text = ""
        passwordTextField.text = ""
    }
}


extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Profile Picture",
                                            message: "How would you like to select a picture?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo",
                                            style: .default,
                                            handler: { [weak self] _ in

                                                self?.presentCamera()

        }))
        actionSheet.addAction(UIAlertAction(title: "Choose Photo",
                                            style: .default,
                                            handler: { [weak self] _ in

                                                self?.presentPhotoPicker()

        }))

        present(actionSheet, animated: true)
    }

    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }

    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }

        self.profileImage.image = selectedImage
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

}

