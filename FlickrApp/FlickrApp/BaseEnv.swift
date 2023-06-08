//
//  BaseEnv.swift
//  FlickrApp
//
//  Created by Zehra Coşkun on 8.06.2023.
//

import Foundation

class BaseEnv {
    let dict : NSDictionary
    init(resourceName : String) {
        guard let filePath = Bundle.main.path(forResource: resourceName, ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: filePath)
        else {
            fatalError("dosya bulunamadı")
        }
        self.dict = plist
    }
}

protocol ApiKeyable {
    var serviceApiKey : String { get }
}

class FlickrEnv : BaseEnv, ApiKeyable {
    init(){
        super.init(resourceName: "FlickrKeys")
    }
    var serviceApiKey: String {
        dict.object(forKey: "myKey") as? String ?? ""
    }
}
