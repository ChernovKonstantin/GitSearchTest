//
//  ViewController.swift
//  GithubBrowser
//
//  Created by Vitalij Semenenko on 2021-01-22.
//

import UIKit

class RecentViewController: UIViewController {
    
    @IBOutlet weak var noResultsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private var refreshControl: UIRefreshControl?
    private var repositoryDataSourse = [RepositoryObject]()
    private var selectedIndex: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "RepositoryTableViewCell", bundle: nil), forCellReuseIdentifier: cellIndentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 115
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(getAllData), for: .valueChanged)
        tableView.refreshControl = self.refreshControl
        
        refreshControl?.beginRefreshing()
        getAllData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DetailViewController, let selectedIndex = selectedIndex,
           self.repositoryDataSourse.indices.contains(selectedIndex.row) {
            vc.repositoryModel = self.repositoryDataSourse[selectedIndex.row]
        }
    }
    
    @objc private func getAllData() {
        RepositoryObject.performRequest(with: .getAll) { [weak self] (isSuccess, response) in
            guard let self = self else {return}
            if isSuccess {
                self.repositoryDataSourse = response
            }
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
                if isSuccess { self.tableView.reloadData() }
            }
        }
    }
    
    @objc private func tapOnImage(tap: UITapGestureRecognizer){
        let location = tap.location(in: tableView)
        if let tapIndexPath = tableView.indexPathForRow(at: location){
            if let controller = storyboard!.instantiateViewController(identifier: "AvatarViewController") as? AvatarImageViewController{
                controller.avatarUrl = URL(string: repositoryDataSourse[tapIndexPath.row].owner.avatarUrl!)
                navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}

extension RecentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositoryDataSourse.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIndentifier, for: indexPath) as? RepositoryTableViewCell {
            cell.setRepositoryModel(with: self.repositoryDataSourse[indexPath.row], windowType: .browse, target: self, selector: #selector(tapOnImage(tap:)))
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectedIndex = indexPath
        self.performSegue(withIdentifier: "showDetail", sender: self)
    }
}

