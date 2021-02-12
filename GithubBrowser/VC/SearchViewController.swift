//
//  SearchViewController.swift
//  GithubBrowser
//
//  Created by Vitalij Semenenko on 2021-01-25.
//

import UIKit
import NVActivityIndicatorView

class SearchViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    @IBOutlet weak var noDataLabel: UITextField!
    
    private var repositoryDataSourse = [RepositoryObject]()
    private var searchTimer: Timer?
    private var selectedIndex: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.isHidden = true
        tableView.register(UINib(nibName: "RepositoryTableViewCell", bundle: nil), forCellReuseIdentifier: cellIndentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 115
    }
    
    private func getAllData(with text: String) {
        showActivityIndicator()
        RepositoryObject.performRequest(with: .getSearchResult(searhText: text)) { [weak self] (isSuccess, response) in
            guard let self = self else {return}
            if isSuccess {
                self.repositoryDataSourse = response
                DispatchQueue.main.async {
                    self.hideActivityIndicator()
                    if self.repositoryDataSourse.isEmpty {
                        self.showNoDataLabel()
                        return
                    }
                    self.hideNoDataLabel()
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func showNoDataLabel(){
        self.noDataLabel.isHidden = false
        self.tableView.isHidden = true
        self.view.bringSubviewToFront(self.noDataLabel)
    }
    
    func hideActivityIndicator(){
        activityIndicatorView.stopAnimating()
        activityIndicatorView.isHidden = true
        self.view.bringSubviewToFront(self.tableView)
    }
    
    func hideNoDataLabel(){
        self.noDataLabel.isHidden = true
        self.tableView.isHidden = false
        self.view.bringSubviewToFront(self.tableView)
    }
    
    func showActivityIndicator(){
        activityIndicatorView.startAnimating()
        activityIndicatorView.isHidden = false
        self.view.bringSubviewToFront(self.activityIndicatorView)
        self.noDataLabel.isHidden = true
        self.tableView.isHidden = true
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DetailViewController, let selectedIndex = selectedIndex,
           self.repositoryDataSourse.indices.contains(selectedIndex.row) {
            vc.repositoryModel = self.repositoryDataSourse[selectedIndex.row]
        }
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositoryDataSourse.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIndentifier, for: indexPath) as? RepositoryTableViewCell {
            cell.setRepositoryModel(with: self.repositoryDataSourse[indexPath.row], windowType: .search, searchText: self.searchBar.text, target: self, selector: #selector(tapOnImage(tap:)))
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectedIndex = indexPath
        self.performSegue(withIdentifier: "showDetail", sender: self)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.searchBar.resignFirstResponder()
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count >= 3 {
            self.searchTimer?.invalidate()
            self.searchTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false, block: { [weak self] (_) in
                self?.getAllData(with: searchText.lowercased())
            })
        }
    }
}
