//
//  ConversationViewModel.swift
//  
//
//  Created by MacBook on 17.03.2021.
//

import Foundation

protocol ConversationViewModelProtocol  {
    
    func reloadData()
    func viewSettings(tableView: Bool, label: Bool)
    func loginObserve()
    func goToPage(email:String, id: String, name: String)
    
}

class ConversationViewModel {
    
    var conversations = [Conversation]()
    var delegate: ConversationViewModelProtocol?
    
    func numberOfRow() -> Int {
        return conversations.count
    }
    
    func cellForRow(at index: Int) -> Conversation {
        return conversations[index]
    }
    
    func startListeningForConversations() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        if let observer = delegate?.loginObserve {
            NotificationCenter.default.removeObserver(observer)
        }
        
        print("starting conversation fetch...")
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        DatabaseManager.shared.getAllConversations(for: safeEmail, completion: { [weak self] result in
            switch result {
            case .success(let conversation):
                print("successfully got conversation models")
                guard !conversation.isEmpty else {
                    self?.delegate?.viewSettings(tableView: true, label: false)
                    return
                }
                self?.delegate?.viewSettings(tableView: true, label: false)
                self?.conversations = conversation
                self?.delegate?.reloadData()
                
            case .failure(let error):
                self?.delegate?.viewSettings(tableView: true, label: false)
                print("failed: \(error)")
            }
        })
    }
    
    func createNewConversation(result: SearchResult) {
        let name = result.name
        let email = DatabaseManager.safeEmail(emailAddress: result.email)
        
        DatabaseManager.shared.conversationExists(with: email, completion: { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            switch result {
            case .success(let conversationId):
                strongSelf.delegate?.goToPage(email: email, id: conversationId, name: name)
               
            case .failure(_):
                strongSelf.delegate?.goToPage(email: email, id: "", name: name)
            }
        })
    }
}
