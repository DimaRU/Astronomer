//
//  DataProvider.swift
//  Astronomer
//
//  Created by Guilherme Rambo on 15/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation

import RxSwift

/// Uses an APIClient and a Storage to provide data for the Astronomer app
final class DataProvider {
    
    private let client: APIClient
    private let storage: Storage
    
    init(client: APIClient, storage: Storage) {
        self.client = client
        self.storage = storage
    }
    
    /// You can subscribe to this variable to get informed when an error occurs on any DataProvider operation
    var error = Variable<Error?>(nil)
    
    // MARK: - Data operations
    
    func searchUsers(with query: String) -> Observable<[User]> {
        client.searchUsers(query: query) { [weak self] result in
            switch result {
            case .success(let results):
                self?.storage.store(users: results.items, completion: nil)
            case .error(let error):
                self?.error.value = error
            }
        }
        
        return storage.searchUsers(with: query)
    }
    
    func repositories(by user: User) -> Observable<[Repository]> {
        client.repositories(by: user.login) { [weak self] result in
            switch result {
            case .success(let repos):
                self?.storage.store(repositories: repos, completion: nil)
            case .error(let error):
                self?.error.value = error
            }
        }
        
        return storage.repositories(by: user)
    }
    
    func user(with login: String) -> Observable<User> {
        client.user(with: login) { [weak self] result in
            switch result {
            case .success(let user):
                self?.storage.store(users: [user], completion: nil)
            case .error(let error):
                self?.error.value = error
            }
        }
        
        return storage.user(withLogin: login)
    }
    
    func stargazers(for repository: Repository) -> Observable<[User]> {
        if let ownerLogin = repository.owner?.login {
            client.stargazers(for: repository.name, ownedBy: ownerLogin) { [weak self] result in
                switch result {
                case .success(let users):
                    var repo = repository
                    repo.stargazers = users
                    self?.storage.store(repositories: [repo], completion: nil)
                case .error(let error):
                    self?.error.value = error
                }
            }
        }
        
        return storage.stargazers(for: repository)
    }
    
}
