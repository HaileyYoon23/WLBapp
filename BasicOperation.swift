//
//  BasicOperation.swift
//  WLBapp
//
//  Created by 나윤서 on 2021/02/28.
//

import Foundation
import UIKit

class BasicOperation {
    static func AlertToManage(errorCode: String) -> UIAlertController {
        let alert = UIAlertController(title: "경고", message: "에러코드 #\(errorCode)", preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "관리자 문의 필요", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(action)
        
        return alert
    }
}
