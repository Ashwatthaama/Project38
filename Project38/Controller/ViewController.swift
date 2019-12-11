//
//  ViewController.swift
//  Project38
//
//  Created by Niraj on 03/12/2019.
//  Copyright © 2019 Niraj. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController, Storyboarded {

   // var dataSource = DataSource.shared

    var delegateCoordinator: MainCoordinator?

    let networkManager = NetworkManager.sharedInstance()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = DataSource.shared
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(changeFilter))
    
        performSelector(inBackground: #selector(fetchCommits), with: nil)
        delegateCoordinator!.loadSavedData {
            self.tableView.reloadData()
        }
    }


    @objc func fetchCommits() {

        let newestCommitDate = delegateCoordinator?.getNewestCommitDate()

        let urlPath = URL(string: "https://api.github.com/repos/apple/swift/commits?per_page=100&since=\(newestCommitDate ?? "")")

        networkManager.requestData(for: urlPath!) { [weak self] result in

            guard let self = self else { return }
            switch result {
            case .success(let data):
                self.delegateCoordinator?.saveData(data)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }

            case .failure(let error):
                print(error)
            }

        }
    }
    
   
//    func configure(commit:Commit, usingJSON json:JSON) {
//        commit.sha = json["sha"].stringValue
//       // commit.message = json["commit"]["message"].stringValue
//        commit.url = json["html_url"].stringValue
//
//        let formatter = ISO8601DateFormatter()
//        commit.date = formatter.date(from: json["commit"]["committer"]["date"].stringValue) ?? Date()
//
//        var commitAuthor: Author!
//
//        // see if this author exists already
//        let authorRequest = Author.createFetchRequest()
//        authorRequest.predicate = NSPredicate(format: "name == %@", json["commit"]["committer"]["name"].stringValue)
//
//        if let authors = try? persistenceManager.context.fetch(authorRequest) {
//            if authors.count > 0 {
//                // we have this author already
//                commitAuthor = authors[0]
//            }
//        }
//
//        if commitAuthor == nil {
//            // we didn't find a saved author - create a new one!
//            let author = Author(context: persistenceManager.context)
//            author.name = json["commit"]["committer"]["name"].stringValue
//            author.email = json["commit"]["committer"]["email"].stringValue
//            commitAuthor = author
//        }
//
//        // use the author, either saved or new
//      //  commit.author = commitAuthor
//    }


    //------------------------------------------------------------------------------
    // MARK: - TableView Delegates
    //------------------------------------------------------------------------------

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       delegateCoordinator?.showDetails(DataSource.shared.fetchResultController.object(at: indexPath))

    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        default:
            break
        }
    }

    @objc func changeFilter() {
        delegateCoordinator?.changeFilter()
    }

}

