//
//  ViewController.swift
//  ListAppp
//
//  Created by Zehra Coşkun on 20.01.2023.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var alertController = UIAlertController()
    
    var data = [NSManagedObject]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        fetch()
    }
    
    
    @IBAction func didRemoveBarButtonItemTapped( _ sender: UIBarButtonItem)
    {
        presentAlert(title: "Uyarı",
                     message: "Bütün listeyi silmek üzeresin",
                     defaultButtonTitle: "Sil gitsin",
                     cancelButtonTitle: "Yapma dur",
                     defaultButtonHandler: { _ in
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let managedObjectContext = appDelegate?.persistentContainer.viewContext
            for item in self.data
            {managedObjectContext?.delete(item)}
            try? managedObjectContext?.save()
            self.fetch()
                                           }
                    )
    }
    
    @IBAction func didAddBarButtonItemTapped( _ sender: UIBarButtonItem)
    {
        presentAddAlert()
    }
    func presentAddAlert()
    {
        presentAlert(title: "Yeni item ekle",
                     message: nil,
                     defaultButtonTitle: "Ekle",
                     cancelButtonTitle: "Vazgeç",
                     isTextFieldAvailable: true,
                     defaultButtonHandler: { _ in
            let text = self.alertController.textFields?.first?.text
            if text != ""
            {
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                let managedObjectContext = appDelegate?.persistentContainer.viewContext
                let entity = NSEntityDescription.entity(forEntityName: "ListItem", in:  managedObjectContext!)
                let ListItem = NSManagedObject(entity: entity!, insertInto: managedObjectContext)
                ListItem.setValue(text, forKey: "title")
                try? managedObjectContext?.save()
                self.fetch()
            }
            else
            {
                self.presentWarningAlert()
            }
        })
    }
    
    func presentWarningAlert()
    {
        presentAlert(title: "Uyarı",
                     message: "Boş item ekleyemezsin !",
                     preferredStyle: .alert,
                     cancelButtonTitle: "Peki",
                     isTextFieldAvailable: false)
    }
    
    func presentAlert ( title: String?,
                        message: String?,
                        preferredStyle: UIAlertController.Style = .alert,
                        defaultButtonTitle: String? = nil,
                        cancelButtonTitle: String?,
                        isTextFieldAvailable: Bool = false,
                        defaultButtonHandler: ((UIAlertAction) -> Void)? = nil)
    {
        alertController = UIAlertController(title: title,
                                            message: message,
                                            preferredStyle: preferredStyle)
        if defaultButtonTitle != nil
        {
            let defaultButton = UIAlertAction(title: defaultButtonTitle,
                                              style: .default,
                                              handler: defaultButtonHandler)
            alertController.addAction(defaultButton )
        }
        
        let cancelButton = UIAlertAction(title: cancelButtonTitle, style: .cancel)
        
        if isTextFieldAvailable {alertController.addTextField()}
        
        
        alertController.addAction(cancelButton)
        present(alertController, animated: true)
    }
    func fetch ()
    {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedObjectContext = appDelegate?.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject >(entityName: "ListItem")
        data = try! managedObjectContext!.fetch(fetchRequest)
        tableView.reloadData()
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
        let ListItem = data[indexPath.row]
        cell.textLabel?.text = ListItem.value(forKey: "title") as? String
        return cell
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .normal,
                                              title: "Sil") { _, _, _ in
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let managedObjectContext = appDelegate?.persistentContainer.viewContext
            managedObjectContext?.delete(self.data[indexPath.row])
            try? managedObjectContext?.save()
            self.fetch()
        }
        deleteAction.backgroundColor = .systemRed
        
        let editAction = UIContextualAction(style: .normal,
                                            title: "Düzenle") { _, _, _ in
            self.presentAlert(title: "Düzenle",
                              message: nil,
                              defaultButtonTitle: "Düzenle",
                              cancelButtonTitle: "Vazgeç",
                              isTextFieldAvailable: true,
                              defaultButtonHandler: { _ in
                let text = self.alertController.textFields?.first?.text
                if text != ""
                {
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    let managedObjectContext = appDelegate?.persistentContainer.viewContext
                    self.data[indexPath.row].setValue(text, forKeyPath: "title")
                    if managedObjectContext!.hasChanges
                    {
                        try? managedObjectContext?.save()
                    }
                    self.tableView.reloadData()
                }
                else
                {
                    self.presentWarningAlert()
                }
            })
        }
        editAction.backgroundColor = .systemGreen
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return config
    }
}

