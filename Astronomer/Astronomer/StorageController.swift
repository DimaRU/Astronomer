//
//  StorageController.swift
//  Astronomer
//
//  Created by Guilherme Rambo on 13/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

enum StorageError: Error {
    case notFound
}

final class StorageController {
    
    private let queue = DispatchQueue(label: "Storage", qos: .background)
    
    private func realm() -> Realm {
        return try! Realm()
    }
    
    func store(users: [User], completion: @escaping (Error?) -> ()) {
        queue.async {
            let realmUsers = users.map(RealmUser.init)
            do {
                let realm = self.realm()
                
                try realm.write {
                    realm.add(realmUsers, update: true)
                }
                
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    func store(repositories: [Repository], completion: @escaping (Error?) -> ()) {
        queue.async {
            let realmRepositories = repositories.map(RealmRepository.init)
            do {
                let realm = self.realm()
                
                try realm.write {
                    realm.add(realmRepositories, update: true)
                }
                
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    func searchUsers(with query: String) -> Observable<[User]> {
        let users = self.realm().objects(RealmUser.self).filter("login CONTAINS[c] '\(query)'")
        
        return Observable.from(users).map { realmUsers in
            return realmUsers.map({ $0.user })
        }
    }
    
}
