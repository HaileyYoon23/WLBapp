//
//  SettingViewController.swift
//  WLBapp
//
//  Created by 나윤서 on 2021/02/23.
//

import UIKit

class SettingViewController: UIViewController {
    @IBOutlet var weekLeastHour: UITextField!
    @IBOutlet var weekLeastMin: UITextField!
    @IBOutlet var dayGoalHour: UITextField!
    @IBOutlet var dayGoalMin: UITextField!
    @IBOutlet var dayLeastHour: UITextField!
    @IBOutlet var dayLeastMin: UITextField!
    @IBOutlet var dayLeastStartHour: UITextField!
    @IBOutlet var dayLeastStartMin: UITextField!
    
    let DBInit = InitDB()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        DBInit.deleteAllWorkedList()
//        DBInit.deleteTableWorkedList()
//        DBInit.createInfoDB()
//        
        if let prevInfo = DBInit.readInfo() {
            weekLeastHour.text = (((prevInfo.weekLeastHour / 10) == 0) ? "0" : "") + String(prevInfo.weekLeastHour)
            weekLeastMin.text = (((prevInfo.weekLeastMin / 10) == 0) ? "0" : "") + String(prevInfo.weekLeastMin)
            dayGoalHour.text = (((prevInfo.dayGoalHour / 10) == 0) ? "0" : "") + String(prevInfo.dayGoalHour)
            dayGoalMin.text = (((prevInfo.dayGoalMin / 10) == 0) ? "0" : "") + String(prevInfo.dayGoalMin)
            dayLeastHour.text = (((prevInfo.dayLeastHour / 10) == 0) ? "0" : "") + String(prevInfo.dayLeastHour)
            dayLeastMin.text = (((prevInfo.dayLeastMin / 10) == 0) ? "0" : "") + String(prevInfo.dayLeastMin)
            dayLeastStartHour.text = (((prevInfo.dayLeastStartHour / 10) == 0) ? "0" : "") + String(prevInfo.dayLeastStartHour)
            dayLeastStartMin.text = (((prevInfo.dayLeastStartMin / 10) == 0) ? "0" : "") + String(prevInfo.dayLeastStartMin)
            
        } else {
            weekLeastHour.text = String(40)
            weekLeastMin.text = "00"
            dayGoalHour.text = String(8)
            dayGoalMin.text = "00"
            dayLeastHour.text = String(4)
            dayLeastMin.text = "00"
            dayLeastStartHour.text = String(15)
            dayLeastStartMin.text = "00"
        }
    }
    
    @IBAction func btnComplete(_ sender: UIButton) {
        if DBInit.readInfo() != nil {
            DBInit.updateInfo(weekLeastHour: Int(weekLeastHour.text ?? "-1") ?? -1, weekLeastMin: Int(weekLeastMin .text ?? "-1") ?? -1, dayGoalHour: Int(dayGoalHour.text ?? "-1") ?? -1, dayGoalMin: Int(dayGoalMin.text ?? "-1") ?? -1, dayLeastHour: Int(dayLeastHour.text ?? "-1") ?? -1, dayLeastMin: Int(dayLeastMin.text ?? "-1") ?? -1, dayLeastStartHour: Int(dayLeastStartHour.text ?? "-1") ?? -1, dayLeastStartMin: Int(dayLeastStartMin.text ?? "-1") ?? -1)
        } else {
            _ = DBInit.insertInfo(weekLeastHour: Int(weekLeastHour.text ?? "-1") ?? -1, weekLeastMin: Int(weekLeastMin .text ?? "-1") ?? -1, dayGoalHour: Int(dayGoalHour.text ?? "-1") ?? -1, dayGoalMin: Int(dayGoalMin.text ?? "-1") ?? -1, dayLeastHour: Int(dayLeastHour.text ?? "-1") ?? -1, dayLeastMin: Int(dayLeastMin.text ?? "-1") ?? -1, dayLeastStartHour: Int(dayLeastStartHour.text ?? "-1") ?? -1, dayLeastStartMin: Int(dayLeastStartMin.text ?? "-1") ?? -1)
        }
    }
    

}
