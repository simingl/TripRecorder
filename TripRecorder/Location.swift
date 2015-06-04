//
//  Location.swift
//  TripRecorder
//
//  Created by Zach Newell on 11/29/14.
//  Copyright (c) 2014 Zach Newell. All rights reserved.
//

import Foundation


public class Location {
    var id  : NSUUID
    var lat : Double  = 0.0
    var lon : Double = 0.0
    var speed: Double = 0.0
    var stopped : Bool = false
    var stopped_duration = 0.0
    var heading : String = ""
    var timestamp: NSDate?
    init(){
        id = NSUUID()
    }
    
    func toJSON() -> [String: AnyObject] {
        var formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        
        //FilePath
        let ds : String = formatter.stringFromDate(timestamp!)
        
        let obj:[String:AnyObject] = [
            "id" : self.id.UUIDString,
            "lat": lat,
            "lon": lon,
            "speed": speed,
            "timestamp": ds,
            "stopped" : stopped,
            "stopped_duration": stopped_duration
        ]
        
        return obj
    }
}