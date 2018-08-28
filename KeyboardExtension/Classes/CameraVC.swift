//
//  CameraVC.swift
//  KeyboardExtension
//
//  Created by Yudiz Solutions Pvt. Ltd. on 20/08/18.
//  Copyright © 2018 Yudiz Solution Pvt Ltd. All rights reserved.
//

import UIKit
import Photos

//MARK:- Protocol
protocol ImagePassProtocol: NSObjectProtocol {
    func passImage()
}

// User Default Constant
let userDefauls = UserDefaults.standard

/// Class to pick image
class CameraVC: UIViewController {
    
    //MARK:- Variables
    var hasAccess: Bool = false
    var selectedImage: UIImage?
    weak var delegate: ImagePassProtocol?
    
    //MARK:- Outlets
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblWarningMsg: UILabel!
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        btnBack.isHidden = hasAccess
        lblWarningMsg.isHidden = hasAccess
        
        if hasAccess{
            openGallery()
        }
    }
    
    func openGallery() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnBackTapped(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK:- Image-Picker Implementation
extension CameraVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            self.selectedImage = pickedImage
            let imgData = UIImagePNGRepresentation(self.selectedImage!)
            userDefauls.setValue(imgData, forKey: "bckImage")
        }
        picker.dismiss(animated: false) {
            self.dismiss(animated: true, completion: {
                if let delegate = self.delegate{
                    delegate.passImage()
                }
            })
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: false) {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
