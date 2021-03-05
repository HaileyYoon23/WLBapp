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
    
    @IBOutlet var lblMonNotWorkTime: UILabel!
    @IBOutlet var lblTueNotWorkTime: UILabel!
    @IBOutlet var lblWedNotWorkTime: UILabel!
    @IBOutlet var lblThrNotWorkTime: UILabel!
    @IBOutlet var lblFriNotWorkTime: UILabel!
    @IBOutlet var lblSatNotWorkTime: UILabel!
    @IBOutlet var lblSunNotWorkTime: UILabel!
    
    // Variable Definition
    var weekTextList: [UILabel] = []
    var weekCommuteList: [UILabel] = []
    var weekOffWorkList: [UILabel] = []
    var weekNotWorkList: [UILabel] = []
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
        weekNotWorkList = [lblMonNotWorkTime, lblTueNotWorkTime, lblWedNotWorkTime, lblThrNotWorkTime, lblFriNotWorkTime, lblSatNotWorkTime, lblSunNotWorkTime]
        
        datecomponent = Calendar.current.dateComponents([.year, .month, .weekOfMonth, .day , .weekday, .hour, .minute, .second], from: Date())
        weekDayNumber = ((datecomponent.weekday ?? 0) + 5) % 7
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: historySelector, userInfo: nil, repeats: true)
    }
    
    func showDetailWokredListOfWeek() {
        for i in 0...weekDayNumber {
            let myDateComponents = DateComponents(year: datecomponent.year, month: datecomponent.month, day: (datecomponent.day ?? 0) - weekDayNumber + i)
            let myDate = Calendar.current.date(from: myDateComponents)!
            if let workedTime = WorkedListDB.readWorkedItem(id: myDate) {
                if workedTime.dayWorkStatus == 4 {
                    weekCommuteList[i].text = ""
                    weekOffWorkList[i].text = "휴가"
                    weekNotWorkList[i].text = ""
                } else if workedTime.dayWorkStatus == 5 {
                    weekCommuteList[i].text = ""
                    weekOffWorkList[i].text = "반차"
                    weekNotWorkList[i].text = ""
                } else {
                    weekCommuteList[i].text = workedTime.commute
                    weekOffWorkList[i].text = workedTime.offWork
                    weekNotWorkList[i].text = String(format: "%02d:%02d:%02d", Int(workedTime.rest/3600), Int(workedTime.rest/60) % 60, Int(workedTime.rest) % 60)
                }
            } else {
                weekCommuteList[i].text = "--:--"
                weekOffWorkList[i].text = "--:--"
                weekNotWorkList[i].text = "--:--"
            }
            
            
            
//            print("rest = \(workedTime.rest) hour = \((workedTime.rest)/3600) min = \((workedTime.rest)/60)")
        }
        for j in weekDayNumber+1..<7 {
            weekCommuteList[j].text = "--:--"
            weekOffWorkList[j].text = "--:--"
            weekNotWorkList[j].text = "--:--"
        }
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
