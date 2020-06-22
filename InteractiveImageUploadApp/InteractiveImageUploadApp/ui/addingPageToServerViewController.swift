//
//  addingPageToServerViewController.swift
//  InteractiveImageUploadApp
//
//  Created by 김동환 on 2020/06/14.
//  Copyright © 2020 김동환. All rights reserved.
//

import UIKit

class addingPageToServerViewController: UIViewController {
    @IBOutlet weak var imagePickerButton: UIButton!
    
    
    
    let picker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.imagePickerButton.addTarget(self, action: #selector(self.pickAndLoadImage), for: .touchUpInside)
        
        self.picker.sourceType = .photoLibrary
        self.picker.allowsEditing = false
        self.picker.delegate = self
    }
    

    @objc func pickAndLoadImage(){
        self.present(self.picker, animated: true)
    }

}

extension addingPageToServerViewController : UINavigationControllerDelegate,UIImagePickerControllerDelegate{
 
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var newImage: UIImage? = nil
        print("in imagePickerController")
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
        imagePickerButton.imageView?.contentMode = .scaleAspectFit
         
        imagePickerButton.setImage(newImage, for: .normal)
        picker.dismiss(animated: true)
    }
}
