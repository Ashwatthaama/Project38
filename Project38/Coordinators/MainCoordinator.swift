//
//  MainCoordinator.swift
//  Project38
//
//  Created by Niraj on 10/12/2019.
//  Copyright © 2019 Niraj. All rights reserved.
//

import UIKit
import CoreData

class MainCoordinator: NSObject, Coordinator, PersistenceProtocol, NSFetchedResultsControllerDelegate {

    var childCoordinators: [Coordinator] = [Coordinator]()
    var navigationController: UINavigationController
    let persistenceManager = PersistenceService.sharedInstance()

     var commitPredicate: NSPredicate?



    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = ViewController.instantiate()
        vc.delegateCoordinator = self
        navigationController.pushViewController(vc, animated: true)
    }

    func showDetails(_ details:Commit) {
        let detailsCoordinator = DetailsCoordinator(navigationController: navigationController)
        detailsCoordinator.parentCoordinator = self
        detailsCoordinator.detailItem = details
        childCoordinators.append(detailsCoordinator)
        detailsCoordinator.start()
    }


    func saveData(_ data: Data) {

        let decoder = JSONDecoder()
        decoder.userInfo[CodingUserInfoKey.context] = persistenceManager.context
        do {
            let _ = try decoder.decode([Commit].self, from: data)
            persistenceManager.saveContext()
        }
        catch {
            print("Error")
        }
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


    func loadSavedData(_ completion:() -> Void?) {


        if DataSource.shared.fetchResultController == nil {
            let request = Commit.createFetchRequest()
            let sort = NSSortDescriptor(key: "author.name", ascending: false)
            request.sortDescriptors = [sort]
            request.fetchBatchSize = 50

            DataSource.shared.fetchResultController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: persistenceManager.context, sectionNameKeyPath: "author.name", cacheName: nil)
            DataSource.shared.fetchResultController.delegate = self
        }
        DataSource.shared.fetchResultController.fetchRequest.predicate = commitPredicate
        do {
            try DataSource.shared.fetchResultController.performFetch()
            //  print("Got \(commits.count) commits")
            completion()
           // tableView.reloadData()
        } catch  {
            print("Fetch Failed")
        }
    }

     func changeFilter() {

        let ac = UIAlertController(title: "Filter Commits", message: nil, preferredStyle: .actionSheet)

        ac.addAction(UIAlertAction(title: "Show Only fixes", style: .default, handler: { [unowned self] _ in
            self.commitPredicate = NSPredicate(format: "message CONTAINS[c] 'fix'")
            self.loadSavedData() {}
        }))

        ac.addAction(UIAlertAction(title: "Ignore Pull Request", style: .default, handler: { [unowned self] _ in
            self.commitPredicate = NSPredicate(format: "NOT message BEGINSWITH 'Merge pull request'")
            self.loadSavedData() { }
        }))

        ac.addAction(UIAlertAction(title: "Recent Commits", style: .default, handler: { [unowned self] _ in
            let tewelveHoursAgo = Date().addingTimeInterval(-43200)
            self.commitPredicate = NSPredicate(format: "date > %@", tewelveHoursAgo as NSDate)
            self.loadSavedData() { }
        }))

        ac.addAction(UIAlertAction(title: "Show all commits", style: .default) { [unowned self] _ in
            self.commitPredicate = nil
            self.loadSavedData() { }
        })

        ac.addAction(UIAlertAction(title: "Show only Durain Commit", style: .default, handler: { [unowned self] _ in
            self.commitPredicate = NSPredicate(format: "author.name == 'Joe Groff'")
            self.loadSavedData() { }
        }))

        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.navigationController.present(ac, animated: true)
    }

    
}
