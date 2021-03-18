//
//  EditDetailViewController.swift
//  WLBapp
//
//  Created by 나윤서 on 2021/02/27.
//

import UIKit

enum Time {
    case hour
    case minute
    case second
}

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
    var dayGoalHour: Int = 0
    var dayGoalMin: Int = 0
    var dayLeastStartHour: Int = 0
    var dayLeastStartMin: Int = 0
    var dayLeastTime: TimeInterval = 0.0
    var dayGoalTime: TimeInterval = 0.0
    var dayLeastStartTime: TimeInterval = 0.0
    var nonWorkFullDay = false
    var nonWorkHalfDay = false
    var workDay = true
    var txtList = [UITextField]()
    var todayComponent = DateComponents()
    var fromDateComponent = DateComponents()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Init Variable
        txtList = [txtCommuteHour, txtCommuteMin, txtOffWorkHour, txtOffWorkMin, txtRestHour, txtRestMin]
        
        if let info = InitDB.readInfo() {
            dayLeastHour = info.dayLeastHour
            dayLeastMin = info.dayLeastMin
            dayGoalHour = info.dayGoalHour
            dayGoalMin = info.dayGoalMin
            dayLeastStartHour = info.dayLeastStartHour
            dayLeastStartMin = info.dayLeastStartMin
        }
        dayLeastTime = TimeInterval(dayLeastHour * 3600 + dayLeastMin * 60)
        dayGoalTime = TimeInterval(dayGoalHour * 3600 + dayGoalMin * 60)
        dayLeastStartTime = TimeInterval(dayLeastStartHour * 3600 + dayLeastStartMin * 60)
        
        setCheckedImage()
        showNameOfWeekDay()
        showPrevWorkItem()
        
        todayComponent = Calendar.current.dateComponents([.year, .month, .weekOfMonth, .day , .weekday, .hour, .minute, .second], from: Date())
        fromDateComponent = Calendar.current.dateComponents([.year, .month, .weekOfMonth, .day , .weekday, .hour, .minute, .second], from: fromDate)
        
        txtOffWorkHour.isUserInteractionEnabled = true
        txtOffWorkMin.isUserInteractionEnabled = true
        txtOffWorkHour.backgroundColor = UIColor.white
        txtOffWorkMin.backgroundColor = UIColor.white
        
        if fromDateComponent.day! == todayComponent.day! {
            if let todayItem = WorkedListDB.readWorkedItem(id: fromDate) {
                let isWorking = todayItem.isWorking
                if isWorking {
                    txtOffWorkHour.isUserInteractionEnabled = false
                    txtOffWorkMin.isUserInteractionEnabled = false
                    txtOffWorkHour.backgroundColor = UIColor.lightGray
                    txtOffWorkMin.backgroundColor = UIColor.lightGray
                }
            }
        }
    }
    
    func setCheckedImage() {
        if let fromDateItem = WorkedListDB.readWorkedItem(id: fromDate) {
            let status = fromDateItem.dayWorkStatus
            switch status {
            case 4:
                btnNonFullDayWork.setImage(imageChecked, for: .normal)
            case 5:
                btnNonHalfDayWork.setImage(imageChecked, for: .normal)
            default:
                btnDayWork.setImage(imageChecked, for: .normal)
            }
        }
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
            print(fromDate)
            print(realWorkTime)
            
            txtCommuteHour.text = String(commuteItem[0])
            txtCommuteMin.text = String(commuteItem[1])
            txtOffWorkHour.text = String(offWorkItem[0])
            txtOffWorkMin.text = String(offWorkItem[1])
            txtRestHour.text = (restHour == 0) ? "00" : String(restHour)
            txtRestMin.text = (restMin == 0) ? "00" : String(restMin)
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
            WorkedListDB.updateWorkedTime(id: thisDay, Commute: nil, OffWork: nil, LastAppUse: Date(), Rest: nil, RealWorkedTime: nil, WorkedTime: nil, WeekDay: nil, DayWorkStatus: statusAfter, spareTimeIfRealTimeIsNil: nil, IsWorking: nil)
        } else {
            _ = WorkedListDB.insertWorkedTime(id: thisDay, Commute: thisDay, OffWork: thisDay, LastAppUse: Date(), Rest: 0.0, RealWorkedTime: 0.0, WorkedTime: 0.0, WeekDay: thisdayComponent.weekday ?? -1, DayWorkStatus: statusAfter, IsWorking: false)
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
                    WorkedListDB.updateWorkedTime(id: myDate, Commute: nil, OffWork: nil, LastAppUse: Date(), Rest: nil, RealWorkedTime: nil, WorkedTime: nil, WeekDay: nil, DayWorkStatus: myStatus, spareTimeIfRealTimeIsNil: TimeInterval(initialWorkTime) - workedTime.realWorkedTime, IsWorking: nil)
                } else {
                    var yesterdayComponent = myDateComponents
                    yesterdayComponent.day = yesterdayComponent.day! - 1
                    let yesterDate = Calendar.current.date(from: yesterdayComponent)!
                    let yesterDateItem = WorkedListDB.readWorkedItem(id: yesterDate)!
                    
                    WorkedListDB.updateWorkedTime(id: myDate, Commute: nil, OffWork: nil, LastAppUse: Date(), Rest: nil, RealWorkedTime: nil, WorkedTime: nil, WeekDay: nil, DayWorkStatus: myStatus, spareTimeIfRealTimeIsNil: yesterDateItem.spareTimeToWork - workedTime.realWorkedTime, IsWorking: nil)
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
            var workdayStatusAfter = 0
            let fromDateComponent = Calendar.current.dateComponents([.year, .month, .day], from: fromDate)
            let todayDateComponent = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            if let fromDateWorkedItem = WorkedListDB.readWorkedItem(id: fromDate) {
                if fromDateComponent.month == todayDateComponent.month && fromDateComponent.day == todayDateComponent.day {     // 오늘에 대해 근로로 Edit
                    workdayStatusAfter = 1
                } else {
                    let info = InitDB.readInfo()!
                    let commuteArr = fromDateWorkedItem.commute.split(separator: ":")
                    if fromDateWorkedItem.realWorkedTime >= TimeInterval(info.dayGoalHour * 3600 + info.dayGoalMin * 60) {
                        workdayStatusAfter = 3
                    } else if fromDateWorkedItem.realWorkedTime >= TimeInterval(info.dayLeastHour * 3600 + info.dayLeastMin * 60) {
                        workdayStatusAfter = 2
                    } else if (Int(commuteArr[0])! * 60 + Int(commuteArr[1])!) > (info.dayLeastStartHour * 60 + info.dayLeastStartMin){
                        workdayStatusAfter = 7
                    } else { workdayStatusAfter = 6 }
                }
            } else {
                workdayStatusAfter = 0
            }
            modifyWorkStatus(thisDay: fromDate, statusBefore: statusbefore, statusAfter: workdayStatusAfter)
        }
    }
    
    func isInValidWorkedTime(timeValue: Int?, kindOfTime: Time) -> Bool {
        if let tV = timeValue {
            switch kindOfTime {
            case .hour:
                if tV >= 0 && tV <= 23 {
                    return false
                }
            case .minute:
                if tV >= 0 && tV <= 59 {
                    return false
                }
            case .second:
                if tV >= 0 && tV <= 59 {
                    return false
                }
            }
        }
        return true
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
    
    @IBAction func btnEditComplete(_ sender: UIButton) {
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
        let commuteTimeMinute = Int(txtCommuteHour.text!)! * 60 + Int(txtCommuteMin.text!)!
        let offworkTimeMinute = Int(txtOffWorkHour.text!)! * 60 + Int(txtOffWorkMin.text!)!
        if commuteTimeMinute > offworkTimeMinute
            || isInValidWorkedTime(timeValue: Int(txtCommuteHour.text!)!, kindOfTime: .hour)
            || isInValidWorkedTime(timeValue: Int(txtCommuteMin.text!)!, kindOfTime: .minute)
            || isInValidWorkedTime(timeValue: Int(txtOffWorkHour.text!)!, kindOfTime: .hour)
            || isInValidWorkedTime(timeValue: Int(txtOffWorkMin.text!)!, kindOfTime: .minute) {
            present(BasicOperation.AlertWrongInput(WrongInputEnum: .wrongworktimeinput), animated: true, completion: nil)
            return                      // 출근시간이 퇴근시간보다 늦을 경우, btnEditComplete 함수 종료 (변경사항 적용 X)
        }
        
        
        if let prevWorkedItem = WorkedListDB.readWorkedItem(id: fromDate) {
            let CommuteComponent = DateComponents(hour: Int(txtCommuteHour.text!), minute: Int(txtCommuteMin.text!))
            let CommuteDate = Calendar.current.date(from: CommuteComponent)!
            let OffWorkComponent = DateComponents(hour: Int(txtOffWorkHour.text!), minute: Int(txtOffWorkMin.text!))
            let OffWorkDate = Calendar.current.date(from: OffWorkComponent)!
            let restTimeInt: Int = ((Int(txtRestHour.text!) ?? -1) * 3600) + ((Int(txtRestMin.text!) ?? -1) * 60)
            let restTime: TimeInterval = TimeInterval(restTimeInt)
            let workTimeInt: Int = ((OffWorkComponent.hour!) * 3600 + (OffWorkComponent.minute!) * 60) - ((CommuteComponent.hour!) * 3600 + (CommuteComponent.minute!) * 60)
            let workTime = TimeInterval(workTimeInt - restTimeInt)
            var realWorkTime = workTime
            switch realWorkTime {
                case (3600*4)..<(3600*4.5):
                    realWorkTime = 3600 * 4
                case (3600*4.5)..<(3600*8.5):
                    realWorkTime -= 3600 * 0.5
                case (3600*8.5)..<(3600*9):
                    realWorkTime = 3600 * 8
                case (3600*9)...:
                    realWorkTime -= 3600
                default:
                    break
            }
            let realWorkHour = Int(realWorkTime / 3600)
            let realWorkMin = Int(realWorkTime / 60) % 60
            let commuteArr = prevWorkedItem.commute.split(separator: ":")
            let commuteTimeInterval = TimeInterval(Int(commuteArr[0])! * 3600 + Int(commuteArr[1])! * 60 + Int(commuteArr[2])!)
            
            var dayWorkStatus = prevWorkedItem.dayWorkStatus
            
            if workDay {
                if commuteTimeInterval > dayLeastStartTime {
                    dayWorkStatus = 7 /* 지각 */
                } else if realWorkTime > dayGoalTime {
                    dayWorkStatus = 3 /* 야근 */
                } else if realWorkTime < dayLeastTime {
                    dayWorkStatus = 6 /* 근태 수정 필요 */
                } else if realWorkTime >= dayLeastTime {
                    dayWorkStatus = 2 /* 정상 출근 완료 */
                }
                
                lblRealWorkTime.text = String(format: "%02d : %02d", realWorkHour, realWorkMin)
            } else if nonWorkFullDay {
                dayWorkStatus = 4
                
            } else if nonWorkHalfDay {
                dayWorkStatus = 5
            }
            WorkedListDB.updateWorkedTime(id: fromDate, Commute: CommuteDate, OffWork: OffWorkDate, LastAppUse: Date(), Rest: restTime, RealWorkedTime: realWorkTime, WorkedTime: workTime, WeekDay: prevWorkedItem.weekDay, DayWorkStatus: dayWorkStatus, spareTimeIfRealTimeIsNil: nil, IsWorking: nil)
            
            let todayComponent = Calendar.current.dateComponents([.year, .month, .weekOfMonth, .day , .weekday, .hour, .minute, .second], from: Date())
            let fromDateComponent = Calendar.current.dateComponents([.year, .month, .weekOfMonth, .day , .weekday, .hour, .minute, .second], from: fromDate)
            
            
            if fromDateComponent.day! == todayComponent.day! {          // if fromDate is Today!
                ViewController.notWorkedTime = restTime
                ViewController.realWorkedTime = realWorkTime
                ViewController.workedTime = workTime
            }
            
            var nextDateComponent = Calendar.current.dateComponents([.year, .month, .weekOfMonth, .day , .weekday, .hour, .minute, .second], from: fromDate)
            nextDateComponent = DateComponents(year: nextDateComponent.year, month: nextDateComponent.month, day: nextDateComponent.day! + 1)
            var nextDate = Calendar.current.date(from: nextDateComponent)!
            var tempComponent = Calendar.current.dateComponents([.year, .month, .weekOfMonth, .day , .weekday, .hour, .minute, .second], from: nextDate)
            while let nextDateWorkedItem = WorkedListDB.readWorkedItem(id: nextDate) {
                WorkedListDB.updateWorkedTime(id: nextDate, Commute: nil, OffWork: nil, LastAppUse: nil, Rest: nil, RealWorkedTime: nextDateWorkedItem.realWorkedTime, WorkedTime: nil, WeekDay: tempComponent.weekday, DayWorkStatus: nil, spareTimeIfRealTimeIsNil: nil, IsWorking: nil)

                nextDateComponent = DateComponents(year: tempComponent.year, month: tempComponent.month, day: tempComponent.day! + 1)
                nextDate = Calendar.current.date(from: nextDateComponent)!
                tempComponent = Calendar.current.dateComponents([.year, .month, .weekOfMonth, .day , .weekday, .hour, .minute, .second], from: nextDate)
            }
            
        } else {
            let nonExistItemAlert = UIAlertController(title: "경고", message: "출근 기록이 존재하지 않습니다", preferredStyle: UIAlertController.Style.alert)
            // TDB : 아직 출근하지 않은 날짜 Edit한 후 출근 Stamp 찍을 시에 대한 코드 필요
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
                
                if realWorkTime >= self.dayLeastTime {
                    dayWorkStatus = 2 /* 정상 출근 완료 */
                }
                
                self.lblRealWorkTime.text = String(format: "%02d : %02d", realWorkHour, realWorkMin)
                _ = WorkedListDB.insertWorkedTime(id: self.fromDate, Commute: CommuteDate, OffWork: OffWorkDate, LastAppUse: Date(), Rest: TimeInterval(restTimeInt), RealWorkedTime: realWorkTime, WorkedTime: TimeInterval(workTime), WeekDay: self.fromWeekDay, DayWorkStatus: dayWorkStatus, IsWorking: false)
            })
            let noEditAction = UIAlertAction(title: "수정하지 않겠습니다", style: UIAlertAction.Style.default, handler: nil)
            nonExistItemAlert.addAction(yesEditAction)
            nonExistItemAlert.addAction(noEditAction)
            
            present(nonExistItemAlert, animated: true, completion: nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         self.view.endEditing(true)
    }
}

// TBD : 입력된 text가 숫자가 아닐 경우에 Error Message 띄워야 함
