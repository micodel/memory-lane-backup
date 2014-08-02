//
//  ViewControllerHome.swift
//  camerataker
//
//  Created by Apprentice on 6/16/14.
//  Copyright (c) 2014 Skippers. All rights reserved.
//

import UIKit
import CoreLocation

class ViewControllerHome: UIViewController, UINavigationControllerDelegate , UITextFieldDelegate, CLLocationManagerDelegate {


    @IBOutlet var changeMemImage : UIImageView
    
    let locationManager = CLLocationManager()
    var textHacker = ""
    
    // after the view loads, start getting location
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController.navigationBar.hidden = true;
        self.textHacker != ""
        self.changeMemImage.hidden = true
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        weak var weakSelf : ViewControllerHome? = self;
        var myLat = locationManager.location.coordinate.latitude
        var myLong = locationManager.location.coordinate.longitude
        
        var testLocation = CLLocation(latitude: myLat, longitude: myLong)
        self.fetchImageWithCLLocation(testLocation, handler: {
            (response: NSURLResponse!, image: UIImage!, error: NSError!) in
            if (!error) {
                // Success! We got back an image...bind the image returned in the closure to the changeImage UIImageView
                if self.textHacker != "" {
                    self.changeMemImage.hidden = false
                    
                }
            }
        })
    }
    
    func locationManager(manager:CLLocationManager!, didUpdateLocations locations:CLLocation[]) {
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
                
                weak var weakSelf : ViewControllerHome? = self
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