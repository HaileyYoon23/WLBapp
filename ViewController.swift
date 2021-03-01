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
    @IBOutlet var lblBigWorkingTime: UILabel!
    @IBOutlet var lblCommuteTime: UILabel!
    @IBOutlet var lblOffWorkPossibleTime: UILabel!
    @IBOutlet var lblButtonMessage: UILabel!
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
    var showdetailSelector: Selector = #selector(ViewController.showDetailWokredListOfWeek)
    var viewSelector: Selector = #selector(ViewController.updateView)
    var isWorking: Bool = false
    var isCommute: Bool = false
    var workingTimer: Timer = Timer()
    var notWorkingTimer: Timer = Timer()
    var workedTime: TimeInterval = 0
    var realWorkedTime: TimeInterval = 0
    var notWorkedTime: TimeInterval = 0
    var commuteComponent: DateComponents = DateComponents()
    var commuteDate: Date = Date()
    var timeToWorkToday:  TimeInterval = 3600 * 8
    
    // DB
    let DBMemory: WorkedListDB = WorkedListDB()
    let DBInfo: InitDB = InitDB()
    let DBWeekInfo: WeekDB = WeekDB()
    
    // Init Info
    var weekLeastHour: Int = 40
    var weekLeastMin: Int = 0
    var dayGoalHour: Int = 8
    var dayGoalMin: Int = 0
    var dayLeastHour: Int = 4
    var dayLeastMin: Int = 0
    var dayLeastStartHour: Int = 15
    var dayLeastStartMin: Int = 0
    
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
        lblBigWorkingTime.textColor = UIColor.white
//        lblWorkingTime.font = UIFont.boldSystemFont(ofSize: 50)
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
//        WorkedListDB.deleteTableWorkedList()
//        DBMemory.createTableWorkedList()
//        InitDB.deleteTableWorkedList()
//        DBInfo.createInfoDB()
        
        
        entireFormat.dateFormat = "yyyy.MM.dd (EEE)"
        todayDate = Date()
        lblDateInfo.text = entireFormat.string(from: todayDate)
        todayComponent = todayCalendar.dateComponents([.year, .month, .weekOfMonth, .day , .weekday, .hour, .minute, .second], from: todayDate)
        lblDateInfo2.text = "\(todayComponent.month ?? errorValue)월 \(todayComponent.weekOfMonth ?? errorValue)째주, 출근 \((todayComponent.weekday ?? errorValue) - 1)일 째"
        lblCurrentTime.text = convertSimpleFormatToPMAMTime(todayComponent)
        
        // Init Info 불러오기 from DB
        initDBs()
        let initInfo = InitDB.readInfo()
        weekLeastHour = initInfo?.weekLeastHour ?? 40
        weekLeastMin = initInfo?.weekLeastMin ?? 0
        dayGoalHour = initInfo?.dayGoalHour ?? 8
        dayGoalMin = initInfo?.dayGoalMin ?? 0
        dayLeastHour = initInfo?.dayLeastHour ?? 4
        dayLeastMin = initInfo?.dayLeastMin ?? 0
        dayLeastStartHour = initInfo?.dayLeastStartHour ?? 15
        dayLeastStartMin = initInfo?.dayLeastStartMin ?? 0
        
        dayLeastWorkTime = Double((dayLeastHour * 3600) + (dayLeastMin * 60))
        dayGoalWorkTime = Double((dayGoalHour * 3600) + (dayGoalMin * 60))
        
        _ = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: curSelector, userInfo: nil, repeats: true)
        
        // 새벽 4시 넘어갈 시 자동 퇴근 및 reset
        _ = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: manageSelector, userInfo: nil, repeats: true)
        
        // 요일별 색깔 정보 Update
        _ = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: showdetailSelector, userInfo: nil, repeats: true)
        
        // 업무 진행별 View update
        _ = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: viewSelector, userInfo: nil, repeats: true)
        
        // 오늘 기준 이전 weekDay 근로정보 set
        // 월 ~ 어제 근로정보 비어있을 시 초기화 진행. 오늘이 월요일인 경우엔, 수정하지 않음.
        makeThisWeekDayWorkedTime()
        if isCommute {
            if isWorking {
                actionWhenIsWorking()
            } else {
                actionWhenIsNotWorking()
            }
        }
        
        testCode()
    }
    
    func initDBs() {
        var tempDate = todayDate
        
        if let _ = WorkedListDB.readWorkedItem(id: Date()) {
            isCommute = true
        }
        
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
        
        // isWorking을 바탕으로 WorkedTime / NonWorkedTime / RealWorkedTime 업데이트
        if let prevTodayWorkItem = WorkedListDB.readWorkedItem(id: todayDate) {
            let prevTimeArr = prevTodayWorkItem.lastAppUse.split(separator: ":")
            isWorking = prevTodayWorkItem.isWorking
            let nowTimeInterval = (todayComponent.hour! - Int(prevTimeArr[0])!) * 3600 + (todayComponent.minute! - Int(prevTimeArr[1])!) * 60 + (todayComponent.second! - Int(prevTimeArr[2])!)     // 어플 마지막 사용 시간으로 부터 얼마나 지났는지
            
            if isWorking {
                let nowWorkedTime = prevTodayWorkItem.workedTime + TimeInterval(nowTimeInterval)
                _ = convertNSTimeInterval2String(nowWorkedTime, isBigOne: false)
                WorkedListDB.updateWorkedTime(id: todayDate, Commute: nil, OffWork: todayDate, LastAppUse: Date(),Rest: nil, RealWorkedTime: realWorkedTime, WorkedTime: nowWorkedTime, WeekDay: todayComponent.weekday, DayWorkStatus: nil, spareTimeIfRealTimeIsNil: nil, IsWorking: isWorking)
                lblWorkingTime.text = convertNSTimeInterval2String(nowWorkedTime, isBigOne: false)
                lblBigWorkingTime.text = convertNSTimeInterval2String(nowWorkedTime, isBigOne: true)
            } else {
                let nowNotWorkedTime = prevTodayWorkItem.rest + TimeInterval(nowTimeInterval)
                WorkedListDB.updateWorkedTime(id: todayDate, Commute: nil, OffWork: nil, LastAppUse: Date(), Rest: nowNotWorkedTime, RealWorkedTime: prevTodayWorkItem.realWorkedTime, WorkedTime: nil, WeekDay: todayComponent.weekday, DayWorkStatus: nil, spareTimeIfRealTimeIsNil: nil, IsWorking: isWorking)
                lblWorkingTime.text = convertNSTimeInterval2String(prevTodayWorkItem.workedTime, isBigOne: false)
                lblBigWorkingTime.text = convertNSTimeInterval2String(prevTodayWorkItem.workedTime, isBigOne: true)
            }
            
            let commuteArr = prevTodayWorkItem.commute.split(separator: ":")
            let commuteComponent = DateComponents(hour: Int(commuteArr[0])!, minute: Int(commuteArr[1])!, second: Int(commuteArr[2])!)
            lblCommuteTime.text = convertSimpleFormatToPMAMTime(commuteComponent)
            
        } else {
            isWorking = false
            isCommute = false
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
                    _ = WorkedListDB.insertWorkedTime(id: yesterDate, Commute: yesterDate, OffWork: yesterDate, LastAppUse: Date(), Rest: 0.0, RealWorkedTime: 0.0, WorkedTime: 0.0, WeekDay: yesterDateComponent.weekday ?? -1, DayWorkStatus: 6 /*근태 수정 필요*/, IsWorking: false)
                } else {
                    if yesterdayWorkedTime!.realWorkedTime <= dayLeastWorkTime {
                        WorkedListDB.updateWorkedTime(id: yesterDate, Commute: nil, OffWork: nil, LastAppUse: Date(), Rest: yesterdayWorkedTime!.rest, RealWorkedTime: yesterdayWorkedTime!.realWorkedTime, WorkedTime: yesterdayWorkedTime!.workedTime, WeekDay: yesterdayWorkedTime!.weekDay, DayWorkStatus: 6 /* 근태 수정 필요 */, spareTimeIfRealTimeIsNil: nil, IsWorking: false)
                    }
                }
            }
        }
    }
    
    @objc func updateView() {
        var percentage: Int = 2
        if let workItem = WorkedListDB.readWorkedItem(id: Date()) {
            percentage = Int(((workItem.realWorkedTime) / (dayGoalWorkTime)) * 60) + 2
        }
        var imageName =  "제목_없는_아트워크 \(percentage).png"
        
        if isWorking {
            ImgView.image = UIImage(named: imageName)
        } else {
            ImgView.image = UIImage(named: "offWork.png")
        }
    }
    
    
    func convertSimpleFormatToPMAMTime(_ timeComponent: DateComponents) -> String {
        var resultTime: String
        var hour: Int = timeComponent.hour ?? -1
        let minute: Int = timeComponent.minute ?? -1
        let PMorAM: String = (hour >= 12 ? "PM" : "AM")
        
        todayDate = Date()
        todayComponent = todayCalendar.dateComponents([.year, .month, .weekOfMonth, .day , .weekday, .hour, .minute, .second], from: todayDate)
        
        hour %= 12
        if hour == 0 {
            hour = 12
        }
        resultTime = PMorAM + String(format: " %02d : %02d", hour, minute) //"\(PMorAM) \(hour) : \(minute)"
        return resultTime
    }
    func convertNSTimeInterval2String(_ time: TimeInterval, isBigOne: Bool) -> String {
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
    
        if isBigOne {
            let strTime = String(format: "%02d:%02d", hour, min);
            return strTime
        } else {
            let strTime = String(format: "%02d s",sec);
            return strTime
        }
        
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
            goalHour = info!.dayGoalHour
        }
        var sec, min, hour : Int
        if let workedItem = WorkedListDB.readWorkedItem(id: Date()){
            let commuteTimeArr = workedItem.commute.split(separator: ":")
            
            sec = 0 + Int(notWorkedTime.truncatingRemainder(dividingBy: 60))
            min = goalMin + Int(commuteTimeArr[1])! + Int(notWorkedTime/60) % 60
            hour = goalHour + Int(commuteTimeArr[0])! + Int(notWorkedTime/3600)
        } else {
            
            sec = 0 + todayComponent.second!
            min = goalMin + todayComponent.minute!
            hour = goalHour + todayComponent.hour!
        }

        min += sec/60
        hour += min/60
        sec %= 60
        min %= 60
        
        let strTime = String(format: "%02d:%02d:%02d", hour, min, sec);
        return strTime
    }
    
    func actionWhenIsWorking() {
        notWorkingTimer.invalidate()
        
        commuteDate = Date()
        lblButtonMessage.text = "클릭 시 퇴근!"
        
        commuteComponent = todayCalendar.dateComponents([.year, .month, .weekOfMonth, .day , .weekday, .hour, .minute, .second], from: commuteDate)
        
        // App.을 사용하지 않는 동안 Time Count가 되지 않으면서 제대로 update 이루어지지 않고 있음
        if let prevWorkedItem = WorkedListDB.readWorkedItem(id: commuteDate) {
            notWorkedTime = prevWorkedItem.rest
            realWorkedTime = prevWorkedItem.realWorkedTime
            workedTime = prevWorkedItem.workedTime
            WorkedListDB.updateWorkedTime(id: commuteDate, Commute: nil, OffWork: commuteDate, LastAppUse: Date(), Rest: notWorkedTime, RealWorkedTime: realWorkedTime, WorkedTime: workedTime, WeekDay: commuteComponent.weekday ?? -1, DayWorkStatus: nil, spareTimeIfRealTimeIsNil: nil, IsWorking: isWorking)
            let commuteTime = prevWorkedItem.commute.split(separator: ":", maxSplits: 2, omittingEmptySubsequences: false)
            commuteComponent = DateComponents(year: commuteComponent.year, month: commuteComponent.month, day: commuteComponent.day! + debugNextDays - 1, hour: Int(commuteTime[0]), minute: Int(commuteTime[1]))
            lblCommuteTime.text = convertSimpleFormatToPMAMTime(commuteComponent)
        } else {
            _ = WorkedListDB.insertWorkedTime(id: commuteDate, Commute: commuteDate, OffWork: commuteDate, LastAppUse: Date(), Rest: notWorkedTime, RealWorkedTime: realWorkedTime, WorkedTime: workedTime, WeekDay: commuteComponent.weekday ?? -1, DayWorkStatus: 1, IsWorking: isWorking)
            lblCommuteTime.text = convertSimpleFormatToPMAMTime(commuteComponent)
            InitDB.updateInfo(weekLeastHour: nil, weekLeastMin: nil, dayGoalHour: nil, dayGoalMin: nil, dayLeastHour: nil, dayLeastMin: nil, dayLeastStartHour: nil, dayLeastStartMin: nil, lastUpdatedDate: commuteDate)
            isCommute = true
        }
        
        workingTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: timeSelector, userInfo: nil, repeats: true)
        _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: offWorkSelector, userInfo: nil, repeats: true)
    }
    
    func actionWhenIsNotWorking() {
        workingTimer.invalidate()
        
        commuteDate = Date()
        
        commuteComponent = todayCalendar.dateComponents([.year, .month, .weekOfMonth, .day , .weekday, .hour, .minute, .second], from: commuteDate)
        
        if let prevWorkedItem = WorkedListDB.readWorkedItem(id: commuteDate) {
            notWorkedTime = prevWorkedItem.rest
            realWorkedTime = prevWorkedItem.realWorkedTime
            workedTime = prevWorkedItem.workedTime
            WorkedListDB.updateWorkedTime(id: commuteDate, Commute: nil, OffWork: nil, LastAppUse: Date(), Rest: notWorkedTime, RealWorkedTime: realWorkedTime, WorkedTime: workedTime, WeekDay: commuteComponent.weekday!, DayWorkStatus: nil, spareTimeIfRealTimeIsNil: nil, IsWorking: isWorking)
            let commuteTime = prevWorkedItem.commute.split(separator: ":", maxSplits: 2, omittingEmptySubsequences: false)
            commuteComponent = DateComponents(year: commuteComponent.year, month: commuteComponent.month, day: commuteComponent.day! + debugNextDays - 1, hour: Int(commuteTime[0]), minute: Int(commuteTime[1]))
            lblCommuteTime.text = convertSimpleFormatToPMAMTime(commuteComponent)
        }
        notWorkingTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: notWorkTimeSelector, userInfo: nil, repeats: true)
        lblButtonMessage.text = "클릭 시 출근!"
    }
    
    @objc func showDetailWokredListOfWeek() {
        let weekDayNumber = ((todayComponent.weekday ?? 0) + 5) % 7
        for i in 0..<7 {
            // 일주일 Date를 불러오는 API 생성 필요.. 후에 수정해야할 부분
            let myDateComponents = DateComponents(year: todayComponent.year, month: todayComponent.month, day: (todayComponent.day ?? 0) - weekDayNumber + i)
            let myDate = Calendar.current.date(from: myDateComponents)!
            if let workedTime = WorkedListDB.readWorkedItem(id: myDate) {
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
                case 7:     // Late 지각
                    lblWeekDayList[i].textColor = UIColor.systemPink
                default:
                    lblWeekDayList[i].textColor = viewColor
                }
            } else { lblWeekDayList[i].textColor = viewColor }
            
            if todayComponent.day == myDateComponents.day {
                lblWeekDayList[i].layer.cornerRadius = 7
                lblWeekDayList[i].layer.borderWidth = 1.0
                lblWeekDayList[i].layer.borderColor = UIColor.white.cgColor
            }
        }
    }
    
    func updateDayWorkStatus() -> Bool {
        var result: Bool = false
        if realWorkedTime >= dayGoalWorkTime {
            WorkedListDB.updateWorkedTime(id: commuteDate, Commute: nil, OffWork: Date(), LastAppUse: Date(), Rest: notWorkedTime, RealWorkedTime: realWorkedTime, WorkedTime: workedTime, WeekDay: todayComponent.weekday ?? -1, DayWorkStatus: 3 /* 야근 */,spareTimeIfRealTimeIsNil: nil, IsWorking: isWorking)
            result = true
        } else if realWorkedTime >= dayLeastWorkTime {
            WorkedListDB.updateWorkedTime(id: commuteDate, Commute: nil, OffWork: Date(), LastAppUse: Date(), Rest: notWorkedTime, RealWorkedTime: realWorkedTime, WorkedTime: workedTime, WeekDay: todayComponent.weekday ?? -1, DayWorkStatus: 2 /* 정상 출근 완료 */,spareTimeIfRealTimeIsNil: nil, IsWorking: isWorking)
            result = true
        }
        return result
    }
    
    @objc func manageWorkTime() {
        todayDate = Date()
        let todayComponent = todayCalendar.dateComponents([.year, .month, .weekOfMonth, .day , .weekday, .hour, .minute, .second], from: todayDate)
        if todayComponent.hour == 4 {       // TBD : 수정 필요 equal은 좋지 않아 보임
            if isWorking == true {
                isWorking = false
                if updateDayWorkStatus() == false {
                    WorkedListDB.updateWorkedTime(id: commuteDate, Commute: nil, OffWork: Date(), LastAppUse: Date(), Rest: notWorkedTime, RealWorkedTime: realWorkedTime, WorkedTime: workedTime, WeekDay: todayComponent.weekday ?? -1, DayWorkStatus: 6 /* 근태 수정 필요 */,spareTimeIfRealTimeIsNil: nil, IsWorking: isWorking)
                }
            }
        }
        
    }
    @objc func updateNotWorkTime() {
        notWorkedTime += timeInterval
        commuteComponent = todayCalendar.dateComponents([.year, .month, .weekOfMonth, .day , .weekday, .hour, .minute, .second], from: commuteDate)
        WorkedListDB.updateWorkedTime(id: commuteDate, Commute: nil, OffWork: nil, LastAppUse: Date(), Rest: notWorkedTime, RealWorkedTime: nil, WorkedTime: nil, WeekDay: commuteComponent.weekday ?? -1, DayWorkStatus: nil, spareTimeIfRealTimeIsNil: nil, IsWorking: isWorking)
    }
    @objc func updateCurrentTime() {
        todayDate = Date()
        let todayComponent = todayCalendar.dateComponents([.year, .month, .weekOfMonth, .day , .weekday, .hour, .minute, .second], from: todayDate)
        
        lblCurrentTime.text = convertSimpleFormatToPMAMTime(todayComponent)
    }
    
    @objc func updateTime() {
        workedTime += timeInterval
        lblWorkingTime.text = convertNSTimeInterval2String(workedTime, isBigOne: false)
        lblBigWorkingTime.text = convertNSTimeInterval2String(workedTime, isBigOne: true)
        commuteComponent = todayCalendar.dateComponents([.year, .month, .weekOfMonth, .day , .weekday, .hour, .minute, .second], from: commuteDate)
        WorkedListDB.updateWorkedTime(id: commuteDate, Commute: nil, OffWork: Date(), LastAppUse: Date(), Rest: nil, RealWorkedTime: realWorkedTime, WorkedTime: workedTime, WeekDay: commuteComponent.weekday ?? -1, DayWorkStatus: nil, spareTimeIfRealTimeIsNil: nil, IsWorking: isWorking)
        _ = updateDayWorkStatus()
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
        if isWorking == true {
            isWorking = false
            if realWorkedTime >= dayGoalWorkTime {
                WorkedListDB.updateWorkedTime(id: commuteDate, Commute: commuteDate, OffWork: Date(), LastAppUse: Date(), Rest: notWorkedTime, RealWorkedTime: realWorkedTime, WorkedTime: workedTime, WeekDay: todayComponent.weekday ?? -1, DayWorkStatus: 3 /* 야근 */, spareTimeIfRealTimeIsNil: nil, IsWorking: isWorking)
            } else if realWorkedTime >= dayLeastWorkTime {
                WorkedListDB.updateWorkedTime(id: commuteDate, Commute: commuteDate, OffWork: Date(), LastAppUse: Date(), Rest: notWorkedTime, RealWorkedTime: realWorkedTime, WorkedTime: workedTime, WeekDay: todayComponent.weekday ?? -1, DayWorkStatus: 2 /* 정상 출근 완료 */,spareTimeIfRealTimeIsNil: nil, IsWorking: isWorking)
            } else {
                WorkedListDB.updateWorkedTime(id: commuteDate, Commute: commuteDate, OffWork: Date(), LastAppUse: Date(), Rest: notWorkedTime, RealWorkedTime: realWorkedTime, WorkedTime: workedTime, WeekDay: todayComponent.weekday ?? -1, DayWorkStatus: 1 /* 정상 */, spareTimeIfRealTimeIsNil: nil, IsWorking: isWorking)
            }               // TBD : 퇴근을 누른 후에 다음날이 되었는데 전날 시간이 Least에 도달하지 못한 경우에 대한 별도 처리가 필요함
        }
    }
    @IBAction func btnDebugNextDay(_ sender: UIButton) {
        if isWorking == false {
            isWorking = true
            let myDateComponents = DateComponents(year: commuteComponent.year, month: commuteComponent.month, day: commuteComponent.day! + debugNextDays, hour: 8, minute: 30)
            debugNextDate = todayCalendar.date(from: myDateComponents)!
            let debugNotWorked = 1000.0
            debugNextDays += 1
            if let prevWorkedItem = WorkedListDB.readWorkedItem(id: debugNextDate) {
                notWorkedTime = prevWorkedItem.rest
                realWorkedTime = prevWorkedItem.realWorkedTime
                workedTime = prevWorkedItem.workedTime
                WorkedListDB.updateWorkedTime(id: debugNextDate, Commute: nil, OffWork: debugNextDate, LastAppUse: Date(), Rest: debugNotWorked, RealWorkedTime: realWorkedTime, WorkedTime: workedTime, WeekDay: commuteComponent.weekday ?? -1, DayWorkStatus: 1, spareTimeIfRealTimeIsNil: nil, IsWorking: isWorking)
            } else {
                _ = WorkedListDB.insertWorkedTime(id: debugNextDate, Commute: debugNextDate, OffWork: debugNextDate, LastAppUse: Date(), Rest: debugNotWorked, RealWorkedTime: realWorkedTime, WorkedTime: workedTime, WeekDay: commuteComponent.weekday ?? -1, DayWorkStatus: 1, IsWorking: isWorking)
            }
        } else {
            isWorking = false
            let myDateComponents = DateComponents(year: commuteComponent.year, month: commuteComponent.month, day: commuteComponent.day! + debugNextDays - 1, hour: 17, minute: 30)
            let myDate = todayCalendar.date(from: myDateComponents)!
            let debugNotWorked = 24250.0
            WorkedListDB.updateWorkedTime(id: debugNextDate, Commute: debugNextDate, OffWork: myDate, LastAppUse: Date(), Rest: debugNotWorked, RealWorkedTime: realWorkedTime, WorkedTime: workedTime, WeekDay: commuteComponent.weekday ?? -1, DayWorkStatus: 1, spareTimeIfRealTimeIsNil: nil, IsWorking: isWorking)
            
            
        }
    }
    @IBAction func btnPrintFromDB(_ sender: UIButton) {
        let result = WorkedListDB.readWorkedItem(id: todayDate)!
        print("ID \(result.workedDate)" + " Commute " + result.commute + " OffWork "+result.offWork + " Rest \(result.rest)" + " RealWorkedTime \(result.realWorkedTime)" + " WorkedTime \(result.workedTime)" + " WeekDay \(result.weekDay)" + " DayWorkStatus \(result.dayWorkStatus)")
    }
    
    @IBAction func btnStamp(_ sender: UIButton) {
        if isWorking == false {
            isWorking = true
            isCommute = true
            actionWhenIsWorking()
            
        } else {
            isWorking = false
            actionWhenIsNotWorking()
        }
    }
    
    
}

