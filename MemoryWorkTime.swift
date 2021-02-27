//
//  MemoryWorkTime.swift
//  WLBapp
//
//  Created by 나윤서 on 2021/02/11.
//

import Foundation
import SQLite3

var dbFormatter: DateFormatter = DateFormatter()
var dbIdFormatter: DateFormatter = DateFormatter()

var db: OpaquePointer?          // db 를 가르키는 포인터
let path: String = {
      let fm = FileManager.default
      return fm.urls(for:.libraryDirectory, in:.userDomainMask).last!
               .appendingPathComponent("WorkedList.db").path
    }()
let createTableString = """
   CREATE TABLE IF NOT EXISTS WorkedList(
   Id CHAR(255) PRIMARY KEY NOT NULL,
   Commute CHAR(255),
   OffWork CHAR(255),
   Rest Int,
   RealWorkedTime Int,
   WorkedTime Int,
   WeekDay Int,
   DayWorkStatus Int,
   SpareTimeToWork Int);
   """

let idInsertString = "SET IDENTITY_INSERT WorkedList ON;"

class WorkedItem {
    var workedDate: String
    var commute: String
    var offWork: String
    var rest: TimeInterval
    var realWorkedTime: TimeInterval
    var workedTime: TimeInterval
    var weekDay: Int
    var dayWorkStatus: Int
    var spareTimeToWork: TimeInterval
    
    init(_ workedDate: String, commute: String, offWork: String, rest: TimeInterval, realWorkedTime: TimeInterval, workedTime: TimeInterval, weekDay: Int, dayWorkStatus: Int, spareTimeToWork: TimeInterval) {
        self.workedDate = workedDate
        self.commute = commute
        self.offWork = offWork
        self.rest = rest
        self.realWorkedTime = realWorkedTime
        self.workedTime = workedTime
        self.weekDay = weekDay
        self.dayWorkStatus = dayWorkStatus
        self.spareTimeToWork = spareTimeToWork
    }
}

class WorkedListDB: NSObject {
    override init() {
        dbFormatter.dateFormat = "HH:mm"
        dbIdFormatter.dateFormat = "yyyy.MM.dd"
        if sqlite3_open(path, &db) == SQLITE_OK {
            if sqlite3_exec(db,createTableString,nil,nil,nil) == SQLITE_OK {
                return
            }
        }
        // throw error
    }
    deinit {
        sqlite3_close(db)
    }
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

    
    func createTableWorkedList() {
      var createTableStatement: OpaquePointer?
      if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
        if sqlite3_step(createTableStatement) == SQLITE_DONE {
          print("\nWorkedList table created.")
        } else {
          print("\nWorkedList table is not created.")
        }
      } else {
        print("\nCREATE TABLE statement is not prepared.")
      }
      sqlite3_finalize(createTableStatement)
    }
    
    func insertWorkedTime(id: Date, Commute: Date, OffWork: Date, Rest: TimeInterval, RealWorkedTime: TimeInterval, WorkedTime: TimeInterval, WeekDay: Int, DayWorkStatus: Int) -> Int {
        let insertStatementString = "INSERT INTO WorkedList (Id, Commute, OffWork, Rest, RealWorkedTime, WorkedTime, WeekDay, DayWorkStatus, SpareTimeToWork) VALUES (?,?,?,?,?,?,?,?,?);"
        var statement: OpaquePointer?
        
        if sqlite3_prepare(db, insertStatementString, -1, &statement, nil) == SQLITE_OK {       // 쿼리 생성
            sqlite3_bind_text(statement, 1, dbIdFormatter.string(from: id), -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, dbFormatter.string(from: Commute), -1, SQLITE_TRANSIENT)
            //  두번째 매개변수는  (?,?,?,?) 에 대해 각 인덱스의 값을 넣어주는 역할
            sqlite3_bind_text(statement, 3, dbFormatter.string(from: OffWork), -1, SQLITE_TRANSIENT)
            sqlite3_bind_int(statement, 4, Int32(Rest))
            sqlite3_bind_int(statement, 5, Int32(RealWorkedTime))
            sqlite3_bind_int(statement, 6, Int32(WorkedTime))
            sqlite3_bind_int(statement, 7, Int32(WeekDay))
            sqlite3_bind_int(statement, 8, Int32(DayWorkStatus))
            if WeekDay == 2 {
                sqlite3_bind_int(statement, 9, Int32(40 * 3600))
            } else {
                var myDateComponents = Calendar.current.dateComponents([.year, .month, .weekOfMonth, .day , .weekday, .hour, .minute, .second], from: id)
                myDateComponents.day = myDateComponents.day! - 1
                let yesterDate = Calendar.current.date(from: myDateComponents)!
                let yesterDateItem = WorkedListDB.readWorkedItem(id: yesterDate)!
                sqlite3_bind_int(statement, 9, Int32(yesterDateItem.spareTimeToWork))
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
        return Int(sqlite3_last_insert_rowid(db))
    }
    
    func updateWorkedTime(id: Date, Commute: Date?, OffWork: Date?, Rest: TimeInterval, RealWorkedTime: TimeInterval, WorkedTime: TimeInterval, WeekDay: Int, DayWorkStatus: Int) {
        let spareTime: Int
        if WeekDay == 2 {
            spareTime = 40 * 3600 - Int(WorkedTime)
        } else {
            var myDateComponents = Calendar.current.dateComponents([.year, .month, .weekOfMonth, .day , .weekday, .hour, .minute, .second], from: id)
            myDateComponents.day = myDateComponents.day! - 1
            let yesterDate = Calendar.current.date(from: myDateComponents)!
            let yesterDateItem = WorkedListDB.readWorkedItem(id: yesterDate)!
            spareTime = Int(yesterDateItem.spareTimeToWork - WorkedTime)
        }
        var updateStatementString = "UPDATE WorkedList SET"
        if Commute != nil {
            updateStatementString += " Commute = '\(dbFormatter.string(from: Commute!))',"
        }
        if OffWork != nil {
            updateStatementString += " OffWork = '\(dbFormatter.string(from: OffWork!))',"
        }
        updateStatementString += " Rest = \(Rest), RealWorkedTime = \(RealWorkedTime), WorkedTime = \(WorkedTime), WeekDay = \(WeekDay), DayWorkStatus = \(DayWorkStatus), SpareTimeToWork = \(spareTime) WHERE Id = '\(dbIdFormatter.string(from: id))';"
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare(db, updateStatementString, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
//                print("DB Update Row Success\n")
            } else {
                print("DB Update Row Failed\n")
            }
        } else {
            print("Update Statement is not prepared\n")
        }
        
        sqlite3_finalize(statement)
    }
    
    static func readWorkedItem(id: Date) -> WorkedItem? {
        let readWorkedItemStatementString = "SELECT * FROM WorkedList WHERE Id = '\(dbIdFormatter.string(from: id))';"
        var item: WorkedItem?
        var statement: OpaquePointer?
        if sqlite3_prepare(db, readWorkedItemStatementString, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                guard let idWorkedDate = sqlite3_column_text(statement, 0) else {
                    return nil
                }
                guard let commute = sqlite3_column_text(statement, 1) else {
                    return nil
                }
                guard let offWork = sqlite3_column_text(statement, 2) else {
                    return nil
                }
                let rest = sqlite3_column_int(statement, 3)
                let realWorkedTime = sqlite3_column_int(statement, 4)
                let workedTime = sqlite3_column_int(statement, 5)
                let weekDay = sqlite3_column_int(statement, 6)
                let dayWorkStatus = sqlite3_column_int(statement, 7)
                let spareTimeToWork = sqlite3_column_int(statement, 8)
                
                let workedItem = WorkedItem(String(cString: idWorkedDate), commute: String(cString: commute), offWork: String(cString: offWork), rest: TimeInterval(rest), realWorkedTime: TimeInterval(realWorkedTime), workedTime: TimeInterval(workedTime), weekDay: Int(weekDay), dayWorkStatus: Int(dayWorkStatus), spareTimeToWork: TimeInterval(spareTimeToWork))
                item = workedItem
            }
        } else {
            print("Query is not prepared for ReadWorkedItem\n")
        }
        
        sqlite3_finalize(statement)
        return item
    }
    
    func readAllWorkedTime() -> [WorkedItem] {
        let readAllStatementString = "SELECT * FROM WorkedList"
        var items: [WorkedItem] = []
        var statement: OpaquePointer?
        
        if sqlite3_prepare(db, readAllStatementString, -1, &statement, nil) == SQLITE_OK {
            while(sqlite3_step(statement) == SQLITE_ROW) {
                guard let idWorkedDate = sqlite3_column_text(statement, 0) else {
                    continue
                }
                guard let commute = sqlite3_column_text(statement, 1) else {
                    continue
                }
                guard let offWork = sqlite3_column_text(statement, 2) else {
                    continue
                }
                let rest = sqlite3_column_int(statement, 3)
                let realWorkedTime = sqlite3_column_int(statement, 4)
                let workedTime = sqlite3_column_int(statement, 5)
                let weekDay = sqlite3_column_int(statement, 6)
                let dayWorkStatus = sqlite3_column_int(statement, 7)
                let spareTimeToWork = sqlite3_column_int(statement, 8)
                
                let workedItem = WorkedItem(String(cString: idWorkedDate), commute: String(cString: commute), offWork: String(cString: offWork), rest: TimeInterval(rest), realWorkedTime: TimeInterval(realWorkedTime), workedTime: TimeInterval(workedTime), weekDay: Int(weekDay), dayWorkStatus: Int(dayWorkStatus), spareTimeToWork: TimeInterval(spareTimeToWork))
                items.append(workedItem)
            }
        } else {
            print("Query is not prepared for ReadAllWorkedTime\n")
        }
        
        sqlite3_finalize(statement)
        return items
    }
    
    func deleteAllWorkedList() {
        let deleteAllStatementString = "DELETE FROM WorkedList"
        var statement: OpaquePointer?
        
        if sqlite3_prepare(db, deleteAllStatementString, -1, &statement, nil) == SQLITE_OK {
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
    
    func setIdInsertWorkedList() {
        var statement: OpaquePointer?
        
        if sqlite3_prepare(db, idInsertString, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
            } else {
                print("Id Insert Failed\n")
            }
        } else {
            print("Query is not prepared for Id Insert\n")
        }
        
        sqlite3_finalize(statement)
    }

    func deleteWorkedList(id: Date) {
        let deleteStatementString = "DELETE FROM WorkedList WHERE Id=\(dbIdFormatter.string(from: id));"
        var statement: OpaquePointer?
        
        if sqlite3_prepare(db, deleteStatementString, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
//                print("Delete Row Success\n")
            } else {
                print("Delete Row Failed'n")
            }
        } else {
            print("Delete Statement in not prepared\n")
        }
        sqlite3_finalize(statement)
    }
    
    func deleteTableWorkedList() {
        let deleteStatementString = "DROP TABLE WorkedList;"
        var statement: OpaquePointer?
        
        if sqlite3_prepare(db, deleteStatementString, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
//                print("Delete Row Success\n")
            } else {
                print("Delete Table Failed'n")
            }
        } else {
            print("Delete Table Statement in not prepared\n")
        }
        sqlite3_finalize(statement)
    }
    

}
