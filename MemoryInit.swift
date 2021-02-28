//
//  MemoryWorkTime.swift
//  WLBapp
//
//  Created by 나윤서 on 2021/02/11.
//

import Foundation
import SQLite3

var db_init: OpaquePointer?          // db 를 가르키는 포인터
let path_init: String = {
      let fm = FileManager.default
      return fm.urls(for:.libraryDirectory, in:.userDomainMask).last!
               .appendingPathComponent("InitTable.db").path
    }()
var dbDateFormatter: DateFormatter = DateFormatter()

let createInitTableString = """
   CREATE TABLE IF NOT EXISTS InitTable(
   Id Int PRIMARY KEY NOT NULL,
   WeekLeastHour Int,
   WeekLeastMin Int,
   DayGoalHour Int,
   DayGoalMin Int,
   DayLeastHour Int,
   DayLeastMin Int,
   DayLeastStartHour Int,
   DayLeastStartMin Int,
   LastUpdatedDate CHAR(255));
   """

class Info {
    var weekLeastHour: Int
    var weekLeastMin: Int
    var dayGoalHour: Int
    var dayGoalMin: Int
    var dayLeastHour: Int
    var dayLeastMin: Int
    var dayLeastStartHour: Int
    var dayLeastStartMin: Int
    var lastUpdatedDate: String?
    
    init(_ weekLeastHour: Int, weekLeastMin: Int, dayGoalHour: Int, dayGoalMin: Int, dayLeastHour: Int, dayLeastMin: Int, dayLeastStartHour: Int, dayLeastStartMin: Int, lastUpdatedDate: String?) {
        self.weekLeastHour = weekLeastHour
        self.weekLeastMin = weekLeastMin
        self.dayGoalHour = dayGoalHour
        self.dayGoalMin = dayGoalMin
        self.dayLeastHour = dayLeastHour
        self.dayLeastMin = dayLeastMin
        self.dayLeastStartHour = dayLeastStartHour
        self.dayLeastStartMin = dayLeastStartMin
        self.lastUpdatedDate = lastUpdatedDate
    }
}

class InitDB: NSObject {
    override init() {
        dbDateFormatter.dateFormat = "yyyy.MM.dd"
        if sqlite3_open(path_init, &db_init) == SQLITE_OK {
            if sqlite3_exec(db_init,createInitTableString,nil,nil,nil) == SQLITE_OK {
                return
            }
        }
        // throw error
    }
    deinit {
        sqlite3_close(db_init)
    }
    
    static let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    func createInfoDB() {
      var createTableStatement: OpaquePointer?
      if sqlite3_prepare_v2(db_init, createInitTableString, -1, &createTableStatement, nil) == SQLITE_OK {
        if sqlite3_step(createTableStatement) == SQLITE_DONE {
          print("\nInitTable created.")
        } else {
          print("\nInitTable is not created.")
        }
      } else {
        print("\nCREATE TABLE statement is not prepared.")
      }
      sqlite3_finalize(createTableStatement)
    }
    
    static func insertInfo(weekLeastHour: Int, weekLeastMin: Int, dayGoalHour: Int, dayGoalMin: Int, dayLeastHour: Int, dayLeastMin: Int, dayLeastStartHour: Int, dayLeastStartMin: Int, lastUpdatedDate: Date?) -> Int {
        let insertStatementString = "INSERT INTO InitTable (Id, WeekLeastHour, WeekLeastMin, DayGoalHour, DayGoalMin, DayLeastHour, DayLeastMin, DayLeastStartHour, DayLeastStartMin, LastUpdatedDate) VALUES (?,?,?,?,?,?,?,?,?,?);"
        var statement: OpaquePointer?
        
        if sqlite3_prepare(db_init, insertStatementString, -1, &statement, nil) == SQLITE_OK {       // 쿼리 생성
            sqlite3_bind_int(statement, 1, Int32(0))                 // Id
            sqlite3_bind_int(statement, 2, Int32(weekLeastHour))
            sqlite3_bind_int(statement, 3, Int32(weekLeastMin))
            //  두번째 매개변수는  (?,?,?,?) 에 대해 각 인덱스의 값을 넣어주는 역할
            sqlite3_bind_int(statement, 4, Int32(dayGoalHour))
            sqlite3_bind_int(statement, 5, Int32(dayGoalMin))
            sqlite3_bind_int(statement, 6, Int32(dayLeastHour))
            sqlite3_bind_int(statement, 7, Int32(dayLeastMin))
            sqlite3_bind_int(statement, 8, Int32(dayLeastStartHour))
            sqlite3_bind_int(statement, 9, Int32(dayLeastStartMin))
            if let lastUD = lastUpdatedDate {
                sqlite3_bind_text(statement, 10, dbFormatter.string(from: lastUD), -1, SQLITE_TRANSIENT)
            } else {
                sqlite3_bind_text(statement, 10, "none", -1, SQLITE_TRANSIENT)
            }
            
            if sqlite3_step(statement) == SQLITE_DONE {         // 쿼리 실행
//                print("DB Insert Row Success\n")
            } else {
                print("DB Insert Row Failed\n")
            }
        } else {
            print("Insert Statement is not prepared\n")
        }
        
        sqlite3_finalize(statement)         // 쿼리 반환
        return Int(sqlite3_last_insert_rowid(db_init))
    }
    
    static func updateInfo(weekLeastHour: Int?, weekLeastMin: Int?, dayGoalHour: Int?, dayGoalMin: Int?, dayLeastHour: Int?, dayLeastMin: Int?, dayLeastStartHour: Int?, dayLeastStartMin: Int?, lastUpdatedDate: Date?) {
        var updateStatementString = "UPDATE InitTable SET "
        var prevStatementExist = false
        if let wLH = weekLeastHour {
            updateStatementString += "WeekLeastHour = \(wLH)"
            prevStatementExist = true
        }
        if let wLM = weekLeastMin {
            if prevStatementExist {
                updateStatementString += ", "
            }
            updateStatementString += "WeekLeastMin = \(wLM)"
            prevStatementExist = true
        }
        if let dGH = dayGoalHour {
            if prevStatementExist {
                updateStatementString += ", "
            }
            updateStatementString += "DayGoalHour = \(dGH)"
            prevStatementExist = true
        }
        if let dGM = dayGoalMin {
            if prevStatementExist {
                updateStatementString += ", "
            }
            updateStatementString += "DayGoalMin = \(dGM)"
            prevStatementExist = true
        }
        if let dLH = dayLeastHour {
            if prevStatementExist {
                updateStatementString += ", "
            }
            updateStatementString += "DayLeastHour = \(dLH)"
            prevStatementExist = true
        }
        if let dLM = dayLeastMin {
            if prevStatementExist {
                updateStatementString += ", "
            }
            updateStatementString += "DayLeastHour = \(dLM)"
            prevStatementExist = true
        }
        if let dLSH = dayLeastStartHour {
            if prevStatementExist {
                updateStatementString += ", "
            }
            updateStatementString += "DayLeastStartHour = \(dLSH)"
            prevStatementExist = true
        }
        if let dLSM = dayLeastStartMin {
            if prevStatementExist {
                updateStatementString += ", "
            }
            updateStatementString += "DayLeastStartMin = \(dLSM)"
            prevStatementExist = true
        }
        if let lastUD = lastUpdatedDate {
            if prevStatementExist {
                updateStatementString += ", "
            }
            updateStatementString += "LastUpdatedDate = '\(dbDateFormatter.string(from: lastUD))'"
        }
        updateStatementString += " WHERE Id = \(0);"
        var statement: OpaquePointer?
        
        if sqlite3_prepare(db_init, updateStatementString, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
//                print("DB Update Row Success\n")
            } else {
                print("InitTable Update Row Failed\n")
            }
        } else {
            print("Update Statement is not prepared\n")
        }
        
        sqlite3_finalize(statement)
    }
    
    static func readInfo() -> Info? {
        let readWorkedItemStatementString = "SELECT * FROM InitTable WHERE Id = \(0);"
        var statement: OpaquePointer?
        var item: Info? = nil
        if sqlite3_prepare(db_init, readWorkedItemStatementString, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                let weekLeastHour = sqlite3_column_int(statement, 1)
                let weekLeastMin = sqlite3_column_int(statement, 2)
                let dayGoalHour = sqlite3_column_int(statement, 3)
                let dayGoalMin = sqlite3_column_int(statement, 4)
                let dayLeastHour = sqlite3_column_int(statement, 5)
                let dayLeastMin = sqlite3_column_int(statement, 6)
                let dayLeastStartHour = sqlite3_column_int(statement, 7)
                let dayLeastStartMin = sqlite3_column_int(statement, 8)
                guard let lastUpdatedDate = sqlite3_column_text(statement, 9) else {
                    return nil
                }
                
                let info: Info = Info(Int(weekLeastHour), weekLeastMin: Int(weekLeastMin), dayGoalHour: Int(dayGoalHour), dayGoalMin: Int(dayGoalMin), dayLeastHour: Int(dayLeastHour), dayLeastMin: Int(dayLeastMin), dayLeastStartHour: Int(dayLeastStartHour), dayLeastStartMin: Int(dayLeastStartMin), lastUpdatedDate: String(cString: lastUpdatedDate))
                item = info
            }
        } else {
            print("Query is not prepared for ReadInfo\n")
        }
        
        sqlite3_finalize(statement)
        return item
    }
    
    static func deleteInfoAll() {
        let deleteAllStatementString = "DELETE FROM InitTable"
        var statement: OpaquePointer?
        
        if sqlite3_prepare(db_init, deleteAllStatementString, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
//                print("DB Delete All Success\n")
            } else {
                print("DB DeleteInfoAll Failed\n")
            }
        } else {
            print("Query is not prepared for DeleteInfoAll\n")
        }
        
        sqlite3_finalize(statement)
    }

    static func deleteWeekTable() {
        let deleteStatementString = "DROP TABLE InitTable;"
        var statement: OpaquePointer?
        
        if sqlite3_prepare(db_init, deleteStatementString, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
//                print("Delete Row Success\n")
            } else {
                print("Delete InitTable Failed'n")
            }
        } else {
            print("Delete InitTable Statement in not prepared\n")
        }
        sqlite3_finalize(statement)
    }
    

}
