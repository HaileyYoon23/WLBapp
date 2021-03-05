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
    
    var txtList: [UITextField] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        DBInit.deleteAllWorkedList()
//        DBInit.deleteTableWorkedList()
//        DBInit.createInfoDB()
//
        txtList = [weekLeastHour, weekLeastMin, dayGoalHour, dayGoalMin, dayLeastHour, dayLeastMin, dayLeastStartHour, dayLeastStartMin]
        
        if let prevInfo = InitDB.readInfo() {
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
        for txt in txtList {
            if let writtenTime = txt.text {
                if writtenTime == "" { txt.text = "00"}
                else {
                    if Int(writtenTime) == nil {
                        present(BasicOperation.AlertWrongInput(WrongInputEnum: .notnumberinput), animated: true, completion: nil)
                        return          // 숫자 입력 하지 않을 시, btnEditComplete 함수 종료 (변경사항 적용 X)
                    }
                }
            } else {
                txt.text = "00"
            }
        }
//        let commuteTimeMinute = Int(txtCommuteHour.text!)! * 60 + Int(txtCommuteMin.text!)!
//        let offworkTimeMinute = Int(txtOffWorkHour.text!)! * 60 + Int(txtOffWorkMin.text!)!
//        if commuteTimeMinute > offworkTimeMinute
//            || isInValidWorkedTime(timeValue: Int(txtCommuteHour.text!)!, kindOfTime: .hour)
//            || isInValidWorkedTime(timeValue: Int(txtCommuteMin.text!)!, kindOfTime: .minute)
//            || isInValidWorkedTime(timeValue: Int(txtOffWorkHour.text!)!, kindOfTime: .hour)
//            || isInValidWorkedTime(timeValue: Int(txtOffWorkMin.text!)!, kindOfTime: .minute) {
//            present(BasicOperation.AlertWrongInput(WrongInputEnum: .wrongworktimeinput), animated: true, completion: nil)
//            return                      // 출근시간이 퇴근시간보다 늦을 경우, btnEditComplete 함수 종료 (변경사항 적용 X)
//        }
        if InitDB.readInfo() != nil {
            InitDB.updateInfo(weekLeastHour: Int(weekLeastHour.text!)!, weekLeastMin: Int(weekLeastMin.text!)!, dayGoalHour: Int(dayGoalHour.text!)!, dayGoalMin: Int(dayGoalMin.text!)!, dayLeastHour: Int(dayLeastHour.text!)!, dayLeastMin: Int(dayLeastMin.text!)!, dayLeastStartHour: Int(dayLeastStartHour.text!)!, dayLeastStartMin: Int(dayLeastStartMin.text!)!, lastUpdatedDate: nil)
        } else {
            _ = InitDB.insertInfo(weekLeastHour: Int(weekLeastHour.text!)!, weekLeastMin: Int(weekLeastMin.text!)!, dayGoalHour: Int(dayGoalHour.text!)!, dayGoalMin: Int(dayGoalMin.text!)!, dayLeastHour: Int(dayLeastHour.text!)!, dayLeastMin: Int(dayLeastMin.text!)!, dayLeastStartHour: Int(dayLeastStartHour.text!)!, dayLeastStartMin: Int(dayLeastStartMin.text!)!, lastUpdatedDate: nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         self.view.endEditing(true)
    }
    

}
