//
//  ViewControllerGet.swift
//  camerataker
//
//  Created by Apprentice on 6/15/14.
//  Copyright (c) 2014 Skippers. All rights reserved.
//

import UIKit
import CoreLocation

class ViewControllerGet: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate , UITextFieldDelegate, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var textHacker = ""
    
    @IBOutlet var changeImage : UIImageView
    @IBOutlet var changeTextView : UITextView

    @IBOutlet var youLatDisplay : UILabel = nil
    @IBOutlet var youLongDisplay : UILabel = nil
 

    
    
    // after the view loads, start getting location
    override func viewDidLoad() {        
        changeTextView.editable = false
        changeTextView.layer.borderWidth = 0.6
        changeTextView.layer.cornerRadius = 6.0
        changeTextView.scrollEnabled = true
        
        
        super.viewDidLoad()
//        self.navigationController.navigationBar.hidden = false;
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        weak var weakSelf : ViewControllerGet? = self;
        var myLat = locationManager.location.coordinate.latitude
        var myLong = locationManager.location.coordinate.longitude
        
        
        var counterlat = 0
        var counterlong = 0
        var answerLat = ""
        var answerLong = ""
        
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
        
        self.youLatDisplay.text = answerLat
        self.youLongDisplay.text = answerLong
//        self.changeTextView.text = "There's no memory here \n\nCreate one in this spot for the next person to stumble on.  \n\nAnd keep walking around to find one in your neighborhood."
        println("test1")

        var testLocation = CLLocation(latitude: myLat, longitude: myLong)
        self.fetchImageWithCLLocation(testLocation, handler: {
            (response: NSURLResponse!, image: UIImage!, error: NSError!) in
            if (!error)
            {
                // Success! We got back an image...bind the image returned in the closure to the changeImage UIImageView
                
                weakSelf!.changeImage.image = image
                self.changeTextView.text = self.textHacker
                
            }
        })
        println("test2")
    }
    
    func locationManager(manager:CLLocationManager!, didUpdateLocations locations:CLLocation[])
    {
        var mostRecentLocation = locations[0]
    }
    
    
    // standard
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
// SID SET THIS UP FOR OUR LOGIC TO CHECK ONCE EVERY CHANGE IN X FEET
//    func locationManager(manager:CLLocationManager!, didUpdateLocations locations:CLLocation[])
//    {
//        // locations array will contain CLLocation objects in chronological order - Most recent first
//        // For our case, we shoud only need to get the first object in this array
//        
//        // Grab the latitude and long from this CLLocation object
//        // call method to fetch image from services (backend) using lat/long
//        // ex. - func fetchImageWithCLLocation(location: CLLocation, handler: {(image: UIImage, error: NSError)()}.....handler should be a closure
//        var mostRecentLocation = locations[0]
//        weak var weakSelf : ViewControllerGet? = self
//   // ON BUTTON CLICK....
//        // the variable 'handler' is a closure that gets executed once a response comes back from the backend
//        self.fetchImageWithCLLocation(mostRecentLocation, handler: {
//            (response: NSURLResponse!, image: UIImage!, error: NSError!) in
//            if (error)
//            {
//                // Success! We got back an image...bind the image returned in the closure to the changeImage UIImageView
//                weakSelf!.changeImage.image = image
//            }
//        })
//    }
    
    
    func fetchImageWithCLLocation(location: CLLocation?, handler: ((NSURLResponse!, UIImage!, NSError!) -> Void)!) {
        println("--- fetch Image with Location")
        //TODO: fetch memory text with CLLOcation.  change method need.  need to return both text and image.
        // Create NSURLRequest object with correct properties set (base url, endpoint, url parameters, any post data, headers, etc.)
        // Make asynchronous call using NSURLConnection using sendAsynchronousRequest (use NSOperationQueue.mainOperationQueue as the operation queue for method, pass handler as the last parameter of the method call)
        if (!location) {
            return;
        }
        
        var request = NSMutableURLRequest();
        request.URL = NSURL(string: self.parameterizedURLFromLocation(location!, baseURL: "http://nameless-reaches-8687.herokuapp.com/memories/"))
        request.HTTPMethod = "GET"
        request.setValue("text/xml", forHTTPHeaderField: "X-Requested-With")
        
        NSURLConnection.sendAsynchronousRequest(request,
            queue: NSOperationQueue.mainQueue(),
            completionHandler:{
                (response: NSURLResponse!, data: NSData!, error: NSError!) in
                var jsonResult: NSDictionary? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary
                if (!jsonResult) {
                    return;
                }
   
                var urlDictionary : NSDictionary = jsonResult!["image"] as NSDictionary
                var urlToImage : AnyObject? = urlDictionary["url"] as AnyObject?
                var textDictionary : NSString = jsonResult!["text"] as NSString
                self.textHacker = textDictionary

                println(urlDictionary)
                println(urlToImage)
                println(textDictionary)
                
                weak var weakSelf : ViewControllerGet? = self
                if (urlToImage) {
                    var kMaybeThisIsAnImage : String = urlToImage! as String
                    println("kMaybeThisIsAnImage: \(kMaybeThisIsAnImage)")
                    weakSelf!.fetchImageAtURL(kMaybeThisIsAnImage, handler: {
                        (response: NSURLResponse!, image: UIImage!, error: NSError!) in
                        if handler {
                            handler(response, image, error)
                        }
                    })
                }
            })
        }

    func fetchImageAtURL(url: String, handler: ((NSURLResponse!, UIImage!, NSError!) -> Void)!) {
        var request = NSMutableURLRequest();
        request.URL = NSURL(string: url)
        request.HTTPMethod = "GET"
        NSURLConnection.sendAsynchronousRequest(request,
            queue: NSOperationQueue.mainQueue(),
            completionHandler:{
                (response: NSURLResponse!, data: NSData!, error: NSError!) in
                var img : UIImage = UIImage(data: data!)
                if handler {
                    handler(response, img, error)
                }
            })
    }
    
    func parameterizedURLFromLocation(location: CLLocation, baseURL: String) -> String {
        println("\(baseURL)?latitude=\(location.coordinate.latitude)&longitude=\(location.coordinate.longitude)")
        return  "\(baseURL)?latitude=\(location.coordinate.latitude)&longitude=\(location.coordinate.longitude)"
    }
}