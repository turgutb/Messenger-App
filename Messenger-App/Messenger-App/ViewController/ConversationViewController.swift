//
//  MainConversationViewController.swift
//  Messenger-App
//
//  Created by MacBook on 14.02.2021.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

final class ConversationViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let conversationViewModel: ConversationViewModel = ConversationViewModel()
    
    @IBOutlet weak var tableView: UITableView!
    
    private let noConversationsLabel: UILabel = {
        let label = UILabel()
        label.text = "No Conversations!"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    private var loginObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.addSubview(noConversationsLabel)
        setupTableView()
        conversationViewModel.delegate = self
        conversationViewModel.startListeningForConversations()
        loginObserve()
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
    }
    
    @IBAction func newConversationButtonTapped(_ sender: Any) {
        
        let vc = NewConversationViewController()
        vc.completion = { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            
            let currentConversations = strongSelf.conversationViewModel.conversations
            
            if let targetConversation = currentConversations.first(where: {
                $0.otherUserEmail == DatabaseManager.safeEmail(emailAddress: result.email)
            }) {
                strongSelf.goToPage(email: targetConversation.otherUserEmail, id: targetConversation.otherUserEmail, name: targetConversation.name)
            }
            else {
                strongSelf.conversationViewModel.createNewConversation(result: result)
            }
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LogInViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ConversationCell", bundle: nil),forCellReuseIdentifier: "ConversationCell")
    }
    
}

extension ConversationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversationViewModel.numberOfRow()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversationViewModel.cellForRow(at: indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell",for: indexPath) as! ConversationCell
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = conversationViewModel.cellForRow(at: indexPath.row)
        goToPage(email: model.otherUserEmail, id: model.id, name: model.name)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let conversationId = conversationViewModel.cellForRow(at: indexPath.row).id
            tableView.beginUpdates()
            conversationViewModel.conversations.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            
            DatabaseManager.shared.deleteConversation(conversationId: conversationId, completion: { success in
                if !success {
                    
                }
            })
            tableView.endUpdates()
        }
    }
}


extension ConversationViewController: ConversationViewModelProtocol {
    
    
    func reloadData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func viewSettings(tableView: Bool, label: Bool) {
        noConversationsLabel.isHidden = tableView
        self.tableView.isHidden = label
    }
    
    func loginObserve() {
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.conversationViewModel.startListeningForConversations()
        })
    }
    
    func goToPage(email:String, id: String, name: String) {
        let vc = ConversationDetailViewController(with: email, id: id)
        vc.isNewConversation = true
        vc.title = name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}


