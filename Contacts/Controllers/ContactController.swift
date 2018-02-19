//
//  ContactController.swift
//  Contacts
//
//  Created by Peter Braun on 2/18/18.
//  Copyright © 2018 anDeRan. All rights reserved.
//

import UIKit
import CoreData
import AlecrimCoreData

class ContactController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let kCellId = "fieldCell"
    private let kDeleteButton = "deleteContact"
    private let kContactLabel = "contactID"
    private let kFieldKey   = 0
    private let kFieldValue = 1
    private let kCellTitleTag = 1
    private let kCellFieldTag = 2

    @IBOutlet weak var tableView: UITableView!
    public var contactObject: Contact?
    private var isEditMode: Bool!

    let fieldsArray:NSArray = {
        guard let fieldsPath = Bundle.main.path(forResource: "Fields", ofType: "plist"),
            let parsed = NSArray(contentsOfFile: fieldsPath) else {
            return []
        }
        return parsed
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        isEditMode = contactObject != nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Custom functions
    @IBAction func saveTapped() {
        let fields = NSMutableDictionary()
        for (row, value) in fieldsArray.enumerated() {
            let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0))
            if let field = cell?.viewWithTag(kCellFieldTag) as? UITextField,
                field.isEnabled == true,
                field.isHidden == false,
                let titles = value as? [String] {
                fields[titles[kFieldKey]] = field.text
            }
        }
        
        persistentContainer.performBackgroundTask { context in
            let contactID = self.isEditMode ? self.contactObject?.contactID : ""
            var record: Contact! = context.contact.first { $0.contactID == contactID }
            if !self.isEditMode {
                let randomID = NSUUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased().prefix(25)
                record = context.contact.create()
                record.contactID = String(randomID)
                record.createdAt = Date().timeIntervalSince1970
            }
            record.updatedAt = Date().timeIntervalSince1970

            for (key, value) in fields {
                record.setValue(value, forKey: key as! String)
            }

            do {
                try context.save()
            } catch {
                print("Save error: \(error)")
            }
        }

        navigationController?.popViewController(animated: true)
    }

    // MARK: - UITableViewDataSource functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fieldsArray.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var isHidden = false
        if !isEditMode, let titles = fieldsArray[indexPath.row] as? [String] {
            if titles[kFieldKey] == kDeleteButton || titles[kFieldKey] == kContactLabel {
                isHidden = true
            }
        }
        return isHidden ? 0 : tableView.rowHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellId, for: indexPath)

        if let titles = fieldsArray[indexPath.row] as? [String] {
            if titles[kFieldKey] == kDeleteButton {
                cell.textLabel?.text = titles[kFieldValue]
                cell.textLabel?.textColor = .red
                cell.textLabel?.textAlignment = .center
            } else {
                cell.selectionStyle = .none
                if let label = cell.viewWithTag(kCellTitleTag) as? UILabel {
                    label.text = titles[kFieldValue]
                    label.isHidden = false
                }
                if let field = cell.viewWithTag(kCellFieldTag) as? UITextField {
                    field.text = contactObject?.value(forKey: titles[kFieldKey]) as? String
                    field.isHidden = false
                    if titles[kFieldKey] == kContactLabel {
                        field.isEnabled = false
                    }
                }
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let titles = fieldsArray[indexPath.row] as? [String] {
            if titles[kFieldKey] == kDeleteButton {
                let alert = UIAlertController(title: "Are you sure?", message: "Do you want to delete record?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                    if let contact = self.contactObject {
                        persistentContainer.performBackgroundTask { context in
                            if let record = context.contact.first({ $0.contactID == contact.contactID! }) {
                                context.contact.delete(record)
                            }
                            do {
                                try context.save()
                            } catch {
                                print("Error on delete: \(error)")
                            }
                        }
                        self.navigationController?.popViewController(animated: true)
                    }
                }))
                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                present(alert, animated: true)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
