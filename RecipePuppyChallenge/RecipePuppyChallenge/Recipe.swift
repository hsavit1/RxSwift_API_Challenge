//
//  Recipe.swift
//  RecipePuppyChallenge
//
//  Created by Henry Savit on 8/21/18.
//  Copyright © 2018 HenrySavit. All rights reserved.
//

import Foundation
import SwiftyJSON

class Recipe {
    var title: String?
    var href: String?
    var ingredients: String?
    var thumbnail: String?

    init (json: JSON) {
        self.title = json["title"].stringValue
        self.href = json["href"].stringValue
        self.ingredients = json["ingredients"].stringValue
        self.thumbnail = json["thumbnail"].stringValue
    }
    
    public init(){}
    
    public init(title: String) {
        self.title = title
    }
}
