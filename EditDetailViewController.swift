//
//  EditDetailViewController.swift
//  WLBapp
//
//  Created by 나윤서 on 2021/02/27.
//

import UIKit

class EditDetailViewController: UIViewController {

    @IBOutlet var lblPrinted: UILabel!
    @IBOutlet var btnNonFullDayWork: UIButton!
    @IBOutlet var btnNonHalfDayWork: UIButton!
    @IBOutlet var btnDayWork: UIButton!
    @IBOutlet var txtCommuteHour: UITextField!
    @IBOutlet var txtCommuteMin: UITextField!
    @IBOutlet var txtOffWorkHour: UITextField!
    @IBOutlet var txtOffWorkMin: UITextField!
    @IBOutlet var txtRestHour: UITextField!
    @IBOutlet var txtRestMin: UITextField!
    @IBOutlet var lblRealWorkTime: UILabel!
    
    // Image Initialization
    let imageChecked = UIImage(systemName: "checkmark.square.fill")
    let imageNonChecked = UIImage(systemName: "square")
    
    var fromWhat: String = ""
    var fromDate: Date = Date()
    var fromWeekDay: Int = 0
    
    var dayLeastHour: Int = 0
    var dayLeastMin: Int = 0
    var dayLeastTime: TimeInterval = 0.0
    var nonWorkFullDay = false
    var nonWorkHalfDay = false
    var workDay = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let info = InitDB.readInfo() {
            dayLeastHour = info.dayLeastHour
            dayLeastMin = info.dayLeastMin
        }
        dayLeastTime = TimeInterval(dayLeastHour * 0 + dayLeastMin * 0)
        
        showNameOfWeekDay()
        showPrevWorkItem()
    }
    
    func showPrevWorkItem() {
        if let prevWorkItem = WorkedListDB.readWorkedItem(id: fromDate) {
            let commuteItem = prevWorkItem.commute.split(separator: ":")
            let offWorkItem = prevWorkItem.offWork.split(separator: ":")
            let restTime: TimeInterval = prevWorkItem.rest
            let restHour = Int(restTime / 3600)
            let restMin = Int(restTime / 60) % 60
            let realWorkTime: TimeInterval = prevWorkItem.realWorkedTime
            let realWorkHour = Int(realWorkTime / 3600)
            let realWorkMin = Int(realWorkTime / 60) % 60
            
            txtCommuteHour.text = String(commuteItem[0])
            txtCommuteMin.text = String(commuteItem[1])
            txtOffWorkHour.text = String(offWorkItem[0])
            txtOffWorkMin.text = String(offWorkItem[1])
            txtRestHour.text = String(restHour)
            txtRestMin.text = String(restMin)
            lblRealWorkTime.text = String(format: "%02d : %02d", realWorkHour, realWorkMin)
            
        } else {
            txtCommuteHour.text = "00"
            txtCommuteMin.text = "00"
            txtOffWorkHour.text = "00"
            txtOffWorkMin.text = "00"
            txtRestHour.text = "00"
            txtRestMin.text = "00"
        }
    }
    
    func showNameOfWeekDay() {
        if fromWhat == "Mon" {
            lblPrinted.text = "Monday"
        } else if fromWhat == "Tue" {
            lblPrinted.text = "Tuesday"
        } else if fromWhat == "Wed" {
            lblPrinted.text = "Wednesday"
        } else if fromWhat == "Thr" {
            lblPrinted.text = "Thursday"
        } else if fromWhat == "Fri" {
            lblPrinted.text = "Friday"
        } else if fromWhat == "Sat" {
            lblPrinted.text = "Saturday"
        } else if fromWhat == "Sun" {
            lblPrinted.text = "Sunday"
        }
    }
    
    func modifyWorkStatus(thisDay: Date, statusBefore: Int, statusAfter: Int) {
//        var error = false
        // 우선 변경된 근로 설정에 대해, 해당일의 WorkStatus만 변경
        if statusBefore == statusAfter {
//            present(BasicOperation.AlertToManage(errorCode: "statusSame"), animated: true, completion: nil)
            return
        }
        var tempDate = thisDay
        let thisdayComponent = Calendar.current.dateComponents([.year, .month, .weekOfMonth, .day , .weekday, .hour, .minute, .second], from: thisDay)
        var tempComponent = thisdayComponent
        if thisdayComponent.weekday == 1 {      // 일요일은 토요일의 WeekOfMonth를 따름
            tempComponent = DateComponents(year: thisdayComponent.year, month: thisdayComponent.month, day: thisdayComponent.day! - 1)
            tempDate = Calendar.current.date(from: tempComponent)!
            tempComponent = Calendar.current.dateComponents([.year, .month, .weekOfMonth, .day , .weekday, .hour, .minute, .second], from: tempDate)
        }
        if let _ = WorkedListDB.readWorkedItem(id: thisDay) {
            WorkedListDB.updateWorkedTime(id: thisDay, Commute: nil, OffWork: nil, Rest: nil, RealWorkedTime: nil, WorkedTime: nil, WeekDay: nil, DayWorkStatus: statusAfter, spareTimeIfRealTimeIsNil: nil)
        } else {
            _ = WorkedListDB.insertWorkedTime(id: thisDay, Commute: thisDay, OffWork: thisDay, Rest: 0.0, RealWorkedTime: 0.0, WorkedTime: 0.0, WeekDay: thisdayComponent.weekday ?? -1, DayWorkStatus: statusAfter)
        }
        
        if let prevWeekInfo = WeekDB.readWeekInfo(tempDate) {
            if statusBefore == 4 {              // 비근로(휴가)였다가
                if statusAfter == 5 {           // 반차로 변경
                    WeekDB.updateWeekInfo(id: tempDate, nonworkhour: prevWeekInfo.nonWorkHour - 4, nonworkmin: prevWeekInfo.nonWorkMin, numofnonworkfullday: prevWeekInfo.numOfNonWorkFullDay - 1, numofnonworkhalfday: prevWeekInfo.numOfNonWorkHalfDay + 1)
                } else if statusAfter != 4{     // 근로로 변경
                    WeekDB.updateWeekInfo(id: tempDate, nonworkhour: prevWeekInfo.nonWorkHour - 8, nonworkmin: prevWeekInfo.nonWorkMin, numofnonworkfullday: prevWeekInfo.numOfNonWorkFullDay - 1, numofnonworkhalfday: prevWeekInfo.numOfNonWorkHalfDay)
                }
            } else if statusBefore == 5 {       // 반차였다가
                if statusAfter == 4 {           // 비근로(휴가)로 변경
                    WeekDB.updateWeekInfo(id: tempDate, nonworkhour: prevWeekInfo.nonWorkHour + 4, nonworkmin: prevWeekInfo.nonWorkMin, numofnonworkfullday: prevWeekInfo.numOfNonWorkFullDay + 1, numofnonworkhalfday: prevWeekInfo.numOfNonWorkHalfDay - 1)
                } else if statusAfter != 5 {    // 근로로 변경
                    WeekDB.updateWeekInfo(id: tempDate, nonworkhour: prevWeekInfo.nonWorkHour - 4, nonworkmin: prevWeekInfo.nonWorkMin, numofnonworkfullday: prevWeekInfo.numOfNonWorkFullDay, numofnonworkhalfday: prevWeekInfo.numOfNonWorkHalfDay + 1)
                }
            } else {                            // 근로였다가
                if statusAfter == 5 {           // 반차로 변경
                    WeekDB.updateWeekInfo(id: tempDate, nonworkhour: prevWeekInfo.nonWorkHour + 4, nonworkmin: prevWeekInfo.nonWorkMin, numofnonworkfullday: prevWeekInfo.numOfNonWorkFullDay , numofnonworkhalfday: prevWeekInfo.numOfNonWorkHalfDay + 1)
                } else if statusAfter == 4 {    // 비근로(휴가)로 변경
                    WeekDB.updateWeekInfo(id: tempDate, nonworkhour: prevWeekInfo.nonWorkHour + 8, nonworkmin: prevWeekInfo.nonWorkMin, numofnonworkfullday: prevWeekInfo.numOfNonWorkFullDay + 1, numofnonworkhalfday: prevWeekInfo.numOfNonWorkHalfDay)
                }
            }
        } else {
            present(BasicOperation.AlertToManage(errorCode: "weekInfoNil"), animated: true, completion: nil)
        }
        
        modifyWeekSpareTimeByStatus(thisDay: thisDay, weekofMonthDay: tempDate, thisComponent: thisdayComponent, statusAfter: statusAfter)
    }
    
    func modifyWeekSpareTimeByStatus(thisDay: Date, weekofMonthDay: Date, thisComponent: DateComponents, statusAfter: Int) {
        let weekDayNumber = ((thisComponent.weekday ?? 0) + 5) % 7
        for i in 0..<7 {
            let myDateComponents = DateComponents(year: thisComponent.year, month: thisComponent.month, day: (thisComponent.day ?? 0) - weekDayNumber + i)
            let myDate = Calendar.current.date(from: myDateComponents)!
            if let workedTime = WorkedListDB.readWorkedItem(id: myDate) {
                let myStatus = (i == weekDayNumber) ? statusAfter : workedTime.dayWorkStatus
                if i == 0 {             // 월요일
                    let info = InitDB.readInfo()!
                    let weekInfo = WeekDB.readWeekInfo(myDate)
                    if weekInfo == nil { print("Error WeekInfo nil #mWSTBS")}
                    let initialWorkTime = info.weekLeastHour * 3600 + info.weekLeastMin * 60 - (weekInfo!.numOfNonWorkFullDay * 8 * 3600 + weekInfo!.numOfNonWorkHalfDay * 4 * 3600)
                    WorkedListDB.updateWorkedTime(id: myDate, Commute: nil, OffWork: nil, Rest: nil, RealWorkedTime: nil, WorkedTime: nil, WeekDay: nil, DayWorkStatus: myStatus, spareTimeIfRealTimeIsNil: TimeInterval(initialWorkTime) - workedTime.realWorkedTime)
                } else {
                    var yesterdayComponent = myDateComponents
                    yesterdayComponent.day = yesterdayComponent.day! - 1
                    let yesterDate = Calendar.current.date(from: yesterdayComponent)!
                    let yesterDateItem = WorkedListDB.readWorkedItem(id: yesterDate)!
                    
                    WorkedListDB.updateWorkedTime(id: myDate, Commute: nil, OffWork: nil, Rest: nil, RealWorkedTime: nil, WorkedTime: nil, WeekDay: nil, DayWorkStatus: myStatus, spareTimeIfRealTimeIsNil: yesterDateItem.spareTimeToWork - workedTime.realWorkedTime)
                }
            } else {            // DB 에 없는 경우엔, 전날의 SpareTime 을 바탕으로 insert/update 진행하기에 상관 X. 월요일이 없는 경우엔 weekInfo 설정 시 월요일 SpareTime Insert/Update 진행
            }
        }
    }
    
    func changeWorkStatus(nonworkfullday: Bool, nonworkhalfday: Bool, workday: Bool) {
        var statusbefore: Int = 0
        if let workedItem = WorkedListDB.readWorkedItem(id: fromDate) {
            statusbefore = workedItem.dayWorkStatus
        }
        
        if nonworkfullday {
            modifyWorkStatus(thisDay: fromDate, statusBefore: statusbefore, statusAfter: 4)
        } else if nonworkhalfday {
            modifyWorkStatus(thisDay: fromDate, statusBefore: statusbefore, statusAfter: 5)
        } else if workday {
            // TBD : fromDate의 RealWorkedTime / is today 정보를 확인하여 Status 맞춰 업데이트 해야 함
            modifyWorkStatus(thisDay: fromDate, statusBefore: statusbefore, statusAfter: 0)
        }
    }
    
    @IBAction func btnActNonFullDayWork(_ sender: UIButton) {
        btnNonFullDayWork.setImage(imageChecked, for: .normal)
        btnNonHalfDayWork.setImage(imageNonChecked, for: .normal)
        btnDayWork.setImage(imageNonChecked, for: .normal)
        
        nonWorkFullDay = true
        nonWorkHalfDay = false
        workDay = false
        changeWorkStatus(nonworkfullday: nonWorkFullDay, nonworkhalfday: nonWorkHalfDay, workday: workDay)
    }
    
    @IBAction func btnActNonHalfDayWork(_ sender: UIButton) {
        btnNonFullDayWork.setImage(imageNonChecked, for: .normal)
        btnNonHalfDayWork.setImage(imageChecked, for: .normal)
        btnDayWork.setImage(imageNonChecked, for: .normal)
         
        nonWorkFullDay = false
        nonWorkHalfDay = true
        workDay = false
        changeWorkStatus(nonworkfullday: nonWorkFullDay, nonworkhalfday: nonWorkHalfDay, workday: workDay)
    }
    
    @IBAction func btnActDayWork(_ sender: UIButton) {
        btnNonFullDayWork.setImage(imageNonChecked, for: .normal)
        btnNonHalfDayWork.setImage(imageNonChecked, for: .normal)
        btnDayWork.setImage(imageChecked, for: .normal)
         
        nonWorkFullDay = false
        nonWorkHalfDay = false
        workDay = true
        changeWorkStatus(nonworkfullday: nonWorkFullDay, nonworkhalfday: nonWorkHalfDay, workday: workDay)
    }
    
    @IBAction func btnEditComplete(_ sender: UIButton) { // TBD : Commute Time < OffWork Time 의 조건 필요
        if let prevWorkedItem = WorkedListDB.readWorkedItem(id: fromDate) {
            let CommuteComponent = DateComponents(hour: Int(txtCommuteHour.text!), minute: Int(txtCommuteMin.text!) )
            let CommuteDate = Calendar.current.date(from: CommuteComponent)!
            let OffWorkComponent = DateComponents(hour: Int(txtOffWorkHour.text!), minute: Int(txtOffWorkMin.text!) )
            let OffWorkDate = Calendar.current.date(from: OffWorkComponent)!
            let restTimeInt: Int = ((Int(txtRestHour.text!) ?? -1) * 3600) + ((Int(txtRestMin.text!) ?? -1) * 60)
            let workTime: Int = ((OffWorkComponent.hour!) * 3600 + (OffWorkComponent.minute!) * 60) - ((CommuteComponent.hour!) * 3600 + (CommuteComponent.minute!) * 60)
            let realWorkTime = TimeInterval(workTime - restTimeInt)
            let realWorkHour = Int(realWorkTime / 3600)
            let realWorkMin = Int(realWorkTime / 60) % 60
            var dayWorkStatus = prevWorkedItem.dayWorkStatus
            
            if workDay {
                if realWorkTime >= dayLeastTime {       // TBD : 날짜가 오늘인 경우, dayWorkStatus '1'로 설정해야 한다.
                    dayWorkStatus = 2 /* 정상 출근 완료 */
                }
                
                lblRealWorkTime.text = String(format: "%02d : %02d", realWorkHour, realWorkMin)
            } else if nonWorkFullDay {
                dayWorkStatus = 4
                
            } else if nonWorkHalfDay {
                dayWorkStatus = 5
            }
            
            WorkedListDB.updateWorkedTime(id: fromDate, Commute: CommuteDate, OffWork: OffWorkDate, Rest: TimeInterval(restTimeInt), RealWorkedTime: realWorkTime, WorkedTime: TimeInterval(workTime), WeekDay: prevWorkedItem.weekDay, DayWorkStatus: dayWorkStatus, spareTimeIfRealTimeIsNil: nil)
            
        } else {
            let nonExistItemAlert = UIAlertController(title: "경고", message: "출근 기록이 존재하지 않습니다", preferredStyle: UIAlertController.Style.alert)
            let yesEditAction = UIAlertAction(title: "수정하겠습니다", style: UIAlertAction.Style.default, handler: {ACTION in
                let CommuteComponent = DateComponents(hour: Int(self.txtCommuteHour.text!), minute: Int(self.txtCommuteMin.text!) )
                let CommuteDate = Calendar.current.date(from: CommuteComponent)!
                let OffWorkComponent = DateComponents(hour: Int(self.txtOffWorkHour.text!), minute: Int(self.txtOffWorkMin.text!) )
                let OffWorkDate = Calendar.current.date(from: OffWorkComponent)!
                let restTimeInt: Int = ((Int(self.txtRestHour.text!) ?? -1) * 3600) + ((Int(self.txtRestMin.text!) ?? -1) * 60)
                let workTime: Int = ((OffWorkComponent.hour!) * 3600 + (OffWorkComponent.minute!) * 60) - ((CommuteComponent.hour!) * 3600 + (CommuteComponent.minute!) * 60)
                let realWorkTime = TimeInterval(workTime - restTimeInt)
                let realWorkHour = Int(realWorkTime / 3600)
                let realWorkMin = Int(realWorkTime / 60) % 60
                var dayWorkStatus = 6
                
                if realWorkTime >= self.dayLeastTime {       // TBD : 날짜가 오늘인 경우, dayWorkStatus '1'로 설정해야 한다.
                    dayWorkStatus = 2 /* 정상 출근 완료 */
                }
                
                self.lblRealWorkTime.text = String(format: "%02d : %02d", realWorkHour, realWorkMin)
                _ = WorkedListDB.insertWorkedTime(id: self.fromDate, Commute: CommuteDate, OffWork: OffWorkDate, Rest: TimeInterval(restTimeInt), RealWorkedTime: realWorkTime, WorkedTime: TimeInterval(workTime), WeekDay: self.fromWeekDay, DayWorkStatus: dayWorkStatus)
            })
            let noEditAction = UIAlertAction(title: "수정하지 않겠습니다", style: UIAlertAction.Style.default, handler: nil)
            nonExistItemAlert.addAction(yesEditAction)
            nonExistItemAlert.addAction(noEditAction)
            
            present(nonExistItemAlert, animated: true, completion: nil)
        }
    }
}

// TBD : 입력된 text가 숫자가 아닐 경우에 Error Message 띄워야 함
