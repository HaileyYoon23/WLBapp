//
//  EditDetailViewController.swift
//  WLBapp
//
//  Created by 나윤서 on 2021/02/27.
//

import UIKit

class EditDetailViewController: UIViewController {

    @IBOutlet var lblPrinted: UILabel!
    
    var fromWhat: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
