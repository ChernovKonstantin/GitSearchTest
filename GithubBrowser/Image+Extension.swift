//
//  Image+Extension.swift
//  GithubBrowser
//
//  Created by Константин Чернов on 11.02.2021.
//

import UIKit

extension UIImageView{
    
    func loadImage(url: URL, completion: @escaping (() -> Void)) -> URLSessionDownloadTask{
        let session = URLSession.shared
        let downloadTask = session.downloadTask(with: url) { [weak self] url, response, error in
            if error == nil, let url = url,
               let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    if let weakSelf = self {
                        weakSelf.image = image
                        completion()
                    }
                }
            }
        }
        downloadTask.resume()
        return downloadTask
    }
}
