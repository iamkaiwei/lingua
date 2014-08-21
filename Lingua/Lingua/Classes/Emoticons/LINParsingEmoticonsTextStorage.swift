//
//  LINParsingEmoticonsTextStorage.swift
//  Lingua
//
//  Created by Kiet Nguyen on 8/20/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINParsingEmoticonsTextStorage: NSTextStorage {
    private var imp = NSMutableAttributedString()
    private var dict = NSDictionary()
    private var expression = NSRegularExpression()

    override init() {
        super.init()
        
        dict = LINParsingEmoticonsTextStorage.getMappingDict()
        expression = LINParsingEmoticonsTextStorage.getRegularExpression()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Reading text
    
    override var string: String {
        return imp.string
    }
    
    override func attributesAtIndex(location: Int, effectiveRange range: NSRangePointer) -> [NSObject : AnyObject] {
        return imp.attributesAtIndex(location, effectiveRange: range)
    }
    
    // MARK: Text editing
    
    override func replaceCharactersInRange(range: NSRange, withString str: String!) {
        imp.replaceCharactersInRange(range, withString: str)
        edited(NSTextStorageEditActions.EditedCharacters, range: range, changeInLength: str.utf16Count - range.length)
    }
    
    override func setAttributes(attrs: [NSObject : AnyObject]!, range: NSRange) {
        imp.setAttributes(attrs, range: range)
    }
    
    // MARK: Adding emoticons
    
    override func processEditing() {
        let matches = expression.matchesInString(self.string, options: NSMatchingOptions(0), range: NSMakeRange(0, self.string.utf16Count))
        
        for result in matches.reverse() {
            let matchRange = result.range
            let captureRange = result.rangeAtIndex(0)
            
            let emoticonKey = (self.string as NSString).substringWithRange(captureRange) as String
            let emoticonName = dict[emoticonKey.lowercaseString] as? String
            if emoticonName != nil {
                println("Emoticon key: \(emoticonKey)")
                
                let textAttactment = NSTextAttachment()
                textAttactment.image = UIImage(named: emoticonName!)
                textAttactment.bounds = CGRectMake(0, 0, 20, 20)
                
                let replacementString = NSAttributedString(attachment: textAttactment)
                replaceCharactersInRange(matchRange, withAttributedString: replacementString)
            }
        }
        
        super.processEditing()
    }
}

extension LINParsingEmoticonsTextStorage {
    // MARK: Class functions

    // Get mapping keys
    class func getMappingDict() -> NSDictionary {
        struct Static {
            static var dict: NSDictionary?
        }
        
        if Static.dict == nil {
            let path = NSBundle.mainBundle().pathForResource("Emoticons", ofType: "plist")
            Static.dict = NSDictionary(contentsOfFile: path!)
        }
        return Static.dict!
    }
    
    // Get regular expression
    class func getRegularExpression() -> NSRegularExpression {
        struct Static {
            static var expression: NSRegularExpression?
        }
        
        if Static.expression == nil {
            let dict = LINParsingEmoticonsTextStorage.getMappingDict()
            let regex = dict["regex"] as String
            Static.expression = NSRegularExpression.regularExpressionWithPattern(regex, options: NSRegularExpressionOptions.CaseInsensitive, error: nil)
        }
        return Static.expression!
    }

    class func serchEmoticonKeyByName(emoticonName: String) -> String {
        let dict = LINParsingEmoticonsTextStorage.getMappingDict()
        return dict.allKeysForObject(emoticonName)[0] as String
    }
}
 