//
//  TablePresentor.swift
//  Basic project
//
//  Created by SIMONOV on 18.06.2022.
//

import Foundation
import UIKit
import Kingfisher

protocol TableViewProtocol: AnyObject {
    func tableViewReloadData()
    
}
protocol TablePresentorProtocol: AnyObject {
    
    var view: TableViewProtocol? { get set }
    func viewDidLoad()
    func numberOfRowsInSection() -> Int
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    func pressingTheFavoritesButton(isSelected: Bool, model: TableModel)
    func dataSearch(searchText: String)
    
}

class TableViewPresentor: TablePresentorProtocol, TableViewCellProtocol {

    private var model: [ReceivedData] = []
    private var filterModel: [ReceivedData] = []
    weak var view: TableViewProtocol?
    private var service = NetworkService()
    private var isSearching = false
    private var pageCount = 2
//MARK: - methods
    
    func viewDidLoad() {
        downloadData()
    }

    func numberOfRowsInSection() -> Int {
        if isSearching { return filterModel.count }
        else { return model.count }
        }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.identifier, for: indexPath) as? TableViewCell
        guard let cell = cell else { return UITableViewCell() }
        
        cell.delegate = self
        
        if isSearching {
            cell.model = TableModel(id: filterModel[indexPath.row].id ?? "", firstName: filterModel[indexPath.row].user?.firstName ?? "" ,
                                   lastName: filterModel[indexPath.row].user?.lastName ?? "",
                           photo: filterModel[indexPath.row].urls?.regular ?? "" , isSelectedButton: false)
        } else {
            cell.model = TableModel(id: model[indexPath.row].id ?? "" ,firstName: model[indexPath.row].user?.firstName ?? "",
                           lastName: model[indexPath.row].user?.lastName ?? "" ,
                           photo: model[indexPath.row].urls?.regular ?? "", isSelectedButton: false)
    }
        if let model = SQLiteCommands.presentRows() {
            
            for x in model {
                if cell.model?.id == x.id {
                    cell.isSelectedButton = true
                    cell.favouritesButton.tintColor = .systemRed
                }
            }
        }
        
        cell.addContent()
        return cell
    }


     private func downloadData() {
         service.getData { [weak self] profiles in
            guard let self = self else { return }
            self.model = profiles
            self.view?.tableViewReloadData()
        }
    }
    
    
    func dataSearch(searchText: String) {
        self.filterModel.removeAll()
        guard searchText.isEmpty || searchText != " " else {
            return
        }
        
        for item in model {
            let text = searchText.lowercased()
            let countainFirstName = item.user?.firstName?.lowercased().range(of: text)
            if countainFirstName != nil {
                self.filterModel.append(item)
            }
        }
        
        if searchText == "" {
            isSearching = false
            view?.tableViewReloadData()
        } else {
            isSearching = true
            view?.tableViewReloadData()
        }
    }
    
    func pressingTheFavoritesButton(isSelected: Bool, model: TableModel) {
       
            if isSelected {
                let databaseModel = SQLiteCommands.presentRows()
                guard let databaseModel = databaseModel else { return }
                for x in databaseModel {
                    if model.id == x.id {
                        return
                    }
                }
                
                SQLiteCommands.insertRow(DatabaseModel(id: model.id, firstName: model.firstName, lastName: model.lastName, photo: model.photo))
                
            } else {
                SQLiteCommands.deleteRow(profileId: model.id)
        }
    }
}
    


        

