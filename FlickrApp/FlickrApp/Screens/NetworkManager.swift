//
//  NetworkManager.swift
//  FlickrApp
//
//  Created by Zehra Coşkun on 30.05.2023.
//

import Foundation

class NetworkManager {
    
    static let shared = NetworkManager()
    
    func fetchImage(with url:String?, competion: @escaping (Data) -> Void){
        if let urlString = url, let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    debugPrint(error)
                    return
                }
                if let data = data {
                    DispatchQueue.main.async {
                        competion(data)
                    }
                }
            }.resume()
        }
    }
}
