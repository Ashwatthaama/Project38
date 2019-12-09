//
//  ViewController.swift
//  Project38
//
//  Created by Niraj on 03/12/2019.
//  Copyright © 2019 Niraj. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    
    var commitPredicate: NSPredicate?

    let persistenceManager = PersistenceService.sharedInstance()

    var fetchResultController: NSFetchedResultsController<Commit>!

    let networkManager = NetworkManager.sharedInstance()

  //  var commits = [Commit]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(changeFilter))
    
        performSelector(inBackground: #selector(fetchCommits), with: nil)
        loadSavedData()
    }



    @objc func fetchCommits() {

        let newestCommitDate = getNewestCommitDate()

        let urlPath = URL(string: "https://api.github.com/repos/apple/swift/commits?per_page=100&since=\(newestCommitDate)")


        networkManager.requestData(for: urlPath!) { result in

            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                decoder.userInfo[CodingUserInfoKey.context] = self.persistenceManager.context
                do {
                   let _ = try decoder.decode([Commit].self, from: data)
                   self.persistenceManager.saveContext()
                }
                catch {
                    print("Error")
                }
            case .failure(let error):
                print(error)
            }

        }
    }

    func configure(commit:Commit, usingJSON json:JSON) {
        commit.sha = json["sha"].stringValue
       // commit.message = json["commit"]["message"].stringValue
        commit.url = json["html_url"].stringValue

        let formatter = ISO8601DateFormatter()
        commit.date = formatter.date(from: json["commit"]["committer"]["date"].stringValue) ?? Date()

        var commitAuthor: Author!

        // see if this author exists already
        let authorRequest = Author.createFetchRequest()
        authorRequest.predicate = NSPredicate(format: "name == %@", json["commit"]["committer"]["name"].stringValue)

        if let authors = try? persistenceManager.context.fetch(authorRequest) {
            if authors.count > 0 {
                // we have this author already
                commitAuthor = authors[0]
            }
        }

        if commitAuthor == nil {
            // we didn't find a saved author - create a new one!
            let author = Author(context: persistenceManager.context)
            author.name = json["commit"]["committer"]["name"].stringValue
            author.email = json["commit"]["committer"]["email"].stringValue
            commitAuthor = author
        }

        // use the author, either saved or new
      //  commit.author = commitAuthor
    }

    func getNewestCommitDate() -> String {
        let formatter = ISO8601DateFormatter()

        let newestRequest = Commit.createFetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        newestRequest.sortDescriptors = [sort]
        newestRequest.fetchLimit = 1

        if let commits = try? persistenceManager.context.fetch(newestRequest) {
            if commits.count > 0 {
                return formatter.string(from: commits[0].date.addingTimeInterval(1))
            }
        }
        return formatter.string(from: Date(timeIntervalSince1970: 0))
    }

    //------------------------------------------------------------------------------
    // MARK: - TableView Delegates
    //------------------------------------------------------------------------------

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchResultController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchResultController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Commit", for: indexPath)

        let commit = fetchResultController.object(at: indexPath)
        cell.textLabel!.text = commit.message
      //  cell.detailTextLabel!.text = commit.date.description
        cell.detailTextLabel!.text = "By \(commit.author.name) on \(commit.date.description)"

        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let commit = fetchResultController.object(at: indexPath)
            self.persistenceManager.context.delete(commit)
//            commits.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
             persistenceManager.saveContext()
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchResultController.sections![section].name
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.detailItem = fetchResultController.object(at: indexPath)
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        default:
            break
        }
    }


    func loadSavedData() {

        if fetchResultController == nil {
            let request = Commit.createFetchRequest()
            let sort = NSSortDescriptor(key: "author.name", ascending: false)
            request.sortDescriptors = [sort]
            request.fetchBatchSize = 50

            fetchResultController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: persistenceManager.context, sectionNameKeyPath: "author.name", cacheName: nil)
            fetchResultController.delegate = self
        }
        fetchResultController.fetchRequest.predicate = commitPredicate
        do {
            try fetchResultController.performFetch()
          //  print("Got \(commits.count) commits")
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

        ac.addAction(UIAlertAction(title: "Show only Durain Commit", style: .default, handler: { [unowned self] _ in
            self.commitPredicate = NSPredicate(format: "author.name == 'Joe Groff'")
            self.loadSavedData()
        }))

        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }



}

