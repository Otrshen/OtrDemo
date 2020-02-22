//
//  FMDBSQLCipherHelper.swift
//  FMDBSQLCipherDemo
//
//  Created by 申铭 on 2020/2/22.
//  Copyright © 2020 Otrshen. All rights reserved.
//

import Foundation

class FMDBSQLCipherHelper {
    
    /// 加密数据库
    /// - Parameters:
    ///   - key: 密钥
    ///   - path: 明文数据库路径
    ///   - targetPath: 密文数据库路径
    class func encrypt(key: String, path: String, targetPath: String) throws {
        let db = FMDatabase(path: path)
        db.open()
        
        try executeStatementsHelper(db: db, sql: "ATTACH DATABASE '\(targetPath)' AS encrypted KEY '\(key)';")
        try executeStatementsHelper(db: db, sql: "SELECT sqlcipher_export('encrypted');")
        try executeStatementsHelper(db: db, sql: "DETACH DATABASE encrypted;")
    }
    
    /// 解密数据库
    /// - Parameters:
    ///   - key: 密钥
    ///   - path: 密文数据库路径
    ///   - targetPath: 明文数据库路径
    class func decrypt(key: String, path: String, targetPath: String) throws {
        let db = FMDatabase(path: path)
        db.open()
        db.setKey(key)
        
        db.executeStatements("PRAGMA key = '\(key)';")
        // 迁移数据库，从低版本sqlcipher迁移到高版本，兼容旧版加密数据库无法打开的问题。
        db.executeStatements("PRAGMA cipher_migrate;")
        
        try executeStatementsHelper(db: db, sql: "ATTACH DATABASE '\(targetPath)' AS decrypt KEY '';")
        try executeStatementsHelper(db: db, sql: "SELECT sqlcipher_export('decrypt');")
        try executeStatementsHelper(db: db, sql: "DETACH DATABASE decrypt;")
    }
    
    private class func executeStatementsHelper(db: FMDatabase, sql: String) throws {
        db.executeStatements(sql)
        if db.hadError() {
            throw db.lastError()
        }
    }
    
}
