// Playground - noun: a place where people can play

import UIKit

var str = "10.12345678"


var answerlat = ""
var counterlat = 0

for x in str {
    if x == "." {
        counterlat = 1
    }
    if counterlat < 8 {
        answerlat += x
    }
    counterlat += 1
}

println(answerlat)


var startTime = NSDate()

var nowTime = NSDate()

var timeElapsed = nowTime.timeIntervalSinceDate(startTime)

var name: String = "susan"
name.endIndex

countElements(name)

//for char in "\(imageData)" {
//    if char != " " {
//        imgAsString += char
//    }
//}

var bigthing: String = "<lkdjfa;sldkjfa;sd22lkfjas;lfkjasd;flkjasd;lfkjasd;flkajsdf;laksjdf;alskdjg;asldkgja;lghaf;kgjha    324upo324u5p30958413u4>"

var container = ""
var test = "testting"
var counter = 0



for x in bigthing{

    if counter == 0{
        counter += 1
    }
    
    else if counter == (countElements(bigthing) - 1){
        println("winning")
    }
    
    else{
    container += x
        counter += 1
    }
    
}

container





for x in bigthing{
    if counter != 0{
    container += x
    counter += 1
    }
}
var iamworking = 5


println(container)





//subscript (i: Int) -> String {
//    return String(Array(self)[i])
//}
//
//var char = "abcde"[2] // char equals "c"
////
////println(name[0])
//println(name.first)
//println(name)
//println(name)

