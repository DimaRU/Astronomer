//
//  AstronomerTests.swift
//  AstronomerTests
//
//  Created by Guilherme Rambo on 10/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import XCTest
import SwiftyJSON
import RealmSwift
@testable import Astronomer

class AstronomerTests: XCTestCase {
    
    private var storage: StorageController!
    
    private class func url(for resource: String) -> URL {
        return Bundle(for: AstronomerTests.self).url(forResource: resource, withExtension: "json")!
    }
    
    private class func data(for resource: String) -> Data {
        let url = self.url(for: resource)
        return try! Data(contentsOf: url)
    }
    
    private lazy var singleUserData = AstronomerTests.data(for: "SingleUser")
    private lazy var singleRepoData = AstronomerTests.data(for: "SingleRepo")
    private lazy var searchUsersData = AstronomerTests.data(for: "SearchUsers")
    private lazy var userReposData = AstronomerTests.data(for: "UserRepos")
    private lazy var repoStargazersData = AstronomerTests.data(for: "RepoStargazers")
    
    override func setUp() {
        super.setUp()
        
        storage = StorageController(configuration: Realm.Configuration(inMemoryIdentifier: "testrealm"))
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - Adapter tests
    
    func testUserAdapter() {
        let json = JSON(data: singleUserData)
        let result = UserAdapter(input: json).adapt()
        
        switch result {
        case .error(let error):
            XCTFail("Expected to succeed but failed with error \(error)")
        case .success(let user):
            XCTAssertEqual(user.id, "67184")
            XCTAssertEqual(user.login, "insidegui")
            XCTAssertEqual(user.email, "insidegui@gmail.com")
            XCTAssertEqual(user.name, "Guilherme Rambo")
            XCTAssertEqual(user.company, "FAKECOMPANYFORTESTS")
            XCTAssertEqual(user.location, "Brazil")
            XCTAssertEqual(user.blog, "twitter.com/_inside")
            XCTAssertEqual(user.avatar, "https://avatars.githubusercontent.com/u/67184?v=3")
            XCTAssertEqual(user.bio, "Mac and iOS developer. Maker of WWDC for macOS, @BrowserFreedom, PodcastMenu @chibistudioapp and a bunch of other stuff.")
            XCTAssertEqual(user.repos, 79)
            XCTAssertEqual(user.followers, 399)
            XCTAssertEqual(user.following, 25)
        }
    }
    
    func testSearchUsersAdapter() {
        let json = JSON(data: searchUsersData)
        let result = SearchUsersAdapter(input: json).adapt()
        
        switch result {
        case .error(let error):
            XCTFail("Expected to succeed but failed with error \(error)")
        case .success(let searchResults):
            XCTAssertEqual(searchResults.items.count, 30)
            XCTAssertEqual(searchResults.count, 7662)
            
            let user = searchResults.items[3]
            
            XCTAssertEqual(user.id, "67184")
            XCTAssertEqual(user.login, "insidegui")
            XCTAssertEqual(user.avatar, "https://avatars.githubusercontent.com/u/67184?v=3")
        }
    }
    
    func testRepositoryAdapter() {
        let json = JSON(data: singleRepoData)
        let result = RepositoryAdapter(input: json).adapt()
        
        switch result {
        case .error(let error):
            XCTFail("Expected to succeed but failed with error \(error)")
        case .success(let repository):
            XCTAssertEqual(repository.id, "34222505")
            XCTAssertEqual(repository.name, "WWDC")
            XCTAssertEqual(repository.fullName, "insidegui/WWDC")
            XCTAssertEqual(repository.description, "The unofficial WWDC app for macOS")
            
            XCTAssertEqual(repository.stars, 4838)
            XCTAssertEqual(repository.forks, 361)
            XCTAssertEqual(repository.watchers, 4838)
            
            XCTAssertNotNil(repository.owner)
            XCTAssertEqual(repository.owner?.id, "67184")
            XCTAssertEqual(repository.owner?.login, "insidegui")
            XCTAssertEqual(repository.owner?.avatar, "https://avatars.githubusercontent.com/u/67184?v=3")
        }
    }
    
    func testRepositoriesAdapter() {
        let json = JSON(data: userReposData)
        let result = RepositoriesAdapter(input: json).adapt()
        
        switch result {
        case .error(let error):
            XCTFail("Expected to succeed but failed with error \(error)")
        case .success(let repositories):
            XCTAssertEqual(repositories.count, 29)
            
            let repo = repositories[5]
            XCTAssertEqual(repo.id, "62277423")
            XCTAssertEqual(repo.name, "Binge")
            XCTAssertEqual(repo.fullName, "insidegui/Binge")
            XCTAssertEqual(repo.description, "Projeto exemplo da minha palestra sobre desenvolvimento pra Mac")
            XCTAssertEqual(repo.stars, 6)
            XCTAssertEqual(repo.forks, 2)
            XCTAssertEqual(repo.watchers, 6)
            
            XCTAssertNotNil(repo.owner)
            XCTAssertEqual(repo.owner?.id, "67184")
            XCTAssertEqual(repo.owner?.login, "insidegui")
            XCTAssertEqual(repo.owner?.avatar, "https://avatars.githubusercontent.com/u/67184?v=3")
        }
    }
    
    func testUsersAdapter() {
        let json = JSON(data: repoStargazersData)
        let result = UsersAdapter(input: json).adapt()
        
        switch result {
        case .error(let error):
            XCTFail("Expected to succeed but failed with error \(error)")
        case .success(let users):
            XCTAssertEqual(users.count, 30)
            let user = users[1]
            XCTAssertEqual(user.id, "97697")
            XCTAssertEqual(user.login, "connor")
        }
    }
    
    // MARK: - Storage tests
    
    private lazy var userForStorageTests: User? = {
        let json = JSON(data: self.singleUserData)
        let result = UserAdapter(input: json).adapt()
        
        switch result {
        case .success(let user):
            return user
        default: return nil
        }
    }()
    
    private func repositoryForStorageTests() -> Repository? {
        let json = JSON(data: self.singleRepoData)
        let result = RepositoryAdapter(input: json).adapt()
        
        switch result {
        case .success(let repo):
            return repo
        default: return nil
        }
    }
    
    private func repositoriesForStorageTests() -> [Repository] {
        let json = JSON(data: self.userReposData)
        let result = RepositoriesAdapter(input: json).adapt()
        
        switch result {
        case .success(let repos):
            return repos
        default: return []
        }
    }
    
    func testRealmUserStorage() {
        let user = userForStorageTests!
        
        let expectation = self.expectation(description: "Store user")
        
        storage.store(users: [user]) { error in
            XCTAssertNil(error)
            
            let realm = self.storage.realm()
            
            let realmUser = realm.objects(RealmUser.self).first!
            
            XCTAssertEqual(realmUser.id, user.id)
            XCTAssertEqual(realmUser.login, user.login)
            XCTAssertEqual(realmUser.email, user.email)
            XCTAssertEqual(realmUser.name, user.name)
            XCTAssertEqual(realmUser.company, user.company)
            XCTAssertEqual(realmUser.location, user.location)
            XCTAssertEqual(realmUser.blog, user.blog)
            XCTAssertEqual(realmUser.avatar, user.avatar)
            XCTAssertEqual(realmUser.bio, user.bio)
            XCTAssertEqual(realmUser.repos, Int32(user.repos ?? 0))
            XCTAssertEqual(realmUser.followers, Int32(user.followers ?? 0))
            XCTAssertEqual(realmUser.following, Int32(user.following ?? 0))
            
            XCTAssertEqual(realmUser.user.id, user.id)
            XCTAssertEqual(realmUser.user.login, user.login)
            XCTAssertEqual(realmUser.user.email, user.email)
            XCTAssertEqual(realmUser.user.name, user.name)
            XCTAssertEqual(realmUser.user.company, user.company)
            XCTAssertEqual(realmUser.user.location, user.location)
            XCTAssertEqual(realmUser.user.blog, user.blog)
            XCTAssertEqual(realmUser.user.avatar, user.avatar)
            XCTAssertEqual(realmUser.user.bio, user.bio)
            XCTAssertEqual(realmUser.user.repos, user.repos)
            XCTAssertEqual(realmUser.user.followers, user.followers)
            XCTAssertEqual(realmUser.user.following, user.following)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testRealmRepositoryStorage() {
        let repository = repositoryForStorageTests()!
        
        let expectation = self.expectation(description: "Store repository")
        
        storage.store(repositories: [repository]) { error in
            XCTAssertNil(error)
            
            let realm = self.storage.realm()
            
            let realmRepo = realm.objects(RealmRepository.self).first!
            
            XCTAssertEqual(realmRepo.id, repository.id)
            XCTAssertEqual(realmRepo.name, repository.name)
            XCTAssertEqual(realmRepo.fullName, repository.fullName)
            XCTAssertEqual(realmRepo.tagline, repository.description)
            XCTAssertEqual(realmRepo.stars, Int32(repository.stars))
            XCTAssertEqual(realmRepo.forks, Int32(repository.forks))
            XCTAssertEqual(realmRepo.watchers, Int32(repository.watchers))
            
            XCTAssertNotNil(realmRepo.owner)
            XCTAssertEqual(realmRepo.owner?.id, "67184")
            XCTAssertEqual(realmRepo.owner?.login, "insidegui")
            XCTAssertEqual(realmRepo.owner?.avatar, "https://avatars.githubusercontent.com/u/67184?v=3")
            
            XCTAssertEqual(realmRepo.repository.id, repository.id)
            XCTAssertEqual(realmRepo.repository.name, repository.name)
            XCTAssertEqual(realmRepo.repository.fullName, repository.fullName)
            XCTAssertEqual(realmRepo.repository.description, repository.description)
            XCTAssertEqual(realmRepo.repository.stars, repository.stars)
            XCTAssertEqual(realmRepo.repository.forks, repository.forks)
            XCTAssertEqual(realmRepo.repository.watchers, repository.watchers)
            
            XCTAssertNotNil(realmRepo.repository.owner)
            XCTAssertEqual(realmRepo.repository.owner?.id, "67184")
            XCTAssertEqual(realmRepo.repository.owner?.login, "insidegui")
            XCTAssertEqual(realmRepo.repository.owner?.avatar, "https://avatars.githubusercontent.com/u/67184?v=3")
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testOwnerInfoStorageUpdate() {
        // when a user's data is updated, the owner property for the corresponding repositories should also be updated
        
        let repositories = repositoriesForStorageTests()
        
        let expectation = self.expectation(description: "Test repository owner info")
        
        storage.store(repositories: repositories) { error in
            XCTAssertNil(error)
            
            // complete user record
            
            let user = self.userForStorageTests!
            self.storage.store(users: [user]) { userError in
                XCTAssertNil(userError)
                
                let realm = self.storage.realm()
                let repositories = realm.objects(RealmRepository.self)
                
                XCTAssertEqual(repositories.first?.owner?.id, "67184")
                XCTAssertEqual(repositories.first?.owner?.login, "insidegui")
                XCTAssertEqual(repositories.first?.owner?.email, "insidegui@gmail.com")
                XCTAssertEqual(repositories.first?.owner?.name, "Guilherme Rambo")
                XCTAssertEqual(repositories.first?.owner?.company, "FAKECOMPANYFORTESTS")
                XCTAssertEqual(repositories.first?.owner?.location, "Brazil")
                XCTAssertEqual(repositories.first?.owner?.blog, "twitter.com/_inside")
                XCTAssertEqual(repositories.first?.owner?.avatar, "https://avatars.githubusercontent.com/u/67184?v=3")
                XCTAssertEqual(repositories.first?.owner?.bio, "Mac and iOS developer. Maker of WWDC for macOS, @BrowserFreedom, PodcastMenu @chibistudioapp and a bunch of other stuff.")
                XCTAssertEqual(repositories.first?.owner?.repos, 79)
                XCTAssertEqual(repositories.first?.owner?.followers, 399)
                XCTAssertEqual(repositories.first?.owner?.following, 25)
                
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
}
