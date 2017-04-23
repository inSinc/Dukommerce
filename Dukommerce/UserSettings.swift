//
//  UserSettings.swift
//  Dukommerce
//
//  Created by Alden Harwood on 3/30/17.
//  Copyright © 2017 Sinclair Toffa & Alden Harwood. All rights reserved.
//

import Foundation

class UserSettings {
    var privatePosts: Bool
    var theme: UserThemes
    
    init(){
        self.privatePosts = false
        self.theme = UserThemes.ThemeOne
    }
    
    enum UserThemes {
        case ThemeOne
        case ThemeTwo
        case ThemeThree
    }
}
