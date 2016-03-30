//
//  BookDetails.swift
//  ISBNVista
//
//  Created by Juan Carlos Farías A. on 3/26/16.
//

import UIKit
import CoreData

@objc protocol BookDetailsDelegate {
    func bookDetails(bookName: String, bookISBN: String)
}

class BookDetails: UIViewController, UITextFieldDelegate {

    var codigo = ""
    weak var delegate: BookDetailsDelegate?
    //Paso 02: declarar el contexto:
    var contexto : NSManagedObjectContext? = nil
    var existe:Bool = false
    
    @IBOutlet weak var isbn: UITextField!
    @IBOutlet weak var titulo: UILabel!
    @IBOutlet weak var autor: UILabel!
    @IBOutlet weak var portada: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        isbn.delegate = self
        
        //Paso 02: Establecer el estado del contexto (obtener el delegate:
        contexto = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        // Do any additional setup after loading the view.
        isbn.text = codigo
        
        if (codigo != "")
        {
            self.portada.image = nil
            getISBNInfo(isbn.text!, vieneDeListado: true)
            isbn.enabled = false
        }
        else
        {
            isbn.enabled = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        
        self.isbn.resignFirstResponder()
        self.portada.image = nil
        self.isbn.enabled = false
        getISBNInfo(isbn.text!, vieneDeListado: false)
        
        return true
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func getISBNInfo( isbn: NSString, vieneDeListado: Bool){
        existe = false
        
        //Paso 03: Verificar si ese libro ya fue buscado anteriormente...
        let libroEntidad = NSEntityDescription.entityForName("Libro", inManagedObjectContext: self.contexto!)
        let peticion = libroEntidad?.managedObjectModel.fetchRequestFromTemplateWithName("petLibro", substitutionVariables: ["isbn": self.isbn.text!])
        do{
            let libroEntidad2 = try self.contexto?.executeFetchRequest(peticion!)
            if (libroEntidad2?.count > 0 && !vieneDeListado){
                let alertController = UIAlertController(title: "Libro ya consultado", message:
                    "No puede ser agregado.", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController, animated: true, completion: nil)
                //self.isbn.text = nil
                
                existe = true
            }else{
                /*let alertController = UIAlertController(title: "Libro Nuevo", message:
                    "Puede ser agregado.", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController, animated: true, completion: nil)*/
            }
            
        }catch _ {
            
        }
        
        let urls = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:" + (isbn as String)
        let url = NSURL(string: urls)
        let session = NSURLSession.sharedSession()
        let bloque = { (datos: NSData?, resp : NSURLResponse?, error: NSError?) -> Void in
            
            if((error) != nil)
            {
                let alertController = UIAlertController(title: "Fallo en la Red", message:
                    error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            else
            {
                do
                {
                        /*self.portada.image = UIImage(contentsOfFile: "sin-imagen.jpg")
                        self.disolver() */
                        
                    let json = try NSJSONSerialization.JSONObjectWithData(datos!, options: NSJSONReadingOptions.MutableLeaves)
                    let key = "ISBN:" + self.isbn.text!
                    let dico1 = json as! NSDictionary
                    print(dico1.count)
                    
                    if (dico1.count>0){
                        
                        let dico2 = dico1[key] as! NSDictionary
                        let title = dico2["title"] as! NSString as String
                        
                        let authors = dico2["authors"] as? [[String: AnyObject]]
                        
                        var authorsNames: String = ""
                        for author  in authors!
                        {
                            if let name = author["name"] as? String
                            {
                                // Do stuff with data
                                if ( authorsNames != "" )
                                {
                                    authorsNames = authorsNames + ","
                                }
                                authorsNames = authorsNames + (name)
                            }
                        }
                        
                        if let covers1 = dico2["cover"]
                        {
                            let covers = covers1 as! NSDictionary
                            let cover = covers["medium"] as! NSString as String
                            if let checkedUrl = NSURL(string: cover) {
                                //self.imageView.contentMode = .ScaleAspectFit
                                self.downloadImage(checkedUrl)
                            }else{
                                self.portada.image = UIImage(contentsOfFile: "sin-imagen.jpg")
                                self.disolver()
                            }
                        }else{
                            self.portada.image = UIImage(contentsOfFile: "sin-imagen.jpg")
                            self.disolver()
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            // code here
                            //self.resultsTextView.text = (texto as! String)
                            self.titulo.text = title
                            self.autor.text = authorsNames
                            if (self.codigo == "")
                            {
                                if (!self.existe){
                                    self.delegate?.bookDetails(title, bookISBN: self.isbn.text!)
                                }
                            }
                        })
                    }else{
                        let alertController = UIAlertController(title: "¡ Inexistente !", message:
                            "No existe Libro con ISBN: \(self.isbn.text!)", preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                    
                }
                catch _{
                    
                }
            }
            print("Título: \(self.titulo.text!)")
            print("ISBN: \(self.isbn.text!)")
            
            if (!self.existe && !vieneDeListado) {
                let nuevoLibroEntidad = NSEntityDescription.insertNewObjectForEntityForName("Libro", inManagedObjectContext: self.contexto!)
                nuevoLibroEntidad.setValue(self.titulo.text!, forKey: "titulo")
                nuevoLibroEntidad.setValue(self.isbn.text!, forKey: "isbn")
                
                do{
                    try self.contexto?.save()
                }catch _ {
                    print("Error al grabar libro...")
                }
            }
            
            
        }
        let dt = session.dataTaskWithURL(url!, completionHandler: bloque)
        dt.resume()
        
    }
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    func downloadImage(url: NSURL){
        getDataFromUrl(url) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                guard let data = data where error == nil else { return }
                print(response?.suggestedFilename ?? "")
                print("Descarga Terminada...")
                self.portada.image = UIImage(data: data)
                self.disolver()
            }
        }
    }

    
    func disolver(){
        UIView.transitionWithView(self.portada,
            duration:5,
            options: .TransitionCrossDissolve,
            animations: { self.portada.image = self.portada.image },
            completion: nil)
    }


}
