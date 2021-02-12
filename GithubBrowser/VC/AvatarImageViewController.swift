//
//  AvatarImageViewController.swift
//  GithubBrowser
//
//  Created by Константин Чернов on 11.02.2021.
//

import UIKit
import NVActivityIndicatorView

class AvatarImageViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    @IBOutlet weak private var avatarImage: UIImageView!
    
    private var datatask: URLSessionDownloadTask?
    var avatarUrl: URL?
    
    deinit {
        datatask?.cancel()
        datatask = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        if let url = avatarUrl{
            datatask = avatarImage.loadImage(url: url){ [weak self] in
                self?.activityIndicator.isHidden = true
                self?.activityIndicator.stopAnimating()
            }
        }
    }

}
