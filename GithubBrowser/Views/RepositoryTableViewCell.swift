//
//  RepositoryTableViewCell.swift
//  GithubBrowser
//
//  Created by Vitalij Semenenko on 2021-01-25.
//

import UIKit
import Kingfisher

class RepositoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var repositoryName: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var updateDateLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var starsCount: UILabel!
    @IBOutlet weak var addFavoritesButton: UIButton!
    @IBOutlet weak var languageLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var updateLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var languageConstraintHeight: NSLayoutConstraint!
    @IBOutlet weak var updateConstraintHeight: NSLayoutConstraint!
    
    private var repositoryModel: RepositoryObject?
    
    public func setRepositoryModel(with model: RepositoryObject, windowType: WindowType = .browse, searchText: String? = nil, target view: Any?, selector: Selector?) {
        self.descriptionTextView.sizeToFit()
        self.descriptionTextView.isScrollEnabled = false
        self.repositoryModel = model
        
        if windowType != .search {
            repositoryName.attributedText = NSAttributedString(string: model.fullName)
            descriptionTextView.attributedText = NSAttributedString(string: model.repDescription ?? "")
        } else if let searchText = searchText {
            repositoryName.attributedText = self.higlightText(in: model.fullName, with: searchText)
            descriptionTextView.attributedText = self.higlightText(in: model.repDescription ?? "", with: searchText)
        }
        
        starsCount.text = "★" + String(model.stargazersCount ?? 0)
        
        if let forks = model.forksCount, forks > 0{
            languageLabel.text = "● Forks: \(forks)"
        }
        if let language = model.language, !language.isEmpty{
            if languageLabel.text == nil{
                languageLabel.text = "\(language)"}
            else{
                languageLabel.text?.append(" | \(language)")
            }
        } else {
            languageLabel.isHidden = true
            languageConstraintHeight.constant = 0
            languageLabelHeight.constant = 0
        }
        
        var dateString = model.updatedAt
        if dateString == nil {dateString = model.createdAt}
        if let dateString = dateString {
            updateDateLabel.text = dateString.getStringDateAgo()
        } else {
            updateDateLabel.text = nil
            updateDateLabel.isHidden = true
            updateConstraintHeight.constant = 0
            updateLabelHeight.constant = 0
        }
        
        if let avatarUrl = URL(string: repositoryModel?.owner.avatarUrl ?? "") {
            avatarImageView.kf.indicatorType = .activity
            avatarImageView.kf.setImage(with: avatarUrl)
        } else {
            avatarImageView.image = nil
        }
        addFavoritesButton.isHidden = windowType == .featured
        
        if let view = view, let selector = selector{
        let tap = UITapGestureRecognizer(target: view, action: selector)
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tap)
        }
    }
    
    private func higlightText(in inputText: String, with searchText: String) -> NSMutableAttributedString {
        let text = inputText as NSString
        let color = UIColor.red
        let attributedString = NSMutableAttributedString(string: inputText)
        var ranges = [NSRange]()
        var range = NSRange()
        
        var startLocation = 0
        repeat {
            range = text.range(of: searchText,
                               options: .caseInsensitive,
                               range: NSRange(location: startLocation, length: text.length - startLocation))
            if range.location != NSNotFound {
                startLocation = range.location + range.length
                ranges.append(range)
            }
        } while range.location != NSNotFound
        
        let attributes = [NSAttributedString.Key.foregroundColor: color]
        for range in ranges {
            attributedString.addAttributes(attributes, range: range)
        }
        
        return attributedString
    }
    
    @IBAction func addFavoritesAction(_ sender: Any) {
        if let model = self.repositoryModel {
            model.putObjectToDatabase()
        }
    }
}
