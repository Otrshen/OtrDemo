//
//  ViewController.swift
//  FMDBSQLCipherDemo
//
//  Created by 申铭 on 2020/2/20.
//  Copyright © 2020 Otrshen. All rights reserved.
//

import UIKit

/// 数据库密钥
let kDBKey = "123123"

class ViewController: UIViewController {
    
    private var databaseQueue: FMDatabaseQueue?
    private var databaseQueue2: FMDatabaseQueue?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let database = FMDatabase(path: getOriginalDBPath())
//        database.open()
//        database.setKey(kDBKey)
        
        databaseQueue = FMDatabaseQueue(path: getOriginalDBPath())
        guard let dbQ = databaseQueue else {
            print("数据库打开失败")
            return
        }
        
        // 如果databaseQueue不销毁则设置一次key即可
        dbQ.inDatabase({ (db) in
            db.setKey(kDBKey)
        })
    }
    
    @IBAction func createTable(_ sender: Any) {
        let sql = "create table if not exists t_test(id integer, name text)"
        if execuSql(sql: sql) {
            print("t_test创建成功")
        }
    }
    
    @IBAction func insertData(_ sender: Any) {
        let insertSql = "insert into t_test(id,name) values(1,'otrshen')"
        if execuSql(sql: insertSql) {
            print("数据插入成功")
        }
    }
    
    @IBAction func queryData(_ sender: Any) {
        guard let dbQ = databaseQueue else {
            print("databaseQueue_数据库打开失败")
            return
        }
        
        guard let databaseQueue2 = FMDatabaseQueue(path: getOriginalDBPath()) else {
           print("databaseQueue2_数据库打开失败")
           return
        }
        
        dbQ.inDatabase { (db) in
            databaseQueue2.inDatabase { (db) in
                
                db.setKey(kDBKey) // 注释下这里试试
                
                do {
                    let result = try db.executeQuery("select * from t_test", values: nil)
                    while result.next() {
                        let id = result.int(forColumn: "id")
                        let name = result.string(forColumn: "name")
                        print("databaseQueue2_id: \(id)")
                        print("databaseQueue2_name: \(name ?? "nnnnn")")
                    }
                    result.close()
                } catch {
                    print("databaseQueue2_catch_error: \(error)")
                }
            }
            
            do {
                let result = try db.executeQuery("select * from t_test", values: nil)
                while result.next() {
                    let id = result.int(forColumn: "id")
                    let name = result.string(forColumn: "name")
                    print("id: \(id)")
                    print("name: \(name ?? "nnnnn")")
                }
                result.close()
            } catch {
                print("catch_error: \(error)")
            }
        }
    }
    
    // 解密
    @IBAction func decryptDB(_ sender: Any) {
        do {
            try FMDBSQLCipherHelper.decrypt(key: kDBKey, path: getOriginalDBPath(), targetPath: getDecryptDBPath())
            print("解密成功: \(getDecryptDBPath())")
        } catch {
            print("解密失败: catch_error:\(error)")
        }
    }
    
    @IBAction func encryptDB(_ sender: Any) {
        do {
            try FMDBSQLCipherHelper.encrypt(key: kDBKey, path: getDecryptDBPath(), targetPath: getEncryptDBPath())
            print("加密成功: \(getDecryptDBPath())")
        } catch {
            print("加密失败: catch_error:\(error)")
        }
    }
    
    private func execuSql(sql: String) -> Bool {
        guard let dq = databaseQueue else { return false }
        
        var flag = true
        dq.inDatabase({ (db) in
            do {
                try db.executeUpdate(sql, values: nil)
            } catch {
                flag = false
                print("错误sql：\(sql)")
                print("错误信息：\(error)")
            }
        })
        
        return flag
    }
    
    // 创建文件夹
    private func createFolderInLibrary(path: String) -> String {
        let srcUrl = NSHomeDirectory() + "/Library/"
        let exist = FileManager.default.fileExists(atPath: srcUrl)
        
        if !exist {
            _ = ((try? FileManager.default.createDirectory(atPath: srcUrl, withIntermediateDirectories: true, attributes: nil)) != nil)
        }
        
        return srcUrl
    }
    
    // 原始数据路径
    private func getOriginalDBPath() -> String {
        return createFolderInLibrary(path: "database") + "doshare.db"
    }
    
    // 密文数据路径
    private func getEncryptDBPath() -> String {
        return createFolderInLibrary(path: "database") + "encrypt.db"
    }
    
    // 明文数据路径
    private func getDecryptDBPath() -> String {
        return createFolderInLibrary(path: "database") + "decrypt.db"
    }

}

