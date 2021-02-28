//
//  ViewController.swift
//  WLBapp
//
//  Created by 나윤서 on 2021/02/11.
//

import UIKit

class ViewController: UIViewController {
    
    // Macro
    let DebugMode: Bool = false
    
    // Outlet Definition //
    @IBOutlet var lblDateInfo: UILabel!
    @IBOutlet var lblDateInfo2: UILabel!
    @IBOutlet var lblMon: UILabel!
    @IBOutlet var lblTue: UILabel!
    @IBOutlet var lblWed: UILabel!
    @IBOutlet var lblThur: UILabel!
    @IBOutlet var lblFri: UILabel!
    @IBOutlet var lblSat: UILabel!
    @IBOutlet var lblSun: UILabel!
    @IBOutlet var lblCurrentTime: UILabel!
    @IBOutlet var lblWorkState: UILabel!
    @IBOutlet var lblWorkingTime: UILabel!
    @IBOutlet var lblCommuteTime: UILabel!
    @IBOutlet var lblOffWorkPossibleTime: UILabel!
    @IBOutlet var ImgView: UIImageView!
    
    // List Of Outlet
    var lblWeekDayList: [UILabel] = []
    
    // Class Var Definition //
    let viewColor = UIColor.darkGray
    var timeInterval = 0.1
    var todayDate: Date = Date()//NSDate() as Date
    var todayCalendar: Calendar = Calendar.current
    var todayComponent = DateComponents()
//    todayCalendar.component([.hour, .minute, .second], from: todayDate)
    let entireFormat: DateFormatter = DateFormatter()
    let simpleFormat: DateFormatter = DateFormatter()
    var orderOfWeek: Int = 0
    var errorValue: Int = -1
    var timeSelector: Selector = #selector(ViewController.updateTime)
    var notWorkTimeSelector: Selector = #selector(ViewController.updateNotWorkTime)
    var curSelector: Selector = #selector(ViewController.updateCurrentTime)
    var offWorkSelector: Selector = #selector(ViewController.updateOffWorkTime)
    var manageSelector: Selector = #selector(ViewController.manageWorkTime)
    var isWorking: Bool = false
    var workingTimer: Timer = Timer()
    var notWorkingTimer: Timer = Timer()
    var workedTime: TimeInterval = 0
    var realWorkedTime: TimeInterval = 0
    var notWorkedTime: TimeInterval = 0
    var commuted: Bool = false
    var commuteComponent: DateComponents = DateComponents()
    var commuteDate: Date = Date()
    var timeToWorkToday:  TimeInterval = 3600 * 8
    
    // DB
    let DBMemory: WorkedListDB = WorkedListDB()
    let DBInfo: InitDB = InitDB()
    let DBWeekInfo: WeekDB = WeekDB()
    
    // Init Info
    var weekLeastHour: Int = -1
    var weekLeastMin: Int = -1
    var dayGoalHour: Int = -1
    var dayGoalMin: Int = -1
    var dayLeastHour: Int = -1
    var dayLeastMin: Int = -1
    var dayLeastStartHour: Int = -1
    var dayLeastStartMin: Int = -1
    
    var dayLeastWorkTime: TimeInterval = -1
    var dayGoalWorkTime: TimeInterval = -1
    
    // Debug Variable
    var debugNextDays: Int = 1
    var debugNextDate: Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // For Debug
        timeInterval = (DebugMode == true) ? 500.0 : timeInterval
        
        // Initialization for code
        lblWeekDayList = [lblMon, lblTue, lblWed, lblThur, lblFri, lblSat, lblSun]
        
        // Label Configuration
        view.backgroundColor = viewColor
        lblWorkingTime.textColor = UIColor.white
        lblWorkingTime.font = UIFont.boldSystemFont(ofSize: 50)
        lblDateInfo.textColor = UIColor.white
        lblDateInfo2.textColor = UIColor.white
        lblMon.textColor = UIColor.white
        lblTue.textColor = UIColor.white
        lblWed.textColor = UIColor.white
        lblThur.textColor = UIColor.white
        lblFri.textColor = UIColor.white
        lblSat.textColor = UIColor.white
        lblSun.textColor = UIColor.white
        lblCurrentTime.textColor = UIColor.white
        
        // Debug Memory Initialization
//        DBMemory.setIdInsertWorkedList()
//        DBMemory.deleteAllWorkedList()
//        DBMemory.deleteTableWorkedList()
//        DBMemory.createTableWorkedList()
//        InitDB.deleteTableWorkedList()
//        DBInfo.createInfoDB()
        
        
        entireFormat.dateFormat = "yyyy.MM.dd (EEE)"
        lblDateInfo.text = entireFormat.string(from: todayDate)
        
        todayComponent = todayCalendar.dateComponents([.year, .month, .weekOfMonth, .day , .weekday, .hour, .minute, .second], from: todayDate)
        lblDateInfo2.text = "\(todayComponent.month ?? errorValue)월 \(todayComponent.weekOfMonth ?? errorValue)째주, 출근 \((todayComponent.weekday ?? errorValue) - 1)일 째"
        lblCurrentTime.text = convertSimpleFormatToPMAMTime(todayComponent)
        _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: curSelector, userInfo: nil, repeats: true)
        
        // 새벽 4시 넘어갈 시 자동 퇴근 및 reset
        _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: manageSelector, userInfo: nil, repeats: true)
        
        // 오늘 기준 이전 weekDay 근로정보 set
        // 월 ~ 어제 근로정보 비어있을 시 초기화 진행. 오늘이 월요일인 경우엔, 수정하지 않음.
        makeThisWeekDayWorkedTime()
        
        // 요일별 색깔 정보 Update
        showDetailWokredListOfWeek()
        
        // Init Info 불러오기 from DB
        initDBs()
        let initInfo = InitDB.readInfo()
        weekLeastHour = initInfo?.weekLeastHour ?? -1
        weekLeastMin = initInfo?.weekLeastMin ?? -1
        dayGoalHour = initInfo?.dayGoalHour ?? -1
        dayGoalMin = initInfo?.dayGoalMin ?? -1
        dayLeastHour = initInfo?.dayLeastHour ?? -1
        dayLeastMin = initInfo?.dayLeastMin ?? -1
        dayLeastStartHour = initInfo?.dayLeastStartHour ?? -1
        dayLeastStartMin = initInfo?.dayLeastStartMin ?? -1
        
        dayLeastWorkTime = Double((dayLeastHour * 3600) + (dayLeastMin * 60))
        dayGoalWorkTime = Double((dayGoalHour * 3600) + (dayGoalMin * 60))
        
        testCode()
    }
    
    func initDBs() {
        var tempDate = todayDate
        
        guard let _ = InitDB.readInfo() else {
            _ = InitDB.insertInfo(weekLeastHour: 40, weekLeastMin: 0, dayGoalHour: 8, dayGoalMin: 0, dayLeastHour: 4, dayLeastMin: 0, dayLeastStartHour: 15, dayLeastStartMin: 0, lastUpdatedDate: nil)
            return
        }
        
        if todayComponent.weekday == 1 {        // 일요일은 토요일의 WeekOfMonth를 따름
            let tempComponent = DateComponents(year: todayComponent.year, month: todayComponent.month, day: todayComponent.day! - 1)
            tempDate = Calendar.current.date(from: tempComponent)!
        }
        
        guard let _ = WeekDB.readWeekInfo(tempDate) else {
            _ = WeekDB.insertWeekInfo(id: tempDate, nonworkhour: 0, nonworkmin: 0, numofnonworkfullday: 0, numofnonworkhalfday: 0)
            return
        }
    }
    
    func makeThisWeekDayWorkedTime(){
        let myDateComponents = Calendar.current.dateComponents([.year, .month, .weekOfMonth, .day , .weekday, .hour, .minute, .second], from: Date())
        if var todayWeekDay = myDateComponents.weekday {
            todayWeekDay = (todayWeekDay + 5) % 7
            if todayWeekDay <= 0 { return }
            for i in 0..<todayWeekDay {         // 월요일부터 update 하기 시작
                let yesterDateComponent = DateComponents(year: myDateComponents.year, month: myDateComponents.month, day: myDateComponents.day! - (todayWeekDay - i), weekday: i)
                let yesterDate = Calendar.current.date(from: yesterDateComponent)!
                let yesterdayWorkedTime = WorkedListDB.readWorkedItem(id: yesterDate)
                if yesterdayWorkedTime == nil {
                    _ = WorkedListDB.insertWorkedTime(id: yesterDate, Commute: yesterDate, OffWork: yesterDate, Rest: 0.0, RealWorkedTime: 0.0, WorkedTime: 0.0, WeekDay: yesterDateComponent.weekday ?? -1, DayWorkStatus: 6 /*근태 수정 필요*/)
                } else {
                    if yesterdayWorkedTime!.realWorkedTime <= dayLeastWorkTime {
                        WorkedListDB.updateWorkedTime(id: yesterDate, Commute: nil, OffWork: nil, Rest: yesterdayWorkedTime!.rest, RealWorkedTime: yesterdayWorkedTime!.realWorkedTime, WorkedTime: yesterdayWorkedTime!.workedTime, WeekDay: yesterdayWorkedTime!.weekDay, DayWorkStatus: 6 /* 근태 수정 필요 */, spareTimeIfRealTimeIsNil: nil)
                    }
                }
            }
        }
    }
    
    // TBD : 요일별 색깔 변하는거 TimeSelector로 변경필요
    func showDetailWokredListOfWeek() {
        let weekDayNumber = ((todayComponent.weekday ?? 0) + 5) % 7
        for i in 0...weekDayNumber {
            // 일주일 Date를 불러오는 API 생성 필요.. 후에 수정해야할 부분
            let myDateComponents = DateComponents(year: todayComponent.year, month: todayComponent.month, day: (todayComponent.day ?? 0) - weekDayNumber + i)
            let myDate = Calendar.current.date(from: myDateComponents)!
            let workedTime = WorkedListDB.readWorkedItem(id: myDate) ?? WorkedItem("--:--", commute: "--:--", offWork: "--:--", rest: 0.0, realWorkedTime: 0.0, workedTime: 0.0, weekDay: 0, dayWorkStatus: 0, spareTimeToWork: 0.0)
            switch workedTime.dayWorkStatus {
            case 0:     // Not Commuted
                lblWeekDayList[i].textColor = viewColor
            case 1:     // Today
                lblWeekDayList[i].textColor = UIColor.white
            case 2:     // Finished Commute
                lblWeekDayList[i].textColor = UIColor.green
            case 3:     // OverWored
                lblWeekDayList[i].textColor = UIColor.yellow
            case 4:     // used vac. (휴가 or 비근로) + 8
                lblWeekDayList[i].textColor = UIColor.blue
            case 5:     // half vac. (반차) +4
                lblWeekDayList[i].textColor = UIColor.systemBlue
            case 6:     // need to modify (근태 수정 필요)
                lblWeekDayList[i].textColor = UIColor.red
            default:
                lblWeekDayList[i].textColor = viewColor
            }
        }
        for j in weekDayNumber+1..<7 {
            lblWeekDayList[j].textColor = viewColor
        }
    }
    
    func convertSimpleFormatToPMAMTime(_ timeComponent: DateComponents) -> String {
        var resultTime: String
        var hour: Int = timeComponent.hour ?? -1
        let minute: Int = timeComponent.minute ?? -1
        let PMorAM: String = (hour >= 12 ? "PM" : "AM")
        hour %= 12
        if hour == 0 {
            hour = 12
        }
        resultTime = PMorAM + String(format: " %02d : %02d", hour, minute) //"\(PMorAM) \(hour) : \(minute)"
        return resultTime
    }
    func convertNSTimeInterval2String(_ time: TimeInterval) -> String {
        realWorkedTime = time
        switch realWorkedTime {
        case (3600*4)..<(3600*4.5):
            realWorkedTime = 3600 * 4
        case (3600*4.5)..<(3600*8.5):
            realWorkedTime -= 3600 * 0.5
        case (3600*8.5)..<(3600*9):
            realWorkedTime = 3600 * 8
        case (3600*9)...:
            realWorkedTime -= 3600
        default:
            break
        }
        
        let hour = Int(realWorkedTime/3600)
        let min = Int(realWorkedTime/60) % 60
        let sec = Int(realWorkedTime.truncatingRemainder(dividingBy: 60))
    
        let strTime = String(format: "%02d:%02d:%02d", hour, min, sec);
        return strTime
    }
    
    func convertToOffWorkTime(_ time: TimeInterval) -> String {
        var info = InitDB.readInfo()
        if info == nil {
            info = Info(40, weekLeastMin: 0, dayGoalHour: 8, dayGoalMin: 0, dayLeastHour: 4, dayLeastMin: 0, dayLeastStartHour: 15, dayLeastStartMin: 0, lastUpdatedDate: nil)
        }
        let todayWeekDay = ((todayComponent.weekday ?? 0) + 5) % 7  // 0 : Mon,  1 : Tue,  2 : Web,  3 : Thr,  4 : Fri,  5 : Sat,  6 : Sun
        var goalMin, goalHour: Int
        if todayWeekDay > 3 {           // 목요일 이후 (금요일부턴) 잔여 근무 시간 기준으로 퇴근 가능시간 계산
            let yesterdayComponent = DateComponents(year: todayComponent.year, month: todayComponent.month, day: todayComponent.day! - 1)
            let result = WorkedListDB.readWorkedItem(id: todayCalendar.date(from: yesterdayComponent) ?? Date())
            var spareTimeOfYesterday = Int(result?.spareTimeToWork ?? -1)
            if spareTimeOfYesterday > 3600 * 8 {
                spareTimeOfYesterday += 60 * 60     // 60분 추가 (휴게시간)
            } else if spareTimeOfYesterday > 3600 * 4 {
                spareTimeOfYesterday += 60 * 30     // 30분 추가 (휴게시간)
            }
            goalHour = spareTimeOfYesterday / 3600
            goalMin = (spareTimeOfYesterday - goalHour * 3600) / 60
            
        } else {        // 평일 목표 근무 시간 8시간 30분
            goalMin = info!.dayGoalMin
            goalHour = info!.dayGoalMin
        }
        var sec = 0  + (commuteComponent.second ?? errorValue) + Int(notWorkedTime.truncatingRemainder(dividingBy: 60))
        var min = goalMin + (commuteComponent.minute ?? errorValue) + Int(notWorkedTime/60) % 60
        var hour = goalHour + (commuteComponent.hour ?? errorValue) + Int(notWorkedTime/3600)

        min += sec/60
        hour += min/60
        sec %= 60
        min %= 60
        
        let strTime = String(format: "%02d:%02d:%02d", hour, min, sec);
        return strTime
    }
    
    @objc func manageWorkTime() {
        todayDate = Date()
        let todayComponent = todayCalendar.dateComponents([.year, .month, .weekOfMonth, .day , .weekday, .hour, .minute, .second], from: todayDate)
        if todayComponent.hour == 4 {       // TBD 수정 필요 equal은 좋지 않아 보임
            if commuted == true {
                if realWorkedTime >= dayGoalWorkTime {
                    WorkedListDB.updateWorkedTime(id: commuteDate, Commute: commuteDate, OffWork: Date(), Rest: notWorkedTime, RealWorkedTime: realWorkedTime, WorkedTime: workedTime, WeekDay: todayComponent.weekday ?? -1, DayWorkStatus: 3 /* 야근 */,spareTimeIfRealTimeIsNil: nil)
                } else if realWorkedTime >= dayLeastWorkTime {
                    WorkedListDB.updateWorkedTime(id: commuteDate, Commute: commuteDate, OffWork: Date(), Rest: notWorkedTime, RealWorkedTime: realWorkedTime, WorkedTime: workedTime, WeekDay: todayComponent.weekday ?? -1, DayWorkStatus: 2 /* 정상 출근 완료 */,spareTimeIfRealTimeIsNil: nil)
                } else {
                    WorkedListDB.updateWorkedTime(id: commuteDate, Commute: commuteDate, OffWork: Date(), Rest: notWorkedTime, RealWorkedTime: realWorkedTime, WorkedTime: workedTime, WeekDay: todayComponent.weekday ?? -1, DayWorkStatus: 6 /* 근태 수정 필요 */,spareTimeIfRealTimeIsNil: nil)
                }
                
                commuted = false
            }
        }
        
    }
    @objc func updateNotWorkTime() {
        notWorkedTime += timeInterval
    }
    @objc func updateCurrentTime() {
        todayDate = Date()
        let todayComponent = todayCalendar.dateComponents([.year, .month, .weekOfMonth, .day , .weekday, .hour, .minute, .second], from: todayDate)
        
        lblCurrentTime.text = convertSimpleFormatToPMAMTime(todayComponent)
    }
    
    @objc func updateTime() {
        workedTime += timeInterval
        lblWorkingTime.text = convertNSTimeInterval2String(workedTime)
    }
    
    @objc func updateOffWorkTime() {
        if(realWorkedTime < timeToWorkToday) {
            lblOffWorkPossibleTime.text = convertToOffWorkTime(workedTime)
        }
    }
    
    // for Debug & Test //
    func testCode() {
//        let myDateComponents = DateComponents(year: 2021, month: 2, day: 28)
//        let myDate = Calendar.current.date(from: myDateComponents)!
//        let myDateComponents_new = Calendar.current.dateComponents([.year, .month, .weekOfMonth, .day , .weekday, .hour, .minute, .second], from: myDate)
//
//        print(myDateComponents_new.weekOfMonth)
    }
    // Debug Button //
    @IBAction func btnDebugPring(_ sender: UIButton) {
        let result = WorkedListDB.readAllWorkedTime()
        for i in 0..<result.count {
            print("\(i) ID \(result[i].workedDate)" + " Commute " + result[i].commute + " OffWork "+result[i].offWork + " Rest \(result[i].rest)" + " RealWorkedTime \(result[i].realWorkedTime)" + " WorkedTime \(result[i].workedTime)" + " WeekDay \(result[i].weekDay)" + " DayWorkStatus \(result[i].dayWorkStatus)" + " SpareTime \(result[i].spareTimeToWork)")
        }
    }
    @IBAction func btnOffWork(_ sender: UIButton) {
        if commuted == true {
            if realWorkedTime >= dayGoalWorkTime {
                WorkedListDB.updateWorkedTime(id: commuteDate, Commute: commuteDate, OffWork: Date(), Rest: notWorkedTime, RealWorkedTime: realWorkedTime, WorkedTime: workedTime, WeekDay: todayComponent.weekday ?? -1, DayWorkStatus: 3 /* 야근 */, spareTimeIfRealTimeIsNil: nil)
            } else if realWorkedTime >= dayLeastWorkTime {
                WorkedListDB.updateWorkedTime(id: commuteDate, Commute: commuteDate, OffWork: Date(), Rest: notWorkedTime, RealWorkedTime: realWorkedTime, WorkedTime: workedTime, WeekDay: todayComponent.weekday ?? -1, DayWorkStatus: 2 /* 정상 출근 완료 */,spareTimeIfRealTimeIsNil: nil)
            } else {
                WorkedListDB.updateWorkedTime(id: commuteDate, Commute: commuteDate, OffWork: Date(), Rest: notWorkedTime, RealWorkedTime: realWorkedTime, WorkedTime: workedTime, WeekDay: todayComponent.weekday ?? -1, DayWorkStatus: 1 /* 정상 */, spareTimeIfRealTimeIsNil: nil)
            }               // TBD : 퇴근을 누른 후에 다음날이 되었는데 전날 시간이 Least에 도달하지 못한 경우에 대한 별도 처리가 필요함
            commuted = false
        }
    }
    @IBAction func btnDebugNextDay(_ sender: UIButton) {
        if commuted == false {
            let myDateComponents = DateComponents(year: commuteComponent.year, month: commuteComponent.month, day: commuteComponent.day! + debugNextDays, hour: 8, minute: 30)
            debugNextDate = todayCalendar.date(from: myDateComponents)!
            let debugNotWorked = 1000.0
            debugNextDays += 1
            if let prevWorkedItem = WorkedListDB.readWorkedItem(id: debugNextDate) {
                notWorkedTime = prevWorkedItem.rest
                realWorkedTime = prevWorkedItem.realWorkedTime
                workedTime = prevWorkedItem.workedTime
                WorkedListDB.updateWorkedTime(id: debugNextDate, Commute: nil, OffWork: debugNextDate, Rest: debugNotWorked, RealWorkedTime: realWorkedTime, WorkedTime: workedTime, WeekDay: commuteComponent.weekday ?? -1, DayWorkStatus: 1, spareTimeIfRealTimeIsNil: nil)
            } else {
                _ = WorkedListDB.insertWorkedTime(id: debugNextDate, Commute: debugNextDate, OffWork: debugNextDate, Rest: debugNotWorked, RealWorkedTime: realWorkedTime, WorkedTime: workedTime, WeekDay: commuteComponent.weekday ?? -1, DayWorkStatus: 1)
            }
            commuted = true
        } else {
            let myDateComponents = DateComponents(year: commuteComponent.year, month: commuteComponent.month, day: commuteComponent.day! + debugNextDays - 1, hour: 17, minute: 30)
            let myDate = todayCalendar.date(from: myDateComponents)!
            let debugNotWorked = 24250.0
            WorkedListDB.updateWorkedTime(id: debugNextDate, Commute: debugNextDate, OffWork: myDate, Rest: debugNotWorked, RealWorkedTime: realWorkedTime, WorkedTime: workedTime, WeekDay: commuteComponent.weekday ?? -1, DayWorkStatus: 1, spareTimeIfRealTimeIsNil: nil)
            
            commuted = false
        }
    }
    @IBAction func btnPrintFromDB(_ sender: UIButton) {
        let result = WorkedListDB.readWorkedItem(id: todayDate)!
        print("ID \(result.workedDate)" + " Commute " + result.commute + " OffWork "+result.offWork + " Rest \(result.rest)" + " RealWorkedTime \(result.realWorkedTime)" + " WorkedTime \(result.workedTime)" + " WeekDay \(result.weekDay)" + " DayWorkStatus \(result.dayWorkStatus)")
    }
    
    
    @IBAction func btnStamp(_ sender: UIButton) {
        if commuted == false {
            commuteDate = Date()
            notWorkedTime = 0
            
            commuted = true
            _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: offWorkSelector, userInfo: nil, repeats: true)
            commuteComponent = todayCalendar.dateComponents([.year, .month, .weekOfMonth, .day , .weekday, .hour, .minute, .second], from: commuteDate)
            
            // TBD : 비근로로 status 변경했는데, 출근 Stamp를 누른 경우?
            // TBD : rest / workedTime / notWorkedTime => 전부 현재 Date()로 계산하도록 변경해야함.
            // App.을 사용하지 않는 동안 Time Count가 되지 않으면서 제대로 update 이루어지지 않고 있음
            if let prevWorkedItem = WorkedListDB.readWorkedItem(id: commuteDate) {
                notWorkedTime = prevWorkedItem.rest
                realWorkedTime = prevWorkedItem.realWorkedTime
                workedTime = prevWorkedItem.workedTime
                WorkedListDB.updateWorkedTime(id: commuteDate, Commute: nil, OffWork: commuteDate, Rest: notWorkedTime, RealWorkedTime: realWorkedTime, WorkedTime: workedTime, WeekDay: commuteComponent.weekday ?? -1, DayWorkStatus: 1, spareTimeIfRealTimeIsNil: nil)
                let commuteTime = prevWorkedItem.commute.split(separator: ":", maxSplits: 2, omittingEmptySubsequences: false)
                commuteComponent = DateComponents(year: commuteComponent.year, month: commuteComponent.month, day: commuteComponent.day! + debugNextDays - 1, hour: Int(commuteTime[0]), minute: Int(commuteTime[1]))
                lblCommuteTime.text = convertSimpleFormatToPMAMTime(commuteComponent)
                // TBD : 휴게시간에 대해 그동안 쉰 시간 추가로 업데이트 필요함 (재시작했을 경우 재시작 전 까지 쉰 시간을 고려하여..)
            } else {
                _ = WorkedListDB.insertWorkedTime(id: commuteDate, Commute: commuteDate, OffWork: commuteDate, Rest: notWorkedTime, RealWorkedTime: realWorkedTime, WorkedTime: workedTime, WeekDay: commuteComponent.weekday ?? -1, DayWorkStatus: 1)
                lblCommuteTime.text = convertSimpleFormatToPMAMTime(commuteComponent)
                InitDB.updateInfo(weekLeastHour: nil, weekLeastMin: nil, dayGoalHour: nil, dayGoalMin: nil, dayLeastHour: nil, dayLeastMin: nil, dayLeastStartHour: nil, dayLeastStartMin: nil, lastUpdatedDate: commuteDate)
            }
        }
        
        if isWorking {
            isWorking = false
            workingTimer.invalidate()
            notWorkingTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: notWorkTimeSelector, userInfo: nil, repeats: true)
            ImgView.image = UIImage(named: "offWork.png")
        } else {
            isWorking = true
            notWorkingTimer.invalidate()
            workingTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: timeSelector, userInfo: nil, repeats: true)
            ImgView.image = UIImage(named: "commute.png")
            WorkedListDB.updateWorkedTime(id: commuteDate, Commute: nil, OffWork: Date(), Rest: notWorkedTime, RealWorkedTime: realWorkedTime, WorkedTime: workedTime, WeekDay: commuteComponent.weekday ?? -1, DayWorkStatus: 1, spareTimeIfRealTimeIsNil: nil)
        }
    }
}

