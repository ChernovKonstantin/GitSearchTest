//
//  FeaturedViewController.swift
//  GithubBrowser
//
//  Created by Vitalij Semenenko on 2021-01-25.
//

import UIKit
import RealmSwift

class FeaturedViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func action(_ sender: UIBarButtonItem) {
        if sender.title!.elementsEqual("Done"){
            sender.title = "Edit"
            tableView.setEditing(false, animated: true)
        } else {
            sender.title = "Done"
            tableView.setEditing(true, animated: true)
        }
    }    
    
    private var repositoryDataSourse = [RepositoryObject]()
    private var selectedIndex: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "RepositoryTableViewCell", bundle: nil), forCellReuseIdentifier: cellIndentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 115
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAllData()
    }
    
    func getAllData() {
        let realm = try! Realm()
        let storedData = realm.objects(RealmRepositoryObject.self)
        self.repositoryDataSourse.removeAll()
        for stored in storedData {
            self.repositoryDataSourse.append(RepositoryObject(from: stored))
        }
        self.tableView.reloadData()
        print(storedData.count)
    }
    
    func deleteObjectFromRealm(_ object: RepositoryObject){
        let realm = try! Realm()
        let realmObject = realm.objects(RealmRepositoryObject.self).filter("fullName = %@", object.fullName)
        try! realm.write({
            realm.delete(realmObject)
        })
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

extension FeaturedViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositoryDataSourse.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIndentifier, for: indexPath) as? RepositoryTableViewCell {
            cell.setRepositoryModel(with: self.repositoryDataSourse[indexPath.row], windowType: .featured, target: self, selector: #selector(tapOnImage(tap:)))
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectedIndex = indexPath
        self.performSegue(withIdentifier: "showDetail", sender: self)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let object = repositoryDataSourse[indexPath.row]
            deleteObjectFromRealm(object)
            repositoryDataSourse.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
