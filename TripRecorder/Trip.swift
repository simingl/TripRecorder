//
//  Trip.swift
//  TripRecorder
//
//  Created by Xuan Wang on 12/1/14.
//  Copyright (c) 2014 Zach Newell. All rights reserved.
//

import Foundation
import CoreLocation
import AVFoundation
import UIKit


public class Trip : NSObject, AVCaptureFileOutputRecordingDelegate {
    
    var locations       : [Location]
    var video           : AVCaptureMovieFileOutput
    var session         : AVCaptureSession
    var tripid          : String
    var video_filepath  : String
    var json_filepath   : String
    var recording       : Bool
    
    init(session: AVCaptureSession){
        
        
        var formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        
        //FilePath
        let ds : String = formatter.stringFromDate(NSDate())
        let paths = NSSearchPathForDirectoriesInDomains(
            .DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0] as! String
        
        self.tripid = "TripRecorder_" + ds
        self.locations = []
        self.session = session
        self.video = AVCaptureMovieFileOutput()
        self.video_filepath = "\(documentsDirectory)/\(self.tripid).mp4"
        self.json_filepath  = "\(documentsDirectory)/\(self.tripid).json"
        
        
        self.recording = true
        
        super.init()
        
        NSFileManager.defaultManager().fileExistsAtPath(self.video_filepath)
        NSFileManager.defaultManager().fileExistsAtPath(self.json_filepath)
        
        session.addOutput(self.video)
        self.video.startRecordingToOutputFileURL(NSURL(fileURLWithPath: self.video_filepath), recordingDelegate: self)
        
    }
    
    func stop(){
        self.session.removeOutput(self.video)
        self.video.stopRecording()
        //UISaveVideoAtPathToSavedPhotosAlbum(self.video_filepath,nil,nil,nil)
        
        
        var locs: [[String:AnyObject]] = []
        
        for l in self.locations {
            let loc_json = l.toJSON()
            locs.append(loc_json)
        }
        
        var doc = [
            "video" : self.tripid + ".mp4",
            "locations" : locs
        ]
        
        var doc_str = JSON(doc).rawString(encoding: 8, options: NSJSONWritingOptions.PrettyPrinted)!
        
        //Save JSON
        doc_str.writeToFile(self.json_filepath, atomically: false, encoding: NSUTF8StringEncoding, error: nil);

        
    }
    
    func addLocation(location: CLLocation) -> NSUUID {
        let loc : Location = Location()
        let uuid = NSUUID()
        
        loc.lat = location.coordinate.latitude
        loc.lon = location.coordinate.longitude
        loc.stopped_duration = 0.0
        loc.speed = location.speed
        loc.timestamp = location.timestamp
        
        if location.speed > 0 {
            loc.stopped = false
        } else {
            loc.stopped = true
        }
        
        locations.append(loc)
        
        return loc.id
    
    }
    
    func updateLocation(id: NSUUID, stoppedDuration: Double, stopped: Bool){
        let locs = locations.filter{$0.id == id}
        let loc = locs.first
        if loc != nil {
            loc?.stopped = stopped

            loc?.stopped_duration = stoppedDuration
        }
    }
    
    
    public func captureOutput(captureOutput: AVCaptureFileOutput!,
        didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!,
        fromConnections connections: [AnyObject]!,
        error: NSError!){
        recording=true
    }

}