//
//  ViewController.swift
//  GGSteps
//
//  Created by Grigor Grigoryan on 11/3/20.
//  Copyright © 2020 Grigor Grigoryan. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    @IBOutlet weak var lblSteps: UILabel!
    @IBOutlet weak var activityState: UILabel!
    @IBOutlet weak var btnStartNow: UIButton!
    @IBOutlet weak var lblCurentValue: UILabel!
    @IBOutlet weak var lblDailySteps: UILabel!
    
    let walkingImages = [UIImage(named: "w1")!, UIImage(named:"w2")!, UIImage(named:"w3")!, UIImage(named:"w4")!, UIImage(named:"w5")!, UIImage(named:"w6")!, UIImage(named:"w7")!, UIImage(named:"w8")!, UIImage(named:"w9")!, UIImage(named:"w10")!]
    
    let runingImages = [UIImage(named: "r1")!, UIImage(named:"r2")!, UIImage(named:"r3")!, UIImage(named:"r4")!, UIImage(named:"r5")!, UIImage(named:"r6")!, UIImage(named:"r7")!, UIImage(named:"r8")!, UIImage(named:"r9")!]
    var days:[String] = []
    var stepsTaken:[Int] = []
    
    private var todayStep: Int = 0
    
    @IBOutlet weak var stateImageView: UIImageView!
    let activityManager = CMMotionActivityManager()
    let pedoMeter = CMPedometer()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        var cal = NSCalendar.current
        var comps = cal.dateComponents([.year, .month, .day, .hour, .minute, .second] , from: Date())
        comps.hour = 0
        comps.minute = 0
        comps.second = 0
        let timeZone = NSTimeZone.system
        cal.timeZone = timeZone
        
        let midnightOfToday = cal.date(from: comps)!
        
        
        if(CMMotionActivityManager.isActivityAvailable()){
            self.activityManager.startActivityUpdates(to: OperationQueue.main, withHandler: { (data: CMMotionActivity!) -> Void in
                DispatchQueue.main.async {
                    if(data.stationary == true){
                        self.activityState.text = "Standing"
                        self.stateImageView.stopAnimating()
                        self.stateImageView.tag = 1
                        
                        self.stateImageView.image = UIImage(named: "statinary")
                    } else if (data.walking == true){
                        self.activityState.text = "Walking"
                        if self.stateImageView.tag != 2 {
                            self.stateImageView.stopAnimating()
                            self.stateImageView.tag = 2
                            self.stateImageView.animationImages = self.walkingImages
                            self.stateImageView.animationDuration = 1.3
                            self.stateImageView.animationRepeatCount = 0
                            self.stateImageView.image = self.stateImageView.animationImages?.first
                            self.stateImageView.startAnimating()
                        }
                    } else if (data.running == true){
                        self.activityState.text = "Running"

                        if self.stateImageView.tag != 3 {
                            self.stateImageView.stopAnimating()
                            self.stateImageView.tag = 3
                            self.stateImageView.animationImages = self.runingImages
                            self.stateImageView.animationDuration = 0.6
                            self.stateImageView.animationRepeatCount = 0
                            self.stateImageView.image = self.stateImageView.animationImages?.first
                            self.stateImageView.startAnimating()
                        }
                    } else if (data.automotive == true){
                        self.activityState.text = "Standing"
                    }
                }
            })
        }
        if(CMPedometer.isStepCountingAvailable()){
            let fromDate = Date(timeIntervalSinceNow: -86400)
            self.pedoMeter.queryPedometerData(from: fromDate, to: Date()) { (data : CMPedometerData!, error) -> Void in
                print(data!)
                DispatchQueue.main.async {
                    if(error == nil){
                        print("++++++++++ \(data.numberOfSteps)")
                        self.lblDailySteps.text = "\(data.numberOfSteps)"
                    }
                }
            }
            
            self.pedoMeter.startUpdates(from: midnightOfToday) { (data: CMPedometerData!, error) -> Void in
                DispatchQueue.main.async {
                    if(error == nil){
                        if self.todayStep == 0 {
                            self.todayStep = data.numberOfSteps.intValue
                        }
                        
                        print("---------- \(data.numberOfSteps)")
                        if self.btnStartNow.isSelected {
                            self.lblSteps.text = "\(data.numberOfSteps.intValue - self.todayStep)"
                        }
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func startNowButtonAction(_ sender: Any) {
        
        btnStartNow.isSelected = !btnStartNow.isSelected
        if btnStartNow.isSelected {
            lblCurentValue.text = "0"
            self.todayStep = 0
            btnStartNow.setTitle("Stop", for: UIControl.State.normal)
        } else {
            btnStartNow.setTitle("Start Now", for: UIControl.State.normal)
        }
        
    }
    
}
