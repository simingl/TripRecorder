//
//  MapPointHandler.swift
//  TripRecorder
//
//  Created by Xuan Wang on 12/7/14.
//  Copyright (c) 2014 Zach Newell. All rights reserved.
//

import Foundation
import MapKit

public class MapPointHandler: NSObject, MKMapViewDelegate {
    
    var mapView : MKMapView
    init(mapView: MKMapView!){
        
        self.mapView = mapView
        
        super.init()
        
        self.mapView.delegate = self
        
    }
    
    public func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        let reuseId = "SA"
        
        if(annotation is MKUserLocation){
            return nil
        }
        
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        
        if (annotation is StopAnnotation){
            var sa = annotation as! StopAnnotation
            var anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            if sa.duration < 3 {
                anView.image = UIImage(named:"red.stop")
            } else {
                anView.image = UIImage(named:"purple.stop")
            }
            anView.canShowCallout = true
            return anView
        }
    
        return nil
    }
}