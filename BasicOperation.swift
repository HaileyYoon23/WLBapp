//
//  BasicOperation.swift
//  WLBapp
//
//  Created by 나윤서 on 2021/02/28.
//

import Foundation
import UIKit

enum WrongInput {
    case notnumberinput
    case wrongworktimeinput
}

class BasicOperation {
    static func AlertToManage(errorCode: String) -> UIAlertController {
        let alert = UIAlertController(title: "경고", message: "에러코드 #\(errorCode)", preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "관리자 문의 필요", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(action)
        
        return alert
    }
    static func AlertWrongInput(WrongInputEnum: WrongInput) -> UIAlertController {
        var errorMessage: String
        
        switch WrongInputEnum {
        case .notnumberinput:
            errorMessage = "숫자만 입력바랍니다."
        case .wrongworktimeinput:
            errorMessage = "올바른 출근시간/퇴근시간으로 입력바랍니다."
        }
        
        let alert = UIAlertController(title: "경고", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "네", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(action)
        
        
        return alert
    }
}
