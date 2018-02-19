//
//  MainController.swift
//  Contacts
//
//  Created by Peter Braun on 2/18/18.
//  Copyright © 2018 anDeRan. All rights reserved.
//

import UIKit
import CoreData
import AlecrimCoreData

class MainController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    private let kCellId = "contactCell"
    private let kOpenContact = "openContact"

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        fetchRequestController.bind(to: self.tableView)

        self.fetchRequestController
            .didInsertObject { [weak self] _, _ in
                try? self?.fetchRequestController.refresh()
            }
            .didDeleteObject { [weak self] _, _ in
                try? self?.fetchRequestController.refresh()
            }

        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.indexPathsForSelectedRows?.forEach {
            tableView.deselectRow(at: $0, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Custom functions
    @IBAction func addTapped() {
        performSegue(withIdentifier: kOpenContact, sender: nil)
    }

    // MARK: - UITableViewDataSource functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchRequestController.numberOfObjects(inSection: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellId, for: indexPath)

        let contact = self.fetchRequestController.object(at: indexPath)
        if let firstName = contact.firstName, let lastName = contact.lastName {
            cell.textLabel?.text = String(indexPath.row + 1) + ". " + lastName + " " + firstName
        }

        cell.backgroundColor = indexPath.row % 2 == 1 ? nil : #colorLiteral(red: 0.947417674, green: 0.947417674, blue: 0.947417674, alpha: 1)

        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ContactController,
            let indexPath = tableView.indexPathForSelectedRow {
            destination.contactObject = self.fetchRequestController.object(at: indexPath)
        }
    }

    // MARK: - AlecrimCoreData functions
    fileprivate lazy var fetchRequestController: FetchRequestController<Contact> = {
        let query = persistentContainer.viewContext.contact.orderBy { $0.lastName }
        return query.toFetchRequestController()
    }()

    // MARK: - UISearchBar functions
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        do {
            if searchText.lengthOfBytes(using: .utf8) == 0 {
                try self.fetchRequestController.resetFilter()
            } else {
                try self.fetchRequestController.filter {
                    $0.lastName.beginsWith(searchText) || $0.firstName.beginsWith(searchText)
                }
            }
        } catch {
            print("Search error: \(error)")
        }
    }
}
