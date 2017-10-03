//
//  Sweet.swift
//  firestoreapp
//
//  Created by Brian Advent on 02.10.17.
//  Copyright © 2017 Brian Advent. All rights reserved.
//

import Foundation
import Firestore

protocol DocumentSerializable  {
    init?(dictionary:[String:Any])
}


struct Sweet {
    var name:String
    var content:String
    var timeStamp:Date
    
    var dictionary:[String:Any] {
        return [
            "name":name,
            "content" : content,
            "timeStamp" : timeStamp
        ]
    }
    
}

extension Sweet : DocumentSerializable {
    init?(dictionary: [String : Any]) {
        guard let name = dictionary["name"] as? String,
            let content = dictionary["content"] as? String,
            let timeStamp = dictionary ["timeStamp"] as? Date else {return nil}
        
        self.init(name: name, content: content, timeStamp: timeStamp)
    }
}


