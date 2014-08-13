//
//  LINProficiency.swift
//  Lingua
//
//  Created by Hoang Ta on 8/13/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import Foundation

class LINProficiency: MTLModel, MTLJSONSerializing {
    var proficiencyID: Int = 1
    var proficiencyName: String = ""
    
    override init() {
        super.init()
    }
    
    required init(coder aDecoder: NSCoder!) {
    super.init(coder: aDecoder)
    }
    
    override init(dictionary dictionaryValue: [NSObject : AnyObject]!, error: NSErrorPointer)  {
    super.init(dictionary: dictionaryValue, error: error)
    }
    
    class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        return ["proficiencyID": "_id",
                "proficiencyName": "name"]
    }
    
    class func fromDictionary(dictionary: NSDictionary) -> LINProficiency? {
        let proficiency = LINProficiency()
        if let id = dictionary["_id"] as? Int {
            proficiency.proficiencyID = id
        }
        if let name = dictionary["name"] as? String {
            proficiency.proficiencyName = name
        }
        return proficiency
    }
    
    class func fromProficiency(p: Int) -> LINProficiency? {
        let proficiencies = ["No proficiency", "Elementary proficiency", "Limited proficiency", "Professional proficiency", "Full professional proficiency"]
        let proficiency = LINProficiency()
        switch p {
        case 0...4:
            proficiency.proficiencyID = p + 1
            proficiency.proficiencyName = proficiencies[p]
        default:
            proficiency.proficiencyID = 1
            proficiency.proficiencyName = proficiencies[0]
        }
        return proficiency
    }
}
