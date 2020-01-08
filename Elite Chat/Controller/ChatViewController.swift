//
//  ChatViewController.swift
//  Elite Chat
//
//  Created by Mustafa on 07/01/20.
//  Copyright © 2020 Mustafa. All rights reserved.
//

import UIKit
import Firebase
class ChatViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    var messages:[Message] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var messageTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        title = "⚡️ELITE CHAT"
        navigationItem.hidesBackButton = true
        tableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "reusableCell")
        loadMessages()
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        if let messageBody = messageTextField.text, let messageSender = Auth.auth().currentUser?.email {
            db.collection("messages").addDocument(data: ["sender" : messageSender, "body":messageBody, "date": Date().timeIntervalSince1970]) { (error) in
                if let e = error {
                    print("There's an Error \(e) while saving")
                } else {
                    DispatchQueue.main.async {
                        self.messageTextField.text = ""
                    }
                    
                    print("Succesfully Saved")
                }
            }
        }
    }
    
    func loadMessages(){
        db.collection("messages").order(by: "date").addSnapshotListener { (querySnapshot, error) in
            self.messages = []
            if let e = error {
                print(e)
            } else {
                if let snapShot = querySnapshot?.documents {
                    for doc in snapShot {
                        let data = doc.data()
                        if let messageSender = data["sender"] as? String, let messageBody = data["body"] as? String {
                            let newMessage = Message(body: messageBody, sender: messageSender)
                            self.messages.append(newMessage)
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                let indexpath = IndexPath(row: self.messages.count - 1, section: 0)
                                self.tableView.scrollToRow(at: indexpath, at: .top, animated: false)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
}

extension ChatViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier:"reusableCell" , for: indexPath) as! MessageCell
        cell.messageLabel.text = data.body
        if data.sender == Auth.auth().currentUser?.email {
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.messageBackground.backgroundColor = UIColor(named: "BrandLightPurple")
            cell.messageLabel.textColor = UIColor(named: "BrandPurple")
        } else {
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.messageBackground.backgroundColor = UIColor(named: "BrandPurple")
            cell.messageLabel.textColor = UIColor(named: "BrandLightPurple")
        }
        return cell
    }
}

