//
//  ViewController.swift
//  camerataker
//
//  Created by Apprentice on 6/14/14.
//  Copyright (c) 2014 Skippers. All rights reserved.
//  

import UIKit
import CoreLocation
//The Core Location framework uses the built in hardware to determine the current location or heading associated with a device.


// CLASS INHERITENCE
class ViewController:
        UIViewController,
        UIImagePickerControllerDelegate,
        // The UIImagePickerControllerDelegate protocol defines methods that your delegate object must implement to interact with the image picker interface. The methods of this protocol notify your delegate when the user either picks an image or movie, or cancels the picker operation.
        UINavigationControllerDelegate,
        // Handles active view transitions.
        UITextFieldDelegate,
        // Handles text transfer and keyboard functions.
        CLLocationManagerDelegate
        // The CLLocationManagerDelegate protocol defines the methods used to receive location and heading updates from a CLLocationManager object. Upon receiving a successful location or heading update, you can use the result to update your user interface or perform other actions.
        {
    
// VARIABLE INITIALZERS
    // init location manager and set coordinates to 0
    let locationManager = CLLocationManager()
    // Iniitializes a variable equal to a LocationManager object.
    // aka an instance of the LocationManager class.
    var myLong = 0.0
    var myLat = 0.0
    // Initializes the users lattidude and longitutde with default values of 0.
    var answerLat = ""
    var answerLong = ""
    // Initializes string varaiables to display the lattitude and longitude on the view.
    
// SYSTEM FUNCTIONS
    // after the view loads, start getting location
    override func viewDidLoad() {
        super.viewDidLoad()
//      (LEGACY: self.navigationController.navigationBar.hidden = false;)
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // This has a default value of best, can we clean this up be excluding this line?
        locationManager.startUpdatingLocation()
        // Continually checks current location.
        
        textMem.layer.borderWidth = 0.6
        textMem.layer.cornerRadius = 6.0
        textMem.scrollEnabled = true
        // Defines and initializes the textarea for create new memory. With rounded corners and overflow scrolling.
    }
    

    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
    }
    
    // standard
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // Connects storyboard objects on create memory page with variables defined below.
    @IBOutlet var imageView : UIImageView = nil
    @IBOutlet var textMem : UITextView = nil
    @IBOutlet var changeError : UILabel = nil
    @IBOutlet var checkButtonChangeColor : UIButton
    
    // Closes keyboard when you click outside of the text area.
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        self.view.endEditing(true)
    }
    
    // Returns text from textfield to its outlet variable. (?)
    // (?) Does this happen automatically at this point or handled manually below?
    // May not be returning literal text, but telling the text field is has to return SOMETHING.
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        // Textfield delegate removes keyboard when return is hit.
        return true
    }
    
    // opens the camera when you hit the "Take Photo" button until "Use Photo" is confirmed
    // the the camera closes
    @IBAction func takePhoto(sender : UIButton) {
        var image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.Camera
        image.allowsEditing = false
        self.presentViewController(image, animated: true, completion: nil)
    }
    
    
    //Initialize camera data string
    func imagePickerController(image: UIImagePickerController, didFinishPickingMediaWithInfo info: NSDictionary) {
        var chosenImage: UIImage = info[UIImagePickerControllerOriginalImage] as UIImage
        self.imageView.image = chosenImage
        self.dismissModalViewControllerAnimated(true)
        var imageData: NSData = UIImageJPEGRepresentation(chosenImage, 0.1)
    }
    
    // sets the actual long and lat values to the variables and convert to strings with 6 deceimal places
    var once = 1
    func locationManager(manager:CLLocationManager!, didUpdateLocations locations:AnyObject[]) {
        if once == 1 {
            myLat = locations[0].coordinate.latitude
            myLong = locations[0].coordinate.longitude

            var counterlat = 0
            var counterlong = 0
            
            for x in "\(myLat)" {
                if x == "." { counterlat = 1 }
                if counterlat < 8 { answerLat += x }
                counterlat += 1
            }
            for x in "\(myLong)" {
                if x == "." { counterlong = 1 }
                if counterlong < 8 { answerLong += x }
                counterlong += 1
            }
        }
        once += 1
    }
    
    
    // submit memory button
    @IBAction func btnCaptureMem(sender : UIButton) {
        if (imageView.image == nil) {changeError.text="Please enter both text and an image to submit"}
        else if (textMem.text == "") {changeError.text="Please enter both text and an image to submit"}
        else {
            var myText = textMem.text
            self.view.endEditing(true)
            
            var url = "http://nameless-reaches-8687.herokuapp.com/memories"
            
            let manager = AFHTTPRequestOperationManager()
            let params = ["text":myText, "latitude":answerLat, "longitude":answerLong]
            
            manager.POST(url, parameters: params,
                constructingBodyWithBlock: {
                    [weak self](formData) -> Void in
                    formData.appendPartWithFileData(UIImageJPEGRepresentation(self?.imageView?.image, 0.9), name: "image", fileName: "picture.jpg", mimeType: "image/jpeg")
                },
                success: {(operation, response) -> Void in
                    println(response)
                },
                failure: {(operation, response) -> Void in
                    println(response)
                })
            
            let alert = UIAlertView()
            alert.title = "Memory Created!"
            alert.message = "You have shared a memory for the world to experience."
            alert.addButtonWithTitle("the world ♥'s you")
            alert.show()
            alert.delegate = nil
            
            textMem.text = ""
            imageView.image = nil
            changeError.text=""
            }
    }
}