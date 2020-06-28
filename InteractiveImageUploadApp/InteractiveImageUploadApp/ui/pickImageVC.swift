//
//  addingPageToServerViewController.swift
//  InteractiveImageUploadApp
//
//  Created by 김동환 on 2020/06/14.
//  Copyright © 2020 김동환. All rights reserved.
//

import UIKit

class pickImageVC: UIViewController {
    @IBOutlet weak var imagePickerButton: UIButton!
    
    
    var imageEditor = imageEdit()
    let picker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.imagePickerButton.addTarget(self, action: #selector(self.pickAndLoadImage), for: .touchUpInside)
        
        self.picker.sourceType = .photoLibrary
        self.picker.allowsEditing = false
        self.picker.delegate = self
        
        imagePickerButton.setImage( imageEditor.testRender(), for: .normal)
    }
    

    @objc func pickAndLoadImage(){
        self.present(self.picker, animated: true)
    }
    
    @IBAction func processImgBtn(_ sender: UIButton) {
        var newImage : UIImage? = nil
        newImage = imagePickerButton.currentImage
        imagePickerButton.setImage(imageEditor.processPixels(in: newImage!), for: .normal)
    }
    
}

extension pickImageVC : UINavigationControllerDelegate,UIImagePickerControllerDelegate{
 
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var newImage: UIImage? = nil
        
        if let possibleImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage{
            newImage = possibleImage
            print("edited image")
        } else if let possibleImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerOriginalImage")] as? UIImage {
            newImage = possibleImage
            print("original image")
        }
        else {
            print("none")
        }
        
        //imagePickerButton.imageView?.image = newImage
        imagePickerButton.imageView?.contentMode = .scaleToFill
         
        imagePickerButton.setImage(newImage, for: .normal)
        picker.dismiss(animated: true)
    }
}
