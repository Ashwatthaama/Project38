//
//  ViewController.swift
//  Project38
//
//  Created by Niraj on 03/12/2019.
//  Copyright © 2019 Niraj. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController {

    var container: NSPersistentContainer!
    var commitPredicate: NSPredicate?

    var commits = [Commit]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(changeFilter))
        container = NSPersistentContainer(name: "Project38")

        container.loadPersistentStores { (descriptor, error) in
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            if let error = error {
                print("Unresolved Error \(error)")
            }

        }

        performSelector(inBackground: #selector(fetchCommits), with: nil)
        loadSavedData()
    }

    func saveContext() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("An Error occured while saving: \(error)")
            }
        }
    }

    @objc func fetchCommits() {
        if let data = try? String(contentsOf: URL(string: "https://api.github.com/repos/apple/swift/commits?per_page=100")!)  {

            let jsonCommit = JSON(parseJSON: data)

            let jsonCommitArray = jsonCommit.arrayValue

            print("Received \(jsonCommitArray.count) new commits.")

            DispatchQueue.main.async { [unowned self] in
                for jsonCommit in jsonCommitArray {
                    let commit = Commit(context: self.container.viewContext)
                    self.configure(commit:commit, usingJSON:jsonCommit)
                }
                self.saveContext()
                self.loadSavedData()
            }
        }
    }

    func configure(commit:Commit, usingJSON json:JSON) {
        commit.sha = json["sha"].stringValue
        commit.message = json["commit"]["message"].stringValue
        commit.url = json["html_url"].stringValue

        let formatter = ISO8601DateFormatter()
        commit.date = formatter.date(from: json["commit"]["committer"]["date"].stringValue) ?? Date()
    }

    //------------------------------------------------------------------------------
    // MARK: - TableView Delegates
    //------------------------------------------------------------------------------

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commits.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Commit", for: indexPath)

        let commit = commits[indexPath.row]
        cell.textLabel!.text = commit.message
        cell.detailTextLabel!.text = commit.date.description

        return cell
    }

    func loadSavedData() {
        let request = Commit.createFetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]
        request.predicate = commitPredicate

        do {
            commits = try container.viewContext.fetch(request)
            print("Got \(commits.count) commits")
            tableView.reloadData()
        } catch  {
            print("Fetch Failed")
        }
    }

    @objc func changeFilter() {

        let ac = UIAlertController(title: "Filter Commits", message: nil, preferredStyle: .actionSheet)

        ac.addAction(UIAlertAction(title: "Show Only fixes", style: .default, handler: { [unowned self] _ in
            self.commitPredicate = NSPredicate(format: "message CONTAINS[c] 'fix'")
            self.loadSavedData()
        }))

        ac.addAction(UIAlertAction(title: "Ignore Pull Request", style: .default, handler: { [unowned self] _ in
            self.commitPredicate = NSPredicate(format: "NOT message BEGINSWITH 'Merge pull request'")
            self.loadSavedData()
        }))

        ac.addAction(UIAlertAction(title: "Recent Commits", style: .default, handler: { [unowned self] _ in
            let tewelveHoursAgo = Date().addingTimeInterval(-43200)
            self.commitPredicate = NSPredicate(format: "date > %@", tewelveHoursAgo as NSDate)
            self.loadSavedData()
        }))

        ac.addAction(UIAlertAction(title: "Show all commits", style: .default) { [unowned self] _ in
            self.commitPredicate = nil
            self.loadSavedData()
        })

        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }



}

