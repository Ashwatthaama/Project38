//
//  DataSource.swift
//  Project38
//
//  Created by Niraj on 09/12/2019.
//  Copyright © 2019 Niraj. All rights reserved.
//

import UIKit
import CoreData

class DataSource: NSObject, UITableViewDataSource {

    static var shared: DataSource = DataSource()

    var detailsCoordinator: DetailsCoordinator?

    var fetchResultController: NSFetchedResultsController<Commit>!

    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchResultController.sections?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchResultController.sections![section]
        return sectionInfo.numberOfObjects
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchResultController.sections![section].name
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Commit", for: indexPath)

        let commit = fetchResultController.object(at: indexPath)
        cell.textLabel!.text = commit.message
        //  cell.detailTextLabel!.text = commit.date.description
        cell.detailTextLabel!.text = "By \(commit.author.name) on \(commit.date.description)"

        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let commit = fetchResultController.object(at: indexPath)
           // self.persistenceManager.context.delete(commit)
            //            commits.remove(at: indexPath.row)
            //            tableView.deleteRows(at: [indexPath], with: .fade)
            //persistenceManager.saveContext()
        }
    }



    //------------------------------------------------------------------------------
    // MARK: - Persistence & Network
    //------------------------------------------------------------------------------

    
}

