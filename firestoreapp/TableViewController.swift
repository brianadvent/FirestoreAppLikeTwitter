//
//  TableViewController.swift
//  firestoreapp
//
//  Created by Brian Advent on 02.10.17.
//  Copyright © 2017 Brian Advent. All rights reserved.
//

import UIKit
import Firestore

class TableViewController: UITableViewController {

    var db:Firestore!
    
    var sweetArray = [Sweet]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        db = Firestore.firestore()
        loadData()
        checkForUpdates()
        
       
    }
    
    func loadData() {
        db.collection("sweets").getDocuments() {
            querySnapshot, error in
            if let error = error {
                print("\(error.localizedDescription)")
            }else{
                self.sweetArray = querySnapshot!.documents.flatMap({Sweet(dictionary: $0.data())})
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        
        
    }
    
    func checkForUpdates() {
        db.collection("sweets").whereField("timeStamp", isGreaterThan: Date())
            .addSnapshotListener {
                querySnapshot, error in
                
                guard let snapshot = querySnapshot else {return}
                
                snapshot.documentChanges.forEach {
                    diff in
                    
                    if diff.type == .added {
                        self.sweetArray.append(Sweet(dictionary: diff.document.data())!)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
                
        }
    }
    
    
    @IBAction func composeSweet(_ sender: Any) {
        
        let composeAlert = UIAlertController(title: "New Sweet", message: "Enter your name and message", preferredStyle: .alert)
        
        composeAlert.addTextField { (textField:UITextField) in
            textField.placeholder = "Your name"
        }
        
        composeAlert.addTextField { (textField:UITextField) in
            textField.placeholder = "Your message"
        }
        
        composeAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        composeAlert.addAction(UIAlertAction(title: "Send", style: .default, handler: { (action:UIAlertAction) in
            
            if let name = composeAlert.textFields?.first?.text, let content = composeAlert.textFields?.last?.text {
                
                let newSweet = Sweet(name: name, content: content, timeStamp: Date())
                
                var ref:DocumentReference? = nil
                ref = self.db.collection("sweets").addDocument(data: newSweet.dictionary) {
                    error in
                    
                    if let error = error {
                        print("Error adding document: \(error.localizedDescription)")
                    }else{
                        print("Document added with ID: \(ref!.documentID)")
                    }
                    
                }
                
            }
            
        }))
        
        self.present(composeAlert, animated: true, completion: nil)
        
        
    }
    


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sweetArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let sweet = sweetArray[indexPath.row]
        
        cell.textLabel?.text = "\(sweet.name): \(sweet.content)"
        cell.detailTextLabel?.text = "\(sweet.timeStamp)"

        return cell
    }
    

    

}
