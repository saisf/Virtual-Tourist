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
    
//    private enum CodingKeys: String, CodingKey {
//        case stat = "stat"
//        case photos = "photos"
//    }
}

struct Photos: Codable {
    let page: Int
    let pages: Int?
    let perpage: Int
    let photo: [CodablePhoto]?
//    let total: Int?

//    private enum CodingKeys: String, CodingKey {
//        case page = "page"
//        case pages = "pages"
////        case perpage = "perpage"
////////        case photo = "photo"
////        case total = "total"
//    }

}

struct CodablePhoto: Codable {
//    let farm: Int
//    let height_m: Int
//    let id: Int
//    let isfamily: Int
//    let isfriend: Int
//    let ispublic: Int
//    let owner: String
//    let secret: String
//    let server: Int
//    let title: String
    let url_m: String
//    let width_m: Int
    
//    private enum CodingKeys: String, CodingKey {
//        case farm = "farm"
//        case height_m = "heigh_m"
//        case id = "id"
//        case isfamily = "isfamily"
//        case isfriend = "isfriend"
//        case ispublic = "ispublic"
//        case owner = "owner"
//        case secret = "secret"
//        case server = "server"
//        case title = "title"
//        case url_m = "url_m"
//        case width_m = "width_m"
//    }
}

