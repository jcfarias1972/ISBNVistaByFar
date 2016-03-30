//
//  TVC.swift
//  ISBNVista
//
//  Created by Juan Carlos Farías A. on 3/26/2016.
//

import UIKit
//Paso 01: Importar CoreData
import CoreData

class TVC: UITableViewController, BookDetailsDelegate {

    var busquedas : Array<Array<String>> = Array<Array<String>>()
    //Paso 02: declarar el contexto:
    var contexto : NSManagedObjectContext? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Busca Libros"
        
        //Paso 02: Establecer el estado del contexto (obtener el delegate:
        self.contexto = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        let libroEntidad = NSEntityDescription.entityForName("Libro", inManagedObjectContext: self.contexto!)
        let peticion = libroEntidad?.managedObjectModel.fetchRequestTemplateForName("petLibros")
        do{
            let librosEntidad = try self.contexto?.executeFetchRequest(peticion!)
            for seccionEntidad2 in librosEntidad! {
                let isbnLibro = seccionEntidad2.valueForKey("isbn") as! String
                let nombreLibro = seccionEntidad2.valueForKey("titulo") as! String
                self.busquedas.append([nombreLibro,isbnLibro])
                print("ISBN: \(isbnLibro), Título: \(nombreLibro)")
            }
        }catch _ {
            
        }
        /*self.busquedas.append(["Programming Symposium","0387068597"])
        self.busquedas.append(["The Witching Hour","9781425723705"])
        self.busquedas.append(["Beginning iOS game development","9781118107324"])
        self.busquedas.append(["Learning iOS Programming","9781449303778"])
        self.busquedas.append(["AndroidTM","9780071599894"])
        self.busquedas.append(["Cien años de soledad","9788437604947"])*/
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.busquedas.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Celda", forIndexPath: indexPath)

        // Configure the cell...
        cell.textLabel?.text = self.busquedas[indexPath.row][0]
        cell.detailTextLabel?.text = "ISBN: " + self.busquedas[indexPath.row][1]
        if (indexPath.row%2)==0{
            cell.backgroundColor = UIColor(red: 240/255, green: 248/255, blue: 255/255, alpha: 1)
        }else{
            cell.backgroundColor = UIColor(red: 255/255, green: 245/255, blue: 255/255, alpha: 1)
        }
        return cell
    }
    
    @IBAction func agregarNuevo(sender: AnyObject) {
        self.performSegueWithIdentifier("BookDetails", sender: self)
        //self.performSegueWithIdentifier("BookDetails", sender: contexto!)
    }

    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let view = segue.destinationViewController as! BookDetails
        
        let path = self.tableView.indexPathForSelectedRow
        if (( path ) != nil)
        {
            let ip = self.tableView.indexPathForSelectedRow
            view.codigo = self.busquedas[ip!.row][1]
        }
        else{
            // No cell selected
            view.codigo = ""
        }
        view.delegate = self
        
        
        
        
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    func bookDetails(bookName: String, bookISBN: String)
    {
        busquedas.append([bookName ,bookISBN])
        self.tableView.beginUpdates()
        self.tableView.insertRowsAtIndexPaths([
            NSIndexPath(forRow: busquedas.count-1, inSection: 0)
            ], withRowAnimation: .Automatic)
        self.tableView.endUpdates()

    }

}
