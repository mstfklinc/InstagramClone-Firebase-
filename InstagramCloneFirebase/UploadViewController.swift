//
//  UploadViewController.swift
//  InstagramCloneFirebase
//
//  Created by apple on 12.11.2019.
//  Copyright © 2019 apple. All rights reserved.
//

import UIKit
import Firebase

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commandText: UITextField!
    @IBOutlet weak var uploadButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImage))
        imageView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func chooseImage()
    {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    func makeAlert(titleInput: String, messageInput: String)
    {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "Error", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func actionButtonClicked(_ sender: Any) {
        
        let storage = Storage.storage()
        let storageReference = storage.reference()
        let mediaFolder = storageReference.child("media")
        
        if let data = imageView.image?.jpegData(compressionQuality: 0.5)
        {
            
            let uuid = UUID().uuidString
            
            let imageReferance = mediaFolder.child("\(uuid).jpg")
            imageReferance.putData(data, metadata: nil) { (metadata, error) in
                
                if error != nil
                {
                    self.makeAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Image not upload")
                }
                else
                {
                    imageReferance.downloadURL { (url, error) in
                        
                        if error == nil
                        {
                            let imageUrl = url?.absoluteURL
                            
                            //DATABASE
                            let firesotoreDatabase = Firestore.firestore()
                            var firestoreReferance : DocumentReference? = nil
                            let firestorePost = ["imageUrl": imageUrl!,
                                                 "postedBy": Auth.auth().currentUser?.email!,
                                                 "postComment": self.commandText.text!,
                                                 "date": FieldValue.serverTimestamp(),
                                                 "likes" : 0] as [String:Any]
                            
                            firestoreReferance = firesotoreDatabase.collection("Posts").addDocument(data: firestorePost, completion: { (error) in
                                
                                if error != nil
                                {
                                    self.makeAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error!")
                                }
                                else
                                {
                                    self.imageView.image = UIImage(named: "selectimage.png")
                                    self.commandText.text = ""
                                    self.tabBarController?.selectedIndex = 0
                                }
                            })
                            
                            
                        }
                    }
                }
            }
        }
        
    }
    
    

}
