//
//  DetailViewController.swift
//  WLBapp
//
//  Created by 나윤서 on 2021/02/14.
//

import UIKit

class DetailViewController: UIViewController {
    // Outlet Definition //
    @IBOutlet var lblMonText: UILabel!
    @IBOutlet var lblTueText: UILabel!
    @IBOutlet var lblWedText: UILabel!
    @IBOutlet var lblThrText: UILabel!
    @IBOutlet var lblFriText: UILabel!
    @IBOutlet var lblSatText: UILabel!
    @IBOutlet var lblSunText: UILabel!
    
    @IBOutlet var lblMonCommuteTime: UILabel!
    @IBOutlet var lblTueCommuteTime: UILabel!
    @IBOutlet var lblWedCommuteTime: UILabel!
    @IBOutlet var lblThrCommuteTime: UILabel!
    @IBOutlet var lblFriCommuteTime: UILabel!
    @IBOutlet var lblSatCommuteTime: UILabel!
    @IBOutlet var lblSunCommuteTime: UILabel!
    
    @IBOutlet var lblMonOffWorkTime: UILabel!
    @IBOutlet var lblTueOffWorkTime: UILabel!
    @IBOutlet var lblWedOffWorkTime: UILabel!
    @IBOutlet var lblThrOffWorkTime: UILabel!
    @IBOutlet var lblFriOffWorkTime: UILabel!
    @IBOutlet var lblSatOffWorkTime: UILabel!
    @IBOutlet var lblSunOffWorkTime: UILabel!
    
    @IBOutlet var lblMonRealWorkTime: UILabel!
    @IBOutlet var lblTueRealWorkTime: UILabel!
    @IBOutlet var lblWedRealWorkTime: UILabel!
    @IBOutlet var lblThrRealWorkTime: UILabel!
    @IBOutlet var lblFriRealWorkTime: UILabel!
    @IBOutlet var lblSatRealWorkTime: UILabel!
    @IBOutlet var lblSunRealWorkTime: UILabel!
    
    @IBOutlet var lblTotalWorkTime: UILabel!
    @IBOutlet var lblSpareWorkTime: UILabel!
    
    // Variable Definition
    var weekTextList: [UILabel] = []
    var weekCommuteList: [UILabel] = []
    var weekOffWorkList: [UILabel] = []
    var weekRealWorkList: [UILabel] = []
    var weekDayNumber: Int = 0      // 0 : Mon,  1 : Tue,  2 : Web,  3 : Thr,  4 : Fri,  5 : Sat,  6 : Sun
    let viewcontroller = ViewController()
    var datecomponent = DateComponents()
    let historySelector: Selector = #selector(updateHistory)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // View Configuration
        view.backgroundColor = UIColor.darkGray
        
        // Initialization
        weekTextList = [lblMonText, lblTueText, lblWedText, lblThrText, lblFriText, lblSatText, lblSunText]
        weekCommuteList = [lblMonCommuteTime, lblTueCommuteTime, lblWedCommuteTime, lblThrCommuteTime, lblFriCommuteTime, lblSatCommuteTime, lblSunCommuteTime]
        weekOffWorkList = [lblMonOffWorkTime, lblTueOffWorkTime, lblWedOffWorkTime, lblThrOffWorkTime, lblFriOffWorkTime, lblSatOffWorkTime, lblSunOffWorkTime]
        weekRealWorkList = [lblMonRealWorkTime, lblTueRealWorkTime, lblWedRealWorkTime, lblThrRealWorkTime, lblFriRealWorkTime, lblSatRealWorkTime, lblSunRealWorkTime]
        
        datecomponent = Calendar.current.dateComponents([.year, .month, .weekOfMonth, .day , .weekday, .hour, .minute, .second], from: Date())
        weekDayNumber = ((datecomponent.weekday ?? 0) + 5) % 7
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: historySelector, userInfo: nil, repeats: true)
    }
    
    func showDetailWokredListOfWeek() {
        lblSpareWorkTime.text = "--:--"
        lblTotalWorkTime.text = "--:--"
        var totalWorkedTimeInterval: TimeInterval = 0
        var spareTime: TimeInterval = 0
        for i in 0...weekDayNumber {
            let myDateComponents = DateComponents(year: datecomponent.year, month: datecomponent.month, day: (datecomponent.day ?? 0) - weekDayNumber + i)
            let myDate = Calendar.current.date(from: myDateComponents)!
            if let workedTime = WorkedListDB.readWorkedItem(id: myDate) {
                if workedTime.dayWorkStatus == 4 {
                    weekCommuteList[i].text = ""
                    weekOffWorkList[i].text = "휴가"
                    weekRealWorkList[i].text = ""
                } else if workedTime.dayWorkStatus == 5 {
                    weekCommuteList[i].text = ""
                    weekOffWorkList[i].text = "반차"
                    weekRealWorkList[i].text = ""
                } else {
                    weekCommuteList[i].text = workedTime.commute
                    weekOffWorkList[i].text = workedTime.offWork
                    weekRealWorkList[i].text = String(format: "%02d:%02d", Int(workedTime.realWorkedTime/3600), Int(workedTime.realWorkedTime/60) % 60)
                }
                totalWorkedTimeInterval += workedTime.realWorkedTime
                spareTime = workedTime.spareTimeToWork
                
            } else {
                weekCommuteList[i].text = "--:--"
                weekOffWorkList[i].text = "--:--"
                weekRealWorkList[i].text = "--:--"
            }
            
            
            
//            print("rest = \(workedTime.rest) hour = \((workedTime.rest)/3600) min = \((workedTime.rest)/60)")
        }
        
        for j in weekDayNumber+1..<7 {
            weekCommuteList[j].text = "--:--"
            weekOffWorkList[j].text = "--:--"
            weekRealWorkList[j].text = "--:--"
        }
        
        lblTotalWorkTime.text = String(format: "%02d:%02d", Int(totalWorkedTimeInterval/3600), Int(totalWorkedTimeInterval/60) % 60)
        lblSpareWorkTime.text = String(format: "%02d:%02d", Int(spareTime/3600), Int(spareTime/60) % 60)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditFromMon" {
            let i = 0
            let vc = segue.destination as! EditDetailViewController
            let myDateComponents = DateComponents(year: datecomponent.year, month: datecomponent.month, day: (datecomponent.day ?? 0) - weekDayNumber + i)
            let myDate = Calendar.current.date(from: myDateComponents)!
            
            vc.fromDate = myDate
            vc.fromWhat = "Mon"
            vc.fromWeekDay = i + 2
        } else if segue.identifier == "EditFromTue" {
            let i = 1
            let vc = segue.destination as! EditDetailViewController
            let myDateComponents = DateComponents(year: datecomponent.year, month: datecomponent.month, day: (datecomponent.day ?? 0) - weekDayNumber + i)
            let myDate = Calendar.current.date(from: myDateComponents)!
            
            vc.fromDate = myDate
            vc.fromWhat = "Tue"
            vc.fromWeekDay = i + 2
        } else if segue.identifier == "EditFromWed" {
            let i = 2
            let vc = segue.destination as! EditDetailViewController
            let myDateComponents = DateComponents(year: datecomponent.year, month: datecomponent.month, day: (datecomponent.day ?? 0) - weekDayNumber + i)
            let myDate = Calendar.current.date(from: myDateComponents)!
            
            vc.fromDate = myDate
            vc.fromWhat = "Wed"
            vc.fromWeekDay = i + 2
        } else if segue.identifier == "EditFromThr" {
            let i = 3
            let vc = segue.destination as! EditDetailViewController
            let myDateComponents = DateComponents(year: datecomponent.year, month: datecomponent.month, day: (datecomponent.day ?? 0) - weekDayNumber + i)
            let myDate = Calendar.current.date(from: myDateComponents)!
            
            vc.fromDate = myDate
            vc.fromWhat = "Thr"
            vc.fromWeekDay = i + 2
        } else if segue.identifier == "EditFromFri" {
            let i = 4
            let vc = segue.destination as! EditDetailViewController
            let myDateComponents = DateComponents(year: datecomponent.year, month: datecomponent.month, day: (datecomponent.day ?? 0) - weekDayNumber + i)
            let myDate = Calendar.current.date(from: myDateComponents)!
            
            vc.fromDate = myDate
            vc.fromWhat = "Fri"
            vc.fromWeekDay = i + 2
        } else if segue.identifier == "EditFromSat" {
            let i = 5
            let vc = segue.destination as! EditDetailViewController
            let myDateComponents = DateComponents(year: datecomponent.year, month: datecomponent.month, day: (datecomponent.day ?? 0) - weekDayNumber + i)
            let myDate = Calendar.current.date(from: myDateComponents)!
            
            vc.fromDate = myDate
            vc.fromWhat = "Sat"
            vc.fromWeekDay = i + 2
        } else if segue.identifier == "EditFromSun" {
            let i = 6
            let vc = segue.destination as! EditDetailViewController
            let myDateComponents = DateComponents(year: datecomponent.year, month: datecomponent.month, day: (datecomponent.day ?? 0) - weekDayNumber + i)
            let myDate = Calendar.current.date(from: myDateComponents)!
            
            vc.fromDate = myDate
            vc.fromWhat = "Sun"
            vc.fromWeekDay = (i + 2) % 7
        }
    }
    
    @objc func updateHistory() {
        showDetailWokredListOfWeek()
    }

}
