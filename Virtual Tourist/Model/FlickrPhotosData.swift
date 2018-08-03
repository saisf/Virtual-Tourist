//
//  Data.swift
//  Virtual Tourist
//
//  Created by Sai Leung on 6/12/18.
//  Copyright © 2018 Sai Leung. All rights reserved.
//

import Foundation

struct Stat: Codable {
    let stat: String
    let photos: Photos
}

struct Photos: Codable {
    let page: Int
    let pages: Int?
    let perpage: Int
    let photo: [CodablePhoto]?
}

struct CodablePhoto: Codable {
    let url_m: String
}

