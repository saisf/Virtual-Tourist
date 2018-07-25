//
//  UserManager.swift
//  Virtual Tourist
//
//  Created by Sai Leung on 6/12/18.
//  Copyright © 2018 Sai Leung. All rights reserved.
//

import Foundation

struct UserManager {
    var photos = [CodablePhoto]()
    
    static var sharedInstance = UserManager()
}
