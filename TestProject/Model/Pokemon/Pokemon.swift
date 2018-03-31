//
//  Pokemon.swift
//  TestProject
//
//  Created by Admin on 3/31/18.
//  Copyright © 2018 Patel, Sanjay. All rights reserved.
//

import Foundation


struct Pokemon:Codable{
    var name: String
    var weight: Int
    var location_area_encounters: String
    var height: Int
    var is_default: Bool
    var id: Int
    var order: Int
    var base_experience: Int
}
