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


class MainView: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate, UIGestureRecognizerDelegate,UITabBarDelegate
{
    
    let pdfDocument = PDFDocument()
    

    @IBOutlet weak var photolibrary: UIBarButtonItem!
    
    @IBAction func photonutton(_ sender: UIBarButtonItem) {
        
        
        
    }
    
    //MARK: -Outlets
    @IBOutlet weak var pickImageButton: UIImageView!
    
    @IBOutlet weak var holdingImageView: UIImageView!
    
    @IBOutlet weak var toolbar: UIToolbar!
    
    //MARK:- Variable Obj's
    let imagePicker = UIImagePickerController()
    
    let viewController = UIViewController()
    
    var holdImg : UIImage!
    
    
    //MARK:- viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        self.customNavigation()
        self.imageCircle()
        imagePicker.delegate = self
        
        
        pickImageButton.layer.cornerRadius = self.accessibilityFrame.size.width / 2
        pickImageButton.clipsToBounds = true
       
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
//        if UIImagePickerController.isSourceTypeAvailable(.camera)
//        {
//            let myPickerController = UIImagePickerController()
//            myPickerController.delegate = self;
//            myPickerController.sourceType = .camera
//            imagePicker.present(myPickerController, animated: true, completion: nil)
//            print("Camera is open succesfully !!")
//        }
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
        
//        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
//        {
//            let myPickerController = UIImagePickerController()
//            myPickerController.delegate = self;
//            myPickerController.sourceType = .photoLibrary
//            present(myPickerController, animated: true, completion: nil)
//            print("Photo Library is open succesfully !!")
//        }
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
        holdingImageView.image = holdImg
        
        
        

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
            let image = scan.imageOfPage(at: pageNumber)
            let pdfpage = PDFPage(image: image)
            pdfDocument.insert(pdfpage!, at: pageNumber)
            
            print("Save")
            
            let data = pdfDocument.dataRepresentation()
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            let docurl = documentDirectory.appendingPathComponent("Scanned.pdf")
            
            do {
                try data?.write(to: docurl)
                print(docurl)
                
            } catch (let error) {
                print(error.localizedDescription)
            }
            
            let pdfview = PDFView()
            
            pdfview.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(pdfview)
            
        let docU = documentDirectory.appendingPathComponent("Scanned.pdf")
            

            
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            print("image")

        }
        controller.dismiss(animated: true, completion: nil)
        print("Saved")
    }
}
