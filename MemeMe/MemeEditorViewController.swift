//
//  MemeEditorViewController.swift
//  MemeMeV1
//
//  Created by Mohamed Metwaly on 2019-02-16.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController {

    // MARK: Outlets and variables
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var navItem: UINavigationItem!
    
    var meme:Meme!
    var memeIndex:Int!
    let navigationBar = UINavigationBar()
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth:  -3.0
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !(meme != nil) {
            setupInitialView()
        } else {
            setupMeme(meme)
        }
        //dismiss keyboard when user taps outside textfield
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
        setupNavbar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        unsubscribeFromKeyboardNotifications()
    }
    
    //MARK: Setup functions
    func setupInitialView(){
        shareButton.isEnabled = false
        textFieldSetup(field: topText, position: "TOP" , text: "",memeExists: false)
        textFieldSetup(field: bottomText, position: "BOTTOM",text: "",memeExists: false)
        navItem.title = "Add Meme"
    }
    
    func setupNavbar(){
        navigationBar.isTranslucent = false
        
        //Add it to viewcontroller's view and set it's constraints
        //Source: https://dev.to/onmyway133/using-standalone-uinavigationbar-in-ios-5b8j
        self.view.addSubview(navigationBar)
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        navigationBar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        //Set navigation item we created to new navigation bar to display it
        navigationBar.items = [navItem]
    }
    
    //Only called if a meme object already exists
    func setupMeme(_ meme: Meme){
        shareButton.isEnabled = true
        textFieldSetup(field: topText, position:"", text: meme.topText,memeExists: true)
        textFieldSetup(field: bottomText, position: "", text: meme.bottomText , memeExists: true)
        imageView.image = meme.originalImage
        navItem.title = "Edit Meme"
    }
    
    func textFieldSetup(field:UITextField,position:String,text:String,memeExists:Bool) {
        if !memeExists{
            field.text = (position == "TOP") ? "TOP" : "BOTTOM"
        }
        else {
            field.text = text
        }
        field.delegate = self
        field.isUserInteractionEnabled = memeExists ? true : false
        field.defaultTextAttributes = memeTextAttributes
        field.textAlignment = .center
    }
    
    //MARK: Keyboard methods
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        
        let userInfo = notification.userInfo
        let beginFrameValue = (userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)!
        let beginFrame = beginFrameValue.cgRectValue
        let endFrameValue = (userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)!
        let endFrame = endFrameValue.cgRectValue
        
        //return if the top textfield is selected or if the frame rectangle was not modified
        if topText.isFirstResponder {
            return
        }
        else if beginFrame.equalTo(endFrame) {
            return
        }
        
        view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        //return the view frame to its original position
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        topText.resignFirstResponder()
        bottomText.resignFirstResponder()
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }

    //MARK: Methods
    @IBAction func pickImageFromCamera(_ sender: Any) {
        ImagePicker(sourceType: .camera)
    }
    
    @IBAction func pickImageFromAlbum(_ sender: Any) {
        ImagePicker(sourceType: .photoLibrary)
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sharedPressed(_ sender: Any) {
        let memedImage = generateMemedImage()
        let shareActivity = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        shareActivity.completionWithItemsHandler = { (activity, success, items, error) in
            if success{
                self.save(memedImage)
                self.dismiss(animated: true, completion: nil)
            }
        };
        self.present(shareActivity, animated: true, completion: nil)
        //For iPad, share button displays a popover
        if let controller = shareActivity.popoverPresentationController {
            controller.sourceView = self.view
        }
    }
    
    func generateMemedImage() -> UIImage {
        
        toolbar.isHidden = true
        navigationBar.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
 
        toolbar.isHidden = false
        navigationBar.isHidden = false
        
        return memedImage
    }
    
    func save(_ memedImage:UIImage) {

        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        
        if (meme != nil) {
            if let top = topText.text, let bottom = bottomText.text {
                meme.bottomText = bottom
                meme.topText = top
            }
            meme.memedImage = memedImage
            appDelegate.memes.remove(at: memeIndex)
            appDelegate.memes.insert(self.meme, at: memeIndex)
        }
        else {
            let meme2 = Meme(topText: topText.text!, bottomText: bottomText.text!, originalImage: imageView.image!, memedImage: memedImage)
            appDelegate.memes.append(meme2)
        }
    }
    
    func ImagePicker (sourceType:UIImagePickerController.SourceType) {
        let pictureView = UIImagePickerController()
        pictureView.delegate = self
        pictureView.sourceType = sourceType
        present(pictureView,animated: true,completion: nil)
    }
}

//MARK: UIImagePicker delegate methods
extension MemeEditorViewController:UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let img = info[.originalImage] as? UIImage {
            imageView.image = img
            shareButton.isEnabled = true
            topText.isUserInteractionEnabled = true
            bottomText.isUserInteractionEnabled = true
            dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: UITextField delegate methods
extension MemeEditorViewController:UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "TOP" || textField.text == "BOTTOM" {
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
