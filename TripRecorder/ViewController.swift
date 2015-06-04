import UIKit
import AVFoundation
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    //Video
    var captureSession = AVCaptureSession();
    var captureDevice : AVCaptureDevice?
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    //Location
    var locationManager : CLLocationManager?
    var lastLocation    : CLLocation?
    var pointHandler    : MapPointHandler?
    var currentUUID     : NSUUID?
    var isStopped       : Bool!
    
    //Trip
    var currentTrip : Trip?
    
    //Settings
    var settings : AppSettings?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var labelPosition: UILabel!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var startButton: UIButton!
    
    func initUI(){
        //Button
        startButton.layer.borderWidth = 1.0;
        startButton.layer.borderColor = UIColor.blueColor().CGColor
    }
  
    
    func initVideo(){
        // Do any additional setup after loading the view, typically from a nib.
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        let devices = AVCaptureDevice.devices()
        
        // Loop through all the capture devices on this phone
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the back camera
                if(device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice
                }
            }
        }
        
        captureDevice?.lockForConfiguration(nil)
        captureDevice?.focusMode = AVCaptureFocusMode.ContinuousAutoFocus
    }
    
    func initLocation(){
        //LocationManager
        locationManager = CLLocationManager()
        locationManager!.delegate = self
        locationManager!.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager!.requestAlwaysAuthorization()
        locationManager!.startUpdatingLocation()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        initVideo()
        initLocation()
        
        //Settings
        var userSettings = NSUserDefaults.standardUserDefaults()
        var defaultSettings = ["stop_distance":"2.0", "short_stop":"3.0", "long_stop":"5.0"];
        userSettings.registerDefaults(defaultSettings)
        settings = AppSettings()
        
        
        settings?.stopDistance = NSString(string: userSettings.stringForKey("stop_distance")!).doubleValue
        settings?.shortStopTime = NSString(string: userSettings.stringForKey("short_stop")!).doubleValue
        settings?.longStopTime = NSString(string: userSettings.stringForKey("long_stop")!).doubleValue
        
        
        //
        var err : NSError? = nil
        captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: &err))
        
        if err != nil {
            println("error: \(err?.localizedDescription)")
        }
        
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        previewView.layer.addSublayer(previewLayer)
        var bounds:CGRect = self.previewView.layer.bounds
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewLayer?.bounds = bounds
        previewLayer?.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))
        //previewLayer?.frame = previewView.bounds
        //previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill;
        //previewLayer?.bounds = previewLayer!.bounds;
        //previewLayer?.position=CGPointMake(CGRectGetMidX(previewLayer!.bounds), CGRectGetMidY(previewLayer!.bounds));
        
        captureSession.startRunning()
        
        //Map View Configuration
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(MKUserTrackingMode.FollowWithHeading, animated:true)
        self.pointHandler = MapPointHandler(mapView: mapView)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func startTrip(sender: AnyObject) {
        let button = sender as! UIButton;
        
        if self.currentTrip == nil {
            //New Trip Start Recording.
            self.currentTrip = Trip(session: self.captureSession)
            button.setTitle("Stop", forState: UIControlState.Normal)
            self.mapView.removeAnnotations(mapView.annotations)
            
        } else {
            //Stop recording and clean up
            self.currentTrip?.stop()
            self.currentTrip = nil
            button.setTitle("Start", forState: UIControlState.Normal)
        }
        
    }


    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var currentLocation = locations.last as! CLLocation
        var diff: Double = 0.0
        if lastLocation == nil {
            lastLocation = currentLocation
        }
        else {
            var distance = currentLocation.distanceFromLocation(lastLocation);
            diff  = currentLocation.timestamp.timeIntervalSinceDate(lastLocation!.timestamp)
            
            //println("Timestamp \(diff), Speed: \(currentLocation.speed)")
            
            //Check if moved.
            if distance > self.settings?.stopDistance &&
               currentLocation.speed > 0 {
                
                if isStopped == true {
                    var sa = StopAnnotation()
                    sa.duration = diff
                    sa.coordinate = lastLocation!.coordinate
                    mapView.addAnnotation(sa)
                }
                
                lastLocation = currentLocation
                
                if currentTrip != nil {
                    currentUUID = self.currentTrip?.addLocation(lastLocation!)
                }
                isStopped = false
                
            //Stopped
            } else {
                isStopped = true
                if currentTrip != nil &&
                   currentUUID    != nil {
                    self.currentTrip?.updateLocation(currentUUID!, stoppedDuration : diff, stopped: isStopped)
                    //If the uuid has changed add an annotation.
                }
                
            }


            
        }

        
        //Text Attributes
        var attrs = [
            NSFontAttributeName : UIFont.systemFontOfSize(16.0),
            NSForegroundColorAttributeName :UIColor.whiteColor(),
            NSBackgroundColorAttributeName: UIColor.blackColor()
        ]
        
        //Short Stop
        if diff >= self.settings?.shortStopTime  {
            attrs = [
                NSForegroundColorAttributeName :UIColor.whiteColor(),
                NSBackgroundColorAttributeName: UIColor.redColor()
            ]
        }
        
        //Long Stop
        if diff >= self.settings?.longStopTime  {
            attrs = [
                NSForegroundColorAttributeName :UIColor.whiteColor(),
                NSBackgroundColorAttributeName: UIColor.purpleColor()
            ]
        }
        
        //Label Text
        var gString = NSMutableAttributedString(string: String(format: " %.5f, %.5f, %.4f, %.4f",
            currentLocation.coordinate.latitude,
            currentLocation.coordinate.longitude,
            currentLocation.speed,
            diff),
            attributes:attrs)
        
        labelPosition.attributedText = gString
    }

}

