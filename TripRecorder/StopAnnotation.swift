//
//  StopAnnotation.swift
//  TripRecorder
//
//  Created by Xuan Wang on 12/7/14.
//  Copyright (c) 2014 Zach Newell. All rights reserved.
//

import Foundation
import MapKit



public class StopAnnotation: MKPointAnnotation {
    var duration : Double!
}

public class IntersectionAnnotation: MKPointAnnotation {
    var duration : Double!
    var timer : NSTimer!
    var tick  : Int!
    override init(){
        super.init()
        tick = 0
        timer = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self,
            selector: Selector("update"), userInfo: nil, repeats: true)
    }
    
    func update() {
        tick = tick + 1
        self.title = String(tick)
    }
}