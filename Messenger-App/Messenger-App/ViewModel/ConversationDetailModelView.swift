//
//  ConversationDetailModelView.swift
//  Messenger-App
//
//  Created by MacBook on 18.03.2021.
//

import Foundation
import MessageKit

protocol ConversationDetailViewProtocol {

    func messageReload(shouldScrollToBottom: Bool)
    func inputBarClear()
    
}


class ConversationDetailViewModel: MessagesViewController {
    
    var delegate: ConversationDetailViewProtocol?
    
    public var otherUserPhotoURL: URL?
    public var otherUserEmail: String?
//    public var isNewConversation: Bool = false
    public var conversationId: String?
    public var senderPhotoURL: URL?
    public var messages = [Message]()

    
    
    func numberOfRow() -> Int {
        return messages.count
    }
    
    func cellForRow(at indexPath: IndexPath) -> Message {
        return messages[indexPath.section]
    }
    
    
    var selfSender: Sender? {
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        return Sender(photoURL: "",
                      senderId: safeEmail,
                      displayName: "Me")
        
    }
    
    func sendButtonTapped(text: String, title: String, isNewConversation: Bool) {
        
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let selfSender = self.selfSender,
              let messageId = createMessageId(),
              let otherUserEmail = otherUserEmail else {
            return
        }
        
        print("Sending: \(text)")
        
        let message = Message(sender: selfSender,
                              messageId: messageId,
                              sentDate: Date(),
                              kind: .text(text))
        self.delegate?.inputBarClear()
        
        if isNewConversation {
            
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, name: title ?? "User", firstMessage: message, completion: { [weak self] success in
                if success {
                    print("message sent")
                    var isNewConversation = isNewConversation
                    isNewConversation = false
                    let newConversationId = "conversation_\(message.messageId)"
                    self?.conversationId = newConversationId
                    self?.listenForMessages(id: newConversationId, shouldScrollToBottom: true)
                    self?.delegate?.inputBarClear()
                }
                else {
                    print("failed to send")
                }
            })
        }
        else {
            guard let conversationId = conversationId else {
                return
            }

            DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: otherUserEmail, name: title, newMessage: message, completion: { [weak self] success in
                if success {
                    self?.delegate?.inputBarClear()
                    print("message sent")
                }
                else {
                    print("failed to send")
                }
            })
        }
    }
    
    func createMessageId() -> String? {
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String,
              let otherUserEmail = otherUserEmail else {
            return nil
        }
               
        let safeCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        let dateString = DatabaseManager.dateFormatter.string(from: Date())
        let newIdentifier = "\(otherUserEmail)_\(safeCurrentEmail)_\(dateString)"
        
        print("created message id: \(newIdentifier)")
        
        return newIdentifier
        
    }
    
     func listenForMessages(id: String, shouldScrollToBottom: Bool) {
        
        DatabaseManager.shared.getAllMessagesForConversation(with: id, completion: { [weak self] result in
            switch result {
            case .success(let messages):
                print("success in getting messages: \(messages)")
                guard !messages.isEmpty else {
                    print("messages are empty")
                    return
                }
                self?.messages = messages
                self?.delegate?.messageReload(shouldScrollToBottom: shouldScrollToBottom)
                case .failure(let error):
                print("failed to get messages: \(error)")
                
            }
        })
    }
    
    func sendPhotoMessage(with data: Data, fileName: String, messageId: String, title: String) {
        
        guard let conversationId = conversationId,
              let otherUserEmail = otherUserEmail,
              
              let selfSender = selfSender else {
                return
        }
        
        StorageManager.shared.uploadMessagePhoto(with: data, fileName: fileName, completion: { result in
     
            switch result {
            case .success(let urlString):
                print("Uploaded Message Photo: \(urlString)")

                guard let url = URL(string: urlString),
                    let placeholder = UIImage(systemName: "plus") else {
                        return
                }

                let media = Media(url: url,
                                  image: nil,
                                  placeholderImage: placeholder,
                                  size: .zero)

                let message = Message(sender: selfSender,
                                      messageId: messageId,
                                      sentDate: Date(),
                                      kind: .photo(media))

                DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: otherUserEmail, name: title, newMessage: message, completion: { success in

                    if success {
                        print("sent photo message")
                    }
                    else {
                        print("failed to send photo message")
                    }
                })

            case .failure(let error):
                print("message photo upload error: \(error)")
            }
        })
        
    }
    
    
    func sendVideoMessege(with fileURL: URL, fileName: String, messageId: String, title: String) {
        
        guard let conversationId = conversationId,
            let name = self.title,
            let selfSender = selfSender else {
                return
        }
        
        StorageManager.shared.uploadMessageVideo(with: fileURL, fileName: fileName, completion: { [weak self] result in
            guard let strongSelf = self else {
                return
            }

            switch result {
            case .success(let urlString):

                print("Uploaded Message Video: \(urlString)")

                guard let url = URL(string: urlString),
                    let placeholder = UIImage(systemName: "plus") else {
                        return
                }

                let media = Media(url: url,
                                  image: nil,
                                  placeholderImage: placeholder,
                                  size: .zero)

                let message = Message(sender: selfSender,
                                      messageId: messageId,
                                      sentDate: Date(),
                                      kind: .video(media))

                DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: strongSelf.otherUserEmail!, name: name, newMessage: message, completion: { success in

                    if success {
                        print("sent photo message")
                    }
                    else {
                        print("failed to send photo message")
                    }
                })
            case .failure(let error):
                print("message photo upload error: \(error)")
            }
        })
    }
    
    func configureAvatar(avatarView: UIImageView, message: MessageType) {
        
        let sender = message.sender
        if sender.senderId == selfSender?.senderId {
            
            if let currentUserImageURL = self.senderPhotoURL {
                avatarView.kf.setImage(with: currentUserImageURL)
            }
            else {
                guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
                    return
                }
                
                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                let path = "images/\(safeEmail)_profile_picture.png"
                
                StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
                    switch result {
                    case .success(let url):
                        self?.senderPhotoURL = url
                        DispatchQueue.main.async {
                            avatarView.kf.setImage(with: url)
                        }
                    case .failure(let error):
                        print("\(error)")
                    }
                })
            }
        }
        
        else {
            
            if let otherUserPhotoURL = self.otherUserPhotoURL {
                avatarView.kf.setImage(with: otherUserPhotoURL)
            }
            else {
                let email = self.otherUserEmail
                let safeEmail = DatabaseManager.safeEmail(emailAddress: email!)
                let path = "images/\(safeEmail)_profile_picture.png"
                
                StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
                    
                    switch result {
                    case .success(let url):
                        self?.otherUserPhotoURL = url
                        
                        DispatchQueue.main.async {
                            avatarView.kf.setImage(with: url)
                        }
                        
                    case .failure(let error):
                        print("\(error)")
                    }
                })
            }
        }
    }
}






