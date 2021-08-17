//
//  addCityViewController.swift
//  tripplanner
//
//  Created by user196869 on 8/12/21.
//

import Foundation
import UIKit
import CoreData

protocol addTripDelegate : NSObjectProtocol{
    func updateView ()
}

class addCityViewController:UIViewController
{
    weak var addTripDelegate: addTripDelegate?
    var selectedTrip: TripInfo?
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtCity: UITextField!
    @IBOutlet weak var btnAddEnable: UIButton!
    @IBOutlet weak var txtToDo: UITextField!
    @IBOutlet weak var todoTV: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        txtName.text = selectedTrip?.name ?? ""
        txtCity.text = selectedTrip?.city ?? ""
        print(selectedTrip?.orderPos)
    }
    
    @IBAction func txtdidchange(_ sender: Any) {
        if txtCity.hasText && txtName.hasText
        {
            btnAddEnable.isEnabled = true
            btnAddEnable.backgroundColor = UIColor.green
        }
        else
        {
            btnAddEnable.isEnabled = false
            btnAddEnable.backgroundColor = UIColor.gray
        }
    }
    @IBAction func btnAdd(_ sender: Any) {
        //only added cities that work with api
        Validation.shared.validateCity(city: txtCity.text!){(valid) in
            DispatchQueue.main.async {[unowned self] in
                if (valid)
                {
                    let alert = UIAlertController(title: "Confirmation", message: "\(txtName.text!), \(txtCity.text!) changes to be updated!",
                                                  preferredStyle: UIAlertController.Style.alert)
                    // Cancel button to not add
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
                    //ok button to save to core data
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {(UIAlertAction) in
                        //save to core data
                        if (self.txtCity.hasText && self.txtName.hasText)
                        {
                            if (self.selectedTrip == nil)
                            {
                                let context = CoreDataStack.shared.persistentContainer.viewContext
                                let fetch : NSFetchRequest<TripInfo> = TripInfo.fetchRequest()
                                let thisTrip = TripInfo(context: context)
                                thisTrip.name = self.txtName.text
                                thisTrip.city = self.txtCity.text
                                if let tripData = try? context.fetch(fetch) as [NSManagedObject]
                                {
                                    thisTrip.orderPos = Int16(tripData.count - 1)
                                }
                                else
                                {
                                    thisTrip.orderPos = 0
                                }
                                self.selectedTrip = thisTrip
                            }
                            else
                            {
                                self.selectedTrip?.city = self.txtCity.text
                                self.selectedTrip?.name = self.txtName.text
                            }
                            
                            self.addTripDelegate?.updateView()
                            CoreDataStack.shared.saveContext()
                        }
                    })
                    // show the alert
                    self.present(alert, animated: true, completion: nil)
                }
//                else
//                {
//                    let alert = UIAlertController(title: "Not supported!", message: "\(self.txtCity.text!) is currently not supported!",
//                                                  preferredStyle: UIAlertController.Style.alert)
//                    // Cancel button to not add
//                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
//                    self.present(alert, animated: true, completion: nil)
//                }
            }
        }
    }
    @IBAction func btnAddTodo(_ sender: Any) {
        if (self.txtCity.hasText && self.txtName.hasText)
        {
            if (self.txtToDo.hasText)
            {
                var todolist:[String]?
                if (self.selectedTrip?.todo == nil)
                {
                    todolist = [String]()
                }
                else
                {
                    todolist = self.selectedTrip?.todo
                }
                todolist? .append(self.txtToDo.text!)
                self.txtToDo.text = nil
                self.selectedTrip?.todo = todolist
                self.todoTV.reloadData()
                CoreDataStack.shared.saveContext()
            }
        }
    }
}


extension addCityViewController:UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedTrip?.todo?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath)
        cell.textLabel?.text = selectedTrip?.todo?[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal,
                                                title: "Delete") { [unowned self] (action, view, completionHandler) in
            selectedTrip?.todo?.remove(at: indexPath.row)
                                       self.todoTV.reloadData()
        }
              //action color
            action.backgroundColor = UIColor.systemRed
              //swipe action
              return UISwipeActionsConfiguration(actions: [action])
    }
    
}
