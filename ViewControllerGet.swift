//
//  ViewControllerGet.swift
//  camerataker
//
//  Created by Apprentice on 6/15/14.
//  Copyright (c) 2014 Skippers. All rights reserved.
//


// COULD THIS PAGE BE A MANUALLY CODED VIEW THAT SITS ON TOP OF HOME PAGE AND IS HIDDEN INSTEAD OF A TRANSITION. SINCE THE HOME PAGE IS LOADING THE IMAGE AND THEN NOT USING? THIS PAGE HAS TO RELOAD A NEW IMAGE? "BACK" BUTTON COULD THEN REHIDE THE IMAGE AND RESET THE VARIABLES.

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

        var testLocation = CLLocation(latitude: myLat, longitude: myLong)
        self.fetchImageWithCLLocation(testLocation, handler: {
            (response: NSURLResponse!, image: UIImage!, error: NSError!) in
            if (!error)
            {
                weakSelf!.changeImage.image = image
                self.changeTextView.text = self.textHacker
                
            }
        })
    }
    
    func locationManager(manager:CLLocationManager!, didUpdateLocations locations:CLLocation[])
    {
        var mostRecentLocation = locations[0]
    }
    
    
    // standard
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    func fetchImageWithCLLocation(location: CLLocation?, handler: ((NSURLResponse!, UIImage!, NSError!) -> Void)!) {
        
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
        return  "\(baseURL)?latitude=\(location.coordinate.latitude)&longitude=\(location.coordinate.longitude)"
    }
}