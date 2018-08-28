//
//  KeyboardViewController.swift
//  KeyboardExtension
//
//  Created by Yudiz Solutions Pvt. Ltd. on 15/08/18.
//  Copyright © 2018 Yudiz Solution Pvt Ltd. All rights reserved.
//

import UIKit

enum ShiftStatus{
    case capitalized
    case normal
}

class KeyboardViewController: UIInputViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var charSet: UIStackView!
    @IBOutlet weak var numSet: UIStackView!
    @IBOutlet weak var specialCharSet: UIStackView!
    
    @IBOutlet weak var bckImageView: UIImageView!
    
    @IBOutlet weak var row0: UIStackView!
    @IBOutlet weak var row1: UIStackView!
    @IBOutlet weak var row2: UIStackView!
    @IBOutlet weak var row3: UIStackView!
    
    @IBOutlet weak var btnShift: UIButton!
    
    @IBOutlet var zoomView: UIView!
    @IBOutlet weak var lblZoomText: UILabel!
    @IBOutlet weak var imgBubbleView: UIImageView!
    
    //MARK:- Variable
    var status: ShiftStatus!
    
    /// Check weather the view has access to all the rights
    var hasAccess: Bool {
        if #available(iOS 11.0, *) {
            return self.hasFullAccess
        }else {
           return false
        }
    }
    
    /// Status Bar Hidden
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    //Set Document Proxy to get text String
    private var proxy: UITextDocumentProxy{
        return textDocumentProxy
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
    }
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackGroundImage()
        setUpUI()
    }
}

//MARK:- UI-Methods
extension KeyboardViewController {

    /// It Prepares the UI of the keyboardView
    func setUpUI(){
        numSet.isHidden = true
        charSet.isHidden = true
        specialCharSet.isHidden = true
        status = .capitalized
        imgBubbleView.tintColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
    }
    
    /// This method is used to set background image
    func setBackGroundImage() {
        if let imgData = userDefauls.value(forKey: "bckImage") as? Data{
            self.bckImageView.image = UIImage(data: imgData)
        }else{
            self.bckImageView.image = #imageLiteral(resourceName: "baby.")
        }
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gallerySegue"{
            let camVC = segue.destination as! CameraVC
            camVC.delegate = self
            camVC.hasAccess = hasAccess
        }
    }
    
    /// Enable and disable Caps lock
    /// - Parameter containerView: Passing buttons reference
    func shiftChange(containerView: UIStackView){
        for view in containerView.subviews{
            if let btn = view as? UIButton{
                let buttonTitle = btn.titleLabel?.text
                if status == .normal{
                    let text = buttonTitle!.lowercased()
                    btn.setTitle(text, for: .normal)
                }else{
                    let text = buttonTitle!.uppercased()
                    btn.setTitle(text, for: .normal)
                }
            }
        }
    }
    
    
    /// User can open Setting through this method
    func openSettingUrl(){
        guard let url = URL(string: UIApplicationOpenSettingsURLString) else { return }
        extensionContext?.open(url, completionHandler: { (success) in
            if !success {
                var responder = self as UIResponder?
                while (responder != nil){
                    let selectorOpenURL = NSSelectorFromString("openURL:")
                    if responder?.responds(to: selectorOpenURL) == true {
                        _ = responder?.perform(selectorOpenURL, with: url)
                    }
                    responder = responder?.next
                }
            }
        })
    }
    
    /// Use to hide view that appears on button tap
    func hideBubbleView(){
        zoomView.layoutIfNeeded()
        UIView.animate(withDuration: 2.0) {
            self.zoomView.removeFromSuperview()
        }
    }
}

//MARK:- UI-Actions
extension KeyboardViewController{
 
    /// Works same as Caps lock in keyboard
    /// - Parameter sender: Works based on button selection
    @IBAction func shiftPressed(_ sender: UIButton){
        sender.isSelected = !sender.isSelected
        status = sender.isSelected ? .normal : .capitalized
        shiftChange(containerView: row0)
        shiftChange(containerView: row1)
        shiftChange(containerView: row2)
    }
    
    /// This func will display the bubble view when key touched down
    /// - Parameters:
    ///   - button: Represent the current tapped button
    ///   - event: Return the touch event of the button
    @IBAction func keyDragDown(_ button: UIButton, forEvent event: UIEvent) {
        guard let touch = event.allTouches?.first else { return }
        let point = touch.location(in: button)
        let str = button.titleLabel!.text
        proxy.insertText(str!)
        if status == .capitalized{
            shiftPressed(self.btnShift)
        }
        button.addSubview(zoomView)
        let xPos = (button.frame.width - self.zoomView.frame.width) / 2
        let yPos = point.y - self.zoomView.frame.height
        self.zoomView.alpha = 0
        self.zoomView.transform = CGAffineTransform(translationX: xPos, y: yPos)
        UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.zoomView.alpha = 1
            self.zoomView.transform = CGAffineTransform(translationX: xPos, y: yPos)
            self.lblZoomText.text = str
        })
    }
    
    /// This func will remove the bubble view when button leaves its boundary
    /// - Parameters:
    ///   - sender: Represent the current tapped button
    ///   - event: Return the touch event of the button
    @IBAction func keyDragInside(_ sender: UIButton, forEvent event: UIEvent){
        guard let touch = event.allTouches?.first else { return }
        let point = touch.location(in: sender)
        let isPointInside = sender.point(inside: point, with: event)
        if !isPointInside{
            hideBubbleView()
        }
    }
    
    /// Remove BubbleView when button is released
    /// - Parameter sender: Represent the current tapped button
    @IBAction func keyPressed(_ sender: UIButton){
        hideBubbleView()
    }
  
    /// This button enables the Special Character keyboard
    /// - Parameter sender: Enable and disable between the two keyboards.
    @IBAction func charSetPressed(_ sender: UIButton){
        if sender.titleLabel!.text == "!@#"{
            row0.isHidden = true
            row1.isHidden = true
            row2.isHidden = true
            numSet.isHidden = false
            charSet.isHidden = false
            specialCharSet.isHidden = false
            sender.setTitle("ABC", for: .normal)
        }else{
            row0.isHidden = false
            row1.isHidden = false
            row2.isHidden = false
            numSet.isHidden = true
            charSet.isHidden = true
            specialCharSet.isHidden = true
            sender.setTitle("!@#", for: .normal)
        }
    }
    
    /// Enable space between TextInput Field
    /// - Parameter sender: Space is added when tapped
    @IBAction func spacePressed(_ sender: UIButton){
        proxy.insertText(" ")
    }
    
    /// Delete text from TextInput Field
    /// - Parameter sender: Text is deleted when tapped
    @IBAction func backSpacePressed(_ sender: UIButton){
        proxy.deleteBackward()
        if !proxy.hasText{
            shiftPressed(self.btnShift)
        }
    }
    
    /// Dismiss Keyboard
    /// - Parameter sender: Dismiss the keyboard when tapped
    @IBAction func donePressed(_ sender: UIButton){
        self.dismissKeyboard()
    }
    
    /// Display's a Pop-up for selecting image
    /// - Parameter sender: Rediret to the next screen
    @IBAction func openAlert(_ sender: UIButton){
        performSegue(withIdentifier: "gallerySegue", sender: nil)
    }
}

//MARK:- Protocol Implementation
extension KeyboardViewController: ImagePassProtocol{
    func passImage() {
        setBackGroundImage()
    }
}
