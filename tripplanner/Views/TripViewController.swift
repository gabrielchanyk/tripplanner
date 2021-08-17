//
//  TripViewController.swift
//  tripplanner
//
//  Created by user196869 on 8/12/21.
//

import Foundation
import UIKit
import CoreData

class TripViewController: UITableViewController {
    
    //fetch controller
    lazy var tripFRC : NSFetchedResultsController<TripInfo> = {
        //fetch request
        let fetch : NSFetchRequest<TripInfo> = TripInfo.fetchRequest()
        //cant do multi sort
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        let orderSort = NSSortDescriptor(key: "orderPos", ascending: true)
        fetch.sortDescriptors = [nameSort , orderSort]
        //set fetch params and put to fetch conroller
        let fetchRcontroller = NSFetchedResultsController(fetchRequest: fetch, managedObjectContext: CoreDataStack.shared.persistentContainer.viewContext, sectionNameKeyPath: "name", cacheName: nil)
        return fetchRcontroller
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //fetch data
        try? tripFRC.performFetch()
        //fetch table
        tableView.reloadData()
        self.navigationItem.leftBarButtonItem = self.editButtonItem
    }
    
    @IBAction func btnRefresh(_ sender: Any) {
        try? tripFRC.performFetch()
        //fetch table
        tableView.reloadData()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // return the number of sections
        return tripFRC.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // the number of rows
        return tripFRC.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //title for section in this case country
        return tripFRC.sections?[section].name ?? ""
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //set cell to custom cell class
        let cell = tableView.dequeueReusableCell(withIdentifier: "tripCell", for: indexPath) as! tripTableViewCell
        cell.thisTrip = tripFRC.object(at: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //height of rows
        return 80
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete
        {
            let deleteFetchRequest : NSFetchRequest<TripInfo> = TripInfo.fetchRequest()
                           //add predicates
                           let namePre = NSPredicate(format: "name == %@", self.tripFRC.object(at: indexPath).name!)
                           let cityPre = NSPredicate(format: "city == %@",self.tripFRC.object(at: indexPath).city!)
                           //set predicates to fetch request
                           deleteFetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [namePre,cityPre])
                           //set view context constant
                           let context = CoreDataStack.shared.persistentContainer.viewContext
                           if let results = try? context.fetch(deleteFetchRequest) as [NSManagedObject] {
                               // Delete trip
                               for trip in results {
                                   context.delete(trip)
                               }
                               //save results
                               CoreDataStack.shared.saveContext()
                               //fetch data
                               try? tripFRC.performFetch()
                               //reload
                               self.tableView.reloadData()
                           }
        }
    }
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //move row and save order
//    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        let moveFetchRequest : NSFetchRequest<TripInfo> = TripInfo.fetchRequest()
//        let context = CoreDataStack.shared.persistentContainer.viewContext
//        if let results = try? context.fetch(moveFetchRequest) as [TripInfo] {
//            if sourceIndexPath.row > destinationIndexPath.row
//            {
//                for i in destinationIndexPath.row..<sourceIndexPath.row
//                {
//                    if (results[i] != results[sourceIndexPath.row])
//                    {
//                        results[i].orderPos = Int16(i+1)
//                    }
//                }
//            }
//            else if sourceIndexPath.row < destinationIndexPath.row
//            {
//                let source = sourceIndexPath.row + 1
//                for i in stride(from: source, through: destinationIndexPath.row, by: -1)
//                {
//                    if (results[i] != results[sourceIndexPath.row])
//                    {
//                        results[i].orderPos = Int16(i-1)
//                    }
//
//                }
//            }
//            results[sourceIndexPath.row].orderPos = Int16(destinationIndexPath.row)
//            //save results
//            CoreDataStack.shared.saveContext()
//            //fetch data
//            try? tripFRC.performFetch()
//            //reload
//            self.tableView.reloadData()
//        }
//
//
//    }
}
extension TripViewController:addTripDelegate
{
    //delegate function
    func updateView() {
        try? tripFRC.performFetch()
        tableView.reloadData()
    }
    //sending info to list view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "addSegue")
        {
            let addVC = segue.destination as! addCityViewController
            addVC.addTripDelegate = self
        }
        //set info to weather view controller
        else if (segue.identifier == "editSegue")
        {
            let editVC = segue.destination as! addCityViewController
            editVC.addTripDelegate = self
            //set selected index path
            let selectedIndexPath = tableView.indexPath(for: sender as! UITableViewCell)
            //send selected city data obj
            editVC.selectedTrip = tripFRC.object(at: selectedIndexPath!)
        }
    }
}
