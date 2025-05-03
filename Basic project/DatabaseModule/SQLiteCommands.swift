//
//  SQLiteCommands.swift
//  Basic project
//
//  Created by SIMONOV on 01.07.2022.
//
import Foundation
import SQLite
import SQLite3

class SQLiteCommands {
    
    static var table = Table("databaseModel")
    static let id = Expression<String>(value: "id")
    static let firstName = Expression<String>(value: "firstName")
    static let lastName = Expression<String>(value: "lastName")
    static let photo = Expression<String>(value: "photo")
    
    static func createTable() {
        guard let database = SQLiteDatabase.general.database else {
            print("Datastore connection error")
            return
        }
        
        do {
            try database.run(table.create(ifNotExists: true) { table in
                table.column(id)
                table.column(firstName)
                table.column(lastName)
                table.column(photo)
            })
        } catch {
            print("Table already exists: \(error)")
        }
    }
    
    static func insertRow(_ profileValues: DatabaseModel) -> Bool? {
        guard let database = SQLiteDatabase.general.database else {
            print("Datasource connection error")
            return nil
        }
        do {
            try database.run(table.insert(id <- profileValues.id,
                firstName <- profileValues.firstName, lastName <- profileValues.lastName, photo <- profileValues.photo))
            return true
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            print("Insert row failed: \(message), in \(String(describing: statement))")
            return false
        } catch let error {
            print("Insertion failed: \(error)")
            return false
        }
    }
    
    static func presentRows() -> [DatabaseModel]? {
        guard let database = SQLiteDatabase.general.database else {
            print("Database connection error")
            return nil
        }
        
        var profileArray = [DatabaseModel]()
        
        table = table.order(id.desc)
        
        do {
            for profile in try database.prepare(table) {
                
                let idValue = profile[id]
                let firstNameValue = profile[firstName]
                let firstLastValue = profile[lastName]
                let photoValue = profile[photo]
                
                let profileObject = DatabaseModel(id: idValue, firstName: firstNameValue, lastName: firstLastValue, photo: photoValue)
                
                profileArray.append(profileObject)
                
                print("id \(profile[id]), firstName: \(profile[firstName]), lastName: \(profile[lastName]), photo: \(profile[photo])")
            }
        } catch {
            print("Present row error: \(error)")
        }
        return profileArray
    }
    
    static func deleteRow(profileId: String) {
        guard let database = SQLiteDatabase.general.database else {
            print("Datastore connection  error")
            return
        }
        
        do {
            let profile = table.filter(id == profileId).limit(1)
            try database.run(profile.delete())
        } catch {
            print("Delete row error: \(error)")
        }
    }
}
