//
//  MainView.swift
//  Iscaner
//
//  Created by Nikunj Prajapati on 01/07/20.
//  Copyright © 2020 Nikunj Prajapati. All rights reserved.
//

import UIKit
import Vision
import VisionKit
import PDFKit
import CoreData


class MainView: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate, UIGestureRecognizerDelegate,UITabBarDelegate
{
    
        let Mainimg: [UIImage] = []
    
    let pdfDocument = PDFDocument()
    
    var people: [NSManagedObject] = []
    
   // var dbObj: DataBaseHelper!

    @IBOutlet weak var photolibrary: UIBarButtonItem!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func photonutton(_ sender: UIBarButtonItem) {
        
        
        
    }
    
    //MARK: -Outlets
    @IBOutlet weak var pickImageButton: UIImageView!
    
  //  @IBOutlet weak var holdingImageView: UIImageView!
    
    @IBOutlet weak var toolbar: UIToolbar!
    
    //MARK:- Variable Obj's
    let imagePicker = UIImagePickerController()
    
    let viewController = UIViewController()
    
    var holdImg : UIImage!
    
    var manageContext: NSManagedObjectContext!
    var manageObjList: [NSManagedObject]!
    
    //MARK:- viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        self.customNavigation()
        self.imageCircle()
        imagePicker.delegate = self
        
        
        pickImageButton.layer.cornerRadius = self.accessibilityFrame.size.width / 2
        pickImageButton.clipsToBounds = true
        
        self.manageContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
            //       ReadData()
        // Do any additional setup after loading the view.
    }
    
    
    
    //MARK:- IBAction Functions
    @IBAction func tapGesturetapped(_ sender: UITapGestureRecognizer)
    {
        //code for only open camera
        camera()
        
    }
    
    @IBAction func openImages(_ sender: UIBarButtonItem)
    {
        // code for only open photolibrary
        photoLibrary()
    }
    
    //MARK: -User Defined Functions
    
    
    ///Function for make image circle
    func imageCircle()
    {
        pickImageButton.layer.borderWidth = 0
        pickImageButton.layer.masksToBounds = false
        pickImageButton.layer.borderColor = UIColor.init(red: 25, green: 34, blue: 251, alpha: 1).cgColor
        pickImageButton.layer.cornerRadius = pickImageButton.frame.height/2
        pickImageButton.clipsToBounds = true
    }
    
    ///Function for custom Navigation
//    func customNavigation()
//    {
//        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        self.navigationController!.navigationBar.shadowImage = UIImage()
//        self.navigationController!.navigationBar.isTranslucent = true
//    }

    ///Function for open camera in the app
    func camera()
    {
//
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            imagePicker.modalPresentationStyle = .fullScreen
            
            //make function call here for visionkit
            configDocs()
            
            
            
            
            self.present(imagePicker, animated: true, completion: nil)
            
        } else {
            
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    
    ///Function for open Photo Library in app
    func photoLibrary()
    {
        
//
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.modalPresentationStyle = .fullScreen
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    
    ///UIImagePickerView delelegate functions...
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        //cancel button
        dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey  : Any])
    {
        //to take image in image-view
        holdImg = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
     //   holdingImageView.image = holdImg
        
        dismiss(animated: true, completion: nil)
    }
       
    
    
    /*
      MARK: - Navigation
     
      In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      Get the new view controller using segue.destination.
      Pass the selected object to the new view controller.
     }
     */
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
//    {
//        guard let cameraPick = segue.destination as? cameraPick
//    }
       
}


//MARK: - VNDocumentCameraViewControllerDelegate
extension MainView: VNDocumentCameraViewControllerDelegate
{
    
    
 
    
    
    private func configDocs()
    {
        let scaninngDoc = VNDocumentCameraViewController()
        scaninngDoc.delegate = self
        self.present(scaninngDoc, animated: true, completion: nil)
    }
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        
        
        for pageNumber in 0..<scan.pageCount
        {
            print("print image saved")
            let image = scan.imageOfPage(at: pageNumber)
           
            print(image)
            if let imageData = image.jpegData(compressionQuality: 1.0)
            {
                //fari ahiya
                
                let imgData = image.jpegData(compressionQuality: 1.0)!
                      let imgString64 = imgData.base64EncodedString(options: .lineLength64Characters)
                    
                
                
                let imBinary = image.pngData()!
                
                print(imBinary)
                
                self.save(image: imBinary)
                
                 let Mainimg2 = UIImage(data: imBinary)!
                // fari puru
                
               // DataBaseHelper.shareInstance.saveImage(data: imageData)
            }
            
        
            print("image saved complete")
            tableView.reloadData()
        }
        controller.dismiss(animated: true, completion: nil)
       
    }
    
    /// ahiya


    func save(image:Data) {
           guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
               return
           }
           let managedContext = appDelegate.persistentContainer.viewContext
           let userEntity = NSEntityDescription.entity(forEntityName: "Image", in: managedContext)!
           //let cityEntity = NSEntityDescription.entity(forEntityName: "CityTable", in: managedContext)!
           
           let person = NSManagedObject(entity: userEntity, insertInto: managedContext)
           
       
           person.setValue(image, forKey: "img")
           do {
               try managedContext.save()
               //people.append(person)
               print("Saved")
           } catch let err as NSError {
               print("Could not save. \(err), \(err.userInfo)")
           }
       }

    ///puru

    
    //
    

    
    
    //
}




extension MainView: UITableViewDelegate, UITableViewDataSource
{
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let person = people[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ImageTableViewCell
        
//        cell?.storedImage.image = UIImage(data: people[indexPath].img!)
        
        
        
        cell?.storedImage.image = person.value(forKey: "img") as? UIImage
        cell?.storedImage.image = Mainimg as? UIImage
        return cell!
    }
    
   
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate
            else{
                return
        }
        let manageContext = appdelegate.persistentContainer.viewContext
        
        let fetchReq = NSFetchRequest<NSManagedObject>(entityName: "Image")
        
        do
        {
            people = try manageContext.fetch(fetchReq)
        }
        catch let error as NSError
        {
            print("data is not saved \(error),\(error.userInfo)")
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        
    }
    
}
