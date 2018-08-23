//
//  ViewController.swift
//  NaviaTest
//
//  Created by Suraj on 01/06/1940 Saka.
//  Copyright © 1940 Suraj. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var thursdayModelArray = [ThursdayDietPlanModel]()
    var WednesdayModelArray = [WednesdayModel]()
    var MondayModelArray = [MondayModel]()
    
    var appd = UIApplication.shared.delegate as! AppDelegate
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        UNUserNotificationCenter.current().delegate = self
        
    }

    func scheduleNotifications(_ Index:Int) {
        
        let content = UNMutableNotificationContent()
        let requestIdentifier = "Notification"
        
        //content.badge = 1
        content.title = "Diet Plan for Today"
        content.subtitle = self.thursdayModelArray[Index].food
        content.body = self.thursdayModelArray[Index].food
        content.sound = UNNotificationSound.default()
        
        
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 3.0, repeats: false)
        
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error:Error?) in
            
            if error != nil {
                print(error?.localizedDescription)
            }
            print("Notification Register Success")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.WeekDietPlanAPI()
    }
    
    
    func WeekDietPlanAPI()
    {
        
        self.activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        
        var request = URLRequest(url: URL(string: "https://naviadoctors.com/dummy/")!)
        
        let session = URLSession.shared
        request.httpMethod = "GET"
        
        var err: NSError?
        
        let prettyPrinted:Bool = false
        
        let options = prettyPrinted ?
            JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions(rawValue: 0)
        
      //  request.httpBody = try! JSONSerialization.data(withJSONObject: params, options: options)
        
      //  request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            
            guard data != nil else
            {
                return
            }
            
//            let strData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
//            print("Body: \(strData)")
            
            var err: NSError?
            let json = try! JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as! NSDictionary
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to theconsole
            
            if(err != nil) {
                // print(err!.localizedDescription)
            }
            else
            {
                
                var food:String = ""
                var meal_time:String = ""
                var diet_duration:Int = 0
                
                if (json["diet_duration"] as? Int) != nil{
                    
                    diet_duration = json["diet_duration"] as! Int
                }
                
                if (json["week_diet_data"] as? NSDictionary) != nil{
                    
                    let jsonDict = json["week_diet_data"] as! NSDictionary
                    
                    //print(jsonDict)
                    
                    if (jsonDict["thursday"] as? NSArray) != nil{
                        
                        let thursdayArray = jsonDict["thursday"] as! NSArray
                        
                        if thursdayArray.count > 0{
                            
                            for index:Int in 0 ..< thursdayArray.count{
                                
                                let dict = thursdayArray[index] as! NSDictionary
                                
                                if (dict["food"] as? String) != nil{
                                    food = dict["food"] as! String
                                }
                                
                                if (dict["meal_time"] as? String) != nil{
                                    
                                    meal_time = dict["meal_time"] as! String
                                }
                                
                                let obj = ThursdayDietPlanModel(food: food, meal_time: meal_time, diet_duration: diet_duration)
                                
                                self.thursdayModelArray.append(obj)
                                
                            }
                        }
                    }
                    if (jsonDict["wednesday"] as? NSArray) != nil{
                        
                        let thursdayArray = jsonDict["wednesday"] as! NSArray
                        
                        if thursdayArray.count > 0{
                            
                            for index:Int in 0 ..< thursdayArray.count{
                                
                                let dict = thursdayArray[index] as! NSDictionary
                                
                                if (dict["food"] as? String) != nil{
                                    food = dict["food"] as! String
                                }
                                
                                if (dict["meal_time"] as? String) != nil{
                                    
                                    meal_time = dict["meal_time"] as! String
                                }
                                
                                let obj = WednesdayModel(food: food, meal_time: meal_time, diet_duration: diet_duration)
                                
                                self.WednesdayModelArray.append(obj)
                                
                            }
                        }
                    }
                    if (jsonDict["monday"] as? NSArray) != nil{
                        
                        let thursdayArray = jsonDict["monday"] as! NSArray
                        
                        if thursdayArray.count > 0{
                            
                            for index:Int in 0 ..< thursdayArray.count{
                                
                                let dict = thursdayArray[index] as! NSDictionary
                                
                                if (dict["food"] as? String) != nil{
                                    food = dict["food"] as! String
                                }
                                
                                if (dict["meal_time"] as? String) != nil{
                                    
                                    meal_time = dict["meal_time"] as! String
                                }
                                
                                let obj = MondayModel(food: food, meal_time: meal_time, diet_duration: diet_duration)
                                
                                self.MondayModelArray.append(obj)
                                
                            }
                        }
                    }
                }
                
                
                DispatchQueue.main.async {
                    
                    self.backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: {
                    UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier!)
                    
                })
                
                //print(self.thursdayModelArray.count,self.WednesdayModelArray.count,self.MondayModelArray.count)
                    
                    
                self.startTimer()
                
                self.activityIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
                    
                }
            }
            
        })
        task.resume()
    }
    
    func startTimer() {
        
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.loop), userInfo: nil, repeats: true)
        }
    }
    
    
    @objc func loop()
    {
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        dateFormatter.dateFormat = "HH:mm:ss"
        
        let DateSub = dateFormatter.string(from: Date().adding(minutes: -5))
        let Date24 = dateFormatter.string(from: Date())
        
        //print(DateSub)
        //print(Date24)
        
        if Date().dayOfWeek()! == "thursday".capitalized{
            
            for index:Int in 0 ..< self.thursdayModelArray.count{
                
                if self.thursdayModelArray[index].meal_time + ":00" == Date24{
                    self.scheduleNotifications(index)
                }
            }
        }
        else if Date().dayOfWeek()! == "wednesday".capitalized{
            
            for index:Int in 0 ..< self.WednesdayModelArray.count{
                
                if self.WednesdayModelArray[index].meal_time + ":00" == Date24{
                    
                    self.scheduleNotifications(index)
                    
                }
            }
        }
        else if Date().dayOfWeek()! == "monday".capitalized{
            
            for index:Int in 0 ..< self.MondayModelArray.count{
                
                if self.MondayModelArray[index].meal_time + ":00" == Date24{
                    
                    self.scheduleNotifications(index)
                    
                }
            }
        }
        
    }
    
    
    
}
extension ViewController: UNUserNotificationCenterDelegate {
    
    //for displaying notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        //If you don't want to show notification when app is open, do something here else and make a return here.
        //Even you you don't implement this delegate method, you will not see the notification on the specified controller. So, you have to implement this delegate and make sure the below line execute. i.e. completionHandler.
        
        completionHandler([.alert, .badge, .sound])
    }
    
    // For handling tap and user actions
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        switch response.actionIdentifier {
        case "action1":
            print("Action First Tapped")
        case "action2":
            print("Action Second Tapped")
        default:
            break
        }
        completionHandler()
    }
    
}
extension Date {
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        //.capitalized
        return dateFormatter.string(from: self).capitalized
        // or use capitalized(with: locale) if you want
    }
    func adding(minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }
    
}

