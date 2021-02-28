//
//  MemoryWeekInfo.swift
//  WLBapp
//
//  Created by 나윤서 on 2021/02/28.
//

import Foundation
import SQLite3

var db_week: OpaquePointer?          // db 를 가르키는 포인터
let path_week: String = {
      let fm = FileManager.default
      return fm.urls(for:.libraryDirectory, in:.userDomainMask).last!
               .appendingPathComponent("WeekTable.db").path
    }()

let createWeekTableString = """
   CREATE TABLE IF NOT EXISTS WeekTable(
   Id CHAR(255) PRIMARY KEY NOT NULL,
   NonWorkHour Int,
   NonWorkMin Int,
   NumOfNonWorkFullDay Int,
   NumOfNonWorkHalfDay Int);
   """

class WeekInfo {
    var id: String
    var nonWorkHour: Int
    var nonWorkMin: Int
    var numOfNonWorkFullDay: Int
    var numOfNonWorkHalfDay: Int
    
    init(_ id: String, nonworkhour: Int, nonworkmin: Int, numofnonworkfullday: Int, numofnonworkhalfday: Int) {
        self.id = id
        self.nonWorkHour = nonworkhour
        self.nonWorkMin = nonworkmin
        self.numOfNonWorkFullDay = numofnonworkfullday
        self.numOfNonWorkHalfDay = numofnonworkhalfday
    }
}

class WeekDB: NSObject {
    override init() {
        if sqlite3_open(path_week, &db_week) == SQLITE_OK {
            if sqlite3_exec(db_week,createWeekTableString,nil,nil,nil) == SQLITE_OK {
                return
            }
        }
        // throw error
    }
    deinit {
        sqlite3_close(db_week)
    }
    
    static let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    func createWeekDB() {
      var createTableStatement: OpaquePointer?
      if sqlite3_prepare_v2(db_week, createWeekTableString, -1, &createTableStatement, nil) == SQLITE_OK {
        if sqlite3_step(createTableStatement) == SQLITE_DONE {
          print("\nWeekTable created.")
        } else {
          print("\nWeekTable is not created.")
        }
      } else {
        print("\nCREATE WEEK TABLE statement is not prepared.")
      }
      sqlite3_finalize(createTableStatement)
    }
    
    static func insertWeekInfo(id: Date, nonworkhour: Int, nonworkmin: Int, numofnonworkfullday: Int, numofnonworkhalfday: Int) -> Int {
        let insertStatementString = "INSERT INTO WeekTable (Id, NonWorkHour, NonWorkMin, NumOfNonWorkFullDay, NumOfNonWorkHalfDay) VALUES (?,?,?,?,?);"
        var statement: OpaquePointer?
        let idDateComponent = Calendar.current.dateComponents([.year, .month, .weekOfMonth, .day , .weekday, .hour, .minute, .second], from: id)
        var idOfDB: String = ""
        if let year = idDateComponent.year {
            if let month = idDateComponent.month {
                if let weekOfMonth = idDateComponent.weekOfMonth {
                    idOfDB = String(format: "%04d.%02d.week%d", year, month, weekOfMonth)
                } else { print("Insert WeekInfo, weekOfMonth is nil\n") }
            } else { print("Insert WeekInfo, month is nil\n") }
        } else { print("Insert WeekInfo, year is nil\n") }
        

        if sqlite3_prepare(db_week, insertStatementString, -1, &statement, nil) == SQLITE_OK {       // 쿼리 생성
            sqlite3_bind_text(statement, 1, idOfDB, -1, SQLITE_TRANSIENT)                 // Id
            sqlite3_bind_int(statement, 2, Int32(nonworkhour))
            sqlite3_bind_int(statement, 3, Int32(nonworkmin))
            //  두번째 매개변수는  (?,?,?,?) 에 대해 각 인덱스의 값을 넣어주는 역할
            sqlite3_bind_int(statement, 4, Int32(numofnonworkfullday))
            sqlite3_bind_int(statement, 5, Int32(numofnonworkhalfday))

            if sqlite3_step(statement) == SQLITE_DONE {         // 쿼리 실행
//                print("DB Insert Row Success\n")
            } else {
                print("DB Insert WeekInfo Row Failed\n")
            }
        } else {
            print("Insert WeekInfo Statement is not prepared\n")
        }

        sqlite3_finalize(statement)         // 쿼리 반환
        return Int(sqlite3_last_insert_rowid(db_week))
    }

    static func updateWeekInfo(id: Date, nonworkhour: Int?, nonworkmin: Int?, numofnonworkfullday: Int?, numofnonworkhalfday: Int?) {
        var updateStatementString = "UPDATE WeekTable SET "
        let idDateComponent = Calendar.current.dateComponents([.year, .month, .weekOfMonth, .day , .weekday, .hour, .minute, .second], from: id)
        var idOfDB: String = ""
        if let year = idDateComponent.year {
            if let month = idDateComponent.month {
                if let weekOfMonth = idDateComponent.weekOfMonth {
                    idOfDB = String(format: "%04d.%02d.week%d", year, month, weekOfMonth)
                } else { print("Insert WeekInfo, weekOfMonth is nil\n") }
            } else { print("Insert WeekInfo, month is nil\n") }
        } else { print("Insert WeekInfo, year is nil\n") }
        var prevStatementExist = false
        if let nWH = nonworkhour {
            updateStatementString += "NonWorkHour = \(nWH)"
            prevStatementExist = true
        }
        if let nWH = nonworkmin {
            if prevStatementExist {
                updateStatementString += ", "
            }
            updateStatementString += "NonWorkMin = \(nWH)"
            prevStatementExist = true
        }
        if let nONWFD = numofnonworkfullday {
            if prevStatementExist {
                updateStatementString += ", "
            }
            updateStatementString += "NumOfNonWorkFullDay = \(nONWFD)"
            prevStatementExist = true
        }
        if let nONWHD = numofnonworkhalfday {
            if prevStatementExist {
                updateStatementString += ", "
            }
            updateStatementString += "NumOfNonWorkHalfDay = \(nONWHD)"
            prevStatementExist = true
        }
        
        updateStatementString += " WHERE Id = '\(idOfDB)';"
        var statement: OpaquePointer?

        if sqlite3_prepare(db_week, updateStatementString, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
//                print("DB Update Row Success\n")
            } else {
                print("WeekTable Update Row Failed\n")
            }
        } else {
            print("Update WeekInfo Statement is not prepared\n")
        }

        sqlite3_finalize(statement)
    }

    static func readWeekInfo(_ id: Date) -> WeekInfo? {
        var statement: OpaquePointer?
        var item: WeekInfo? = nil
        let idDateComponent = Calendar.current.dateComponents([.year, .month, .weekOfMonth, .day , .weekday, .hour, .minute, .second], from: id)
        var idOfDB: String = ""
        if let year = idDateComponent.year {
            if let month = idDateComponent.month {
                if let weekOfMonth = idDateComponent.weekOfMonth {
                    idOfDB = String(format: "%04d.%02d.week%d", year, month, weekOfMonth)
                } else { print("Insert WeekInfo, weekOfMonth is nil\n") }
            } else { print("Insert WeekInfo, month is nil\n") }
        } else { print("Insert WeekInfo, year is nil\n") }
        
        let readWorkedItemStatementString = "SELECT * FROM WeekTable WHERE Id = '\(idOfDB)';"
        
        if sqlite3_prepare(db_week, readWorkedItemStatementString, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                let nonWorkHour = sqlite3_column_int(statement, 1)
                let nonWorkMin = sqlite3_column_int(statement, 2)
                let numOfNonWorkFullDay = sqlite3_column_int(statement, 3)
                let numOfNonWorkHalfDay = sqlite3_column_int(statement, 4)

                let weekInfo: WeekInfo = WeekInfo(idOfDB, nonworkhour: Int(nonWorkHour), nonworkmin: Int(nonWorkMin), numofnonworkfullday: Int(numOfNonWorkFullDay), numofnonworkhalfday: Int(numOfNonWorkHalfDay))
                item = weekInfo
            }
        } else {
            print("Query is not prepared for ReadWeekInfo\n")
        }

        sqlite3_finalize(statement)
        return item
    }

    static func deleteAllWeekInfo() {
        let deleteAllStatementString = "DELETE FROM WeekTable"
        var statement: OpaquePointer?

        if sqlite3_prepare(db_week, deleteAllStatementString, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
//                print("DB Delete All Success\n")
            } else {
                print("DB WeekTable Delete All Failed\n")
            }
        } else {
            print("Query is not prepared for DeleteAll WeekInfo\n")
        }

        sqlite3_finalize(statement)
    }

    static func deleteWeekTable() {
        let deleteStatementString = "DROP TABLE WeekTable;"
        var statement: OpaquePointer?

        if sqlite3_prepare(db_week, deleteStatementString, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
//                print("Delete Row Success\n")
            } else {
                print("Delete WeekTable Failed'n")
            }
        } else {
            print("Delete WeekTable Statement in not prepared\n")
        }
        sqlite3_finalize(statement)
    }
    

}
