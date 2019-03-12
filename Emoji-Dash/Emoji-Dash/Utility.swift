//
//  Utility.swift
//  Emoji-Dash
//
//  Created by Esti Tweg on 2019-01-29.
//  Copyright © 2019 Esti Tweg. All rights reserved.
//

import Foundation

class Utility {
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}
