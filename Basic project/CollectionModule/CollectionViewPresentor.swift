//
//  CollectionPresentor.swift
//  Basic project
//
//  Created by SIMONOV on 18.06.2022.
//

import Foundation
import UIKit
import Kingfisher

protocol CollectionViewProtocol: AnyObject {
    
    func collectionViewReloadData()
    
}

protocol CollectionPresentorProtocol: AnyObject {
    var view: CollectionViewProtocol? { get set }
    func viewDidLoad()
    func numberOfRowsInSection() -> Int
    func cellForItemAt(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    func updateModel(completion: @escaping ([CollectionModel]) -> Void)
    func configureModel()
}

class CollectionViewPresentor: CollectionPresentorProtocol, CollectionViewCellProtocol {
   
    
    weak var view: CollectionViewProtocol?
    var service = NetworkService()
    var model: [CollectionModel] = []

    
    func viewDidLoad() {
        createTable()
    }
        
    
    func numberOfRowsInSection() -> Int {
        return model.count
    }
    
    func cellForItemAt(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavoritesCollectionViewCell.identifier, for: indexPath) as? FavoritesCollectionViewCell
        guard let cell = cell else { return UICollectionViewCell() }
        
        cell.delegate = self
        
        cell.model = CollectionModel(id: model[indexPath.row].id,
                                             firstName: model[indexPath.row].firstName,
                                             lastName: model[indexPath.row].lastName,
                                             photo: model[indexPath.row].photo)
        cell.setContent()
        return cell
    }
    
    func configureModel() {
        updateModel { [weak self] data in
            self?.model = data
            self?.view?.collectionViewReloadData()
        }
    }
    
    private func createTable() {
        let database = SQLiteDatabase.general
        database.createTable()
    }
    
     func updateModel(completion: @escaping ([CollectionModel]) -> Void) {
        
        let model: [DatabaseModel] = SQLiteCommands.presentRows() ?? []
        var cellModel: [CollectionModel] = []
        
        for x in model {
            //let string = String(decoding: x.photo, as: UTF8.self)
            cellModel.append(CollectionModel(id: x.id, firstName: x.firstName, lastName: x.lastName, photo: x.photo ))
        }
        completion(cellModel)
    }
    
    func deletingTheSelectedCell(model: CollectionModel) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            SQLiteCommands.deleteRow(profileId: model.id)
            self.updateModel { [weak self] data in
                self?.model = data
                self?.view?.collectionViewReloadData()
            }
        }
    }
}

  


