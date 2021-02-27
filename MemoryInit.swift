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
   DayLeastStartMin Int);
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
    
    init(_ weekLeastHour: Int, weekLeastMin: Int, dayGoalHour: Int, dayGoalMin: Int, dayLeastHour: Int, dayLeastMin: Int, dayLeastStartHour: Int, dayLeastStartMin: Int) {
        self.weekLeastHour = weekLeastHour
        self.weekLeastMin = weekLeastMin
        self.dayGoalHour = dayGoalHour
        self.dayGoalMin = dayGoalMin
        self.dayLeastHour = dayLeastHour
        self.dayLeastMin = dayLeastMin
        self.dayLeastStartHour = dayLeastStartHour
        self.dayLeastStartMin = dayLeastStartMin
    }
}

class InitDB: NSObject {
    override init() {
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
    
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
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
    
    func insertInfo(weekLeastHour: Int, weekLeastMin: Int, dayGoalHour: Int, dayGoalMin: Int, dayLeastHour: Int, dayLeastMin: Int, dayLeastStartHour: Int, dayLeastStartMin: Int) -> Int {
        let insertStatementString = "INSERT INTO InitTable (Id, WeekLeastHour, WeekLeastMin, DayGoalHour, DayGoalMin, DayLeastHour, DayLeastMin, DayLeastStartHour, DayLeastStartMin) VALUES (?,?,?,?,?,?,?,?,?);"
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
            
            if sqlite3_step(statement) == SQLITE_DONE {         // 쿼리 실행
//                print("DB Insert Row Success\n")
            } else {
                print("DB Insert Row Failed\n")
            }
        } else {
            print("Insert Statement is not prepared\n")
        }
        
        sqlite3_finalize(statement)         // 쿼리 반환
        return Int(sqlite3_last_insert_rowid(db))
    }
    
    func updateInfo(weekLeastHour: Int, weekLeastMin: Int, dayGoalHour: Int, dayGoalMin: Int, dayLeastHour: Int, dayLeastMin: Int, dayLeastStartHour: Int, dayLeastStartMin: Int) {
        let updateStatementString = "UPDATE InitTable SET WeekLeastHour = '\(weekLeastHour)', WeekLeastMin = '\(weekLeastMin)', DayGoalHour = '\(dayGoalHour)', DayGoalMin = '\(dayGoalMin)', DayLeastHour = \(dayLeastHour), DayLeastMin = \(dayLeastMin), DayLeastStartHour = \(dayLeastStartHour), DayLeastStartMin = \(dayLeastStartMin) WHERE Id = \(0);"
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
    
    func readInfo() -> Info? {
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
                
                let info: Info = Info(Int(weekLeastHour), weekLeastMin: Int(weekLeastMin), dayGoalHour: Int(dayGoalHour), dayGoalMin: Int(dayGoalMin), dayLeastHour: Int(dayLeastHour), dayLeastMin: Int(dayLeastMin), dayLeastStartHour: Int(dayLeastStartHour), dayLeastStartMin: Int(dayLeastStartMin))
                item = info
            }
        } else {
            print("Query is not prepared for ReadInfo\n")
        }
        
        sqlite3_finalize(statement)
        return item
    }
    
    func deleteAllWorkedList() {
        let deleteAllStatementString = "DELETE FROM InitTable"
        var statement: OpaquePointer?
        
        if sqlite3_prepare(db_init, deleteAllStatementString, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
//                print("DB Delete All Success\n")
            } else {
                print("DB Delete All Failed\n")
            }
        } else {
            print("Query is not prepared for DeleteAll\n")
        }
        
        sqlite3_finalize(statement)
    }

    func deleteTableWorkedList() {
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
