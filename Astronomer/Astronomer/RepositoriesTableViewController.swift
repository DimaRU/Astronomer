//
//  RepositoriesTableViewController.swift
//  Astronomer
//
//  Created by Guilherme Rambo on 16/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import UIKit
import RxSwift

class RepositoriesTableViewController: UITableViewController {

    private struct Constants {
        static let cellIdentifier = "repositoryCell"
    }
    
    private weak var provider: DataProvider!
    
    private let disposeBag = DisposeBag()
    
    private var user: User {
        didSet {
            update(with: user)
        }
    }
    
    private var repositoryViewModels: [RepositoryViewModel] = [] {
        didSet {
            tableView.reload(oldData: oldValue, newData: repositoryViewModels)
        }
    }
    
    init(provider: DataProvider, user: User) {
        self.user = user
        self.provider = provider
        
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        update(with: user)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.cellIdentifier)
        
        provider.repositories(by: user).observeOn(MainScheduler.instance).subscribe { event in
            switch event {
            case .next(let repositories):
                self.repositoryViewModels = repositories.map(RepositoryViewModel.init)
            default: break
            }
        }.addDisposableTo(self.disposeBag)
    }
    
    private func update(with user: User) {
        // TODO: fetch user's repositories, store repository view models and display
        title = UserViewModel(user: user).repositoriesTitle
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositoryViewModels.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath)

        cell.textLabel?.text = repositoryViewModels[indexPath.row].repository.name

        return cell
    }

}
