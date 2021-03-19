//
//  ConversationCell.swift
//  Messenger-App
//
//  Created by MacBook on 15.02.2021.
//

import UIKit
import Kingfisher


class ConversationCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2
        self.profileImage.clipsToBounds = true
        self.profileImage.layer.borderColor = UIColor.white.cgColor
        self.profileImage.layer.borderWidth = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func dateFormatter(date: Date) {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.string(from: date)
    }
    
    
    
    public func configure(with model: Conversation) {
        
        lastMessageLabel?.text = model.latestMessage.text
        nameLabel?.text = model.name
        
        let path = "images/\(model.otherUserEmail)_profile_picture.png"
        StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                    self?.profileImage?.kf.setImage(with: url)
                }
            case .failure(let error):
                print("failed to get image url: \(error)")
            }
        })
    }
}
