//
//  User.swift
//  Messenger-App
//
//  Created by MacBook on 12.02.2021.
//

import Foundation
import MessageKit
import CoreLocation
import UIKit


struct Message: MessageType {
    
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
    
}

extension MessageKind {
    var messageKindString: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "linkPreview"
        case .custom(_):
            return "custom"
        }
    }
}
//enum MessageType {
//    case Video
//    case Photo
//}



struct Sender: SenderType {
    
    public var photoURL: String
    public var senderId: String
    public var displayName: String
    
}

struct Media: MediaItem {

    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
}

struct SearchResult {
    let name: String
    let email: String
}


struct Conversation {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}

struct Location: LocationItem {
    var location: CLLocation
    var size: CGSize
}

extension Notification.Name {
    static let didLogInNotification = Notification.Name("didLogInNotification")
}

extension UIView {

    public var width: CGFloat {
        return frame.size.width
    }

    public var height: CGFloat {
        return frame.size.height
    }

    public var top: CGFloat {
        return frame.origin.y
    }

    public var bottom: CGFloat {
        return frame.size.height + frame.origin.y
    }

    public var left: CGFloat {
        return frame.origin.x
    }

    public var right: CGFloat {
        return frame.size.width + frame.origin.x
    }

}


//
//struct ChatAppUser {
//    
//    let firstName: String
//    let lastName: String
//    let emailAddress: String
//    
//    
//    
//    var safeEmail: String {
//        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
//        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
//        return safeEmail
//    }
//    
//}
