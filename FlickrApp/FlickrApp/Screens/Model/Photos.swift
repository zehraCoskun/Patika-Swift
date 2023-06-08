//
//  Photos.swift
//  FlickrApp
//
//  Created by Zehra Coşkun on 30.05.2023.
//

import Foundation

struct Photos: Codable {
    let page: Int?
    let pages: Int?
    let perpage: Int?
    let total: Int?
    let photo: [Photo]?
}
