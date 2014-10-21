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
    private var dataDetector: NSDataDetector?
    var enablePlaceHolderText = false
    
    override init() {
        super.init()
        
        dict = LINParsingEmoticonsTextStorage.getMappingDict()
        expression = LINParsingEmoticonsTextStorage.getRegularExpression()
        dataDetector = LINDataDetectorHelper.getDataDetector()
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
    
    override func replaceCharactersInRange(range: NSRange, withString str: String) {
        imp.replaceCharactersInRange(range, withString: str)
        edited(NSTextStorageEditActions.EditedCharacters, range: range, changeInLength: str.utf16Count - range.length)
    }
    
    override func setAttributes(attrs: [NSObject : AnyObject]!, range: NSRange) {
        imp.setAttributes(attrs, range: range)
        edited(NSTextStorageEditActions.EditedCharacters, range: range, changeInLength: 0)
    }
    
    override func setAttributedString(attrString: NSAttributedString) {
        super.setAttributedString(attrString)

        let wholeRange = NSMakeRange(0, self.string.utf16Count)
        removeAttribute(NSLinkAttributeName, range: wholeRange)
        
        dataDetector!.enumerateMatchesInString(self.string, options: NSMatchingOptions(0), range: wholeRange) { (result, flags, stop) -> Void in
            var value: AnyObject?
            
            switch(result.resultType) {
            case NSTextCheckingType.Link:
                value = result.URL!
            case NSTextCheckingType.PhoneNumber:
                value = result.phoneNumber!
            default:
                break
            }
            
            if value != nil {
                self.addAttribute(NSLinkAttributeName, value: value!, range: result.range)
            }
        }
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
                let textAttactment = LINEmoticonTextAttachment()
                textAttactment.image = UIImage(named: emoticonName!)
                textAttactment.bounds = CGRectMake(0, -5, 20, 20)
                textAttactment.emoticonKey = emoticonKey

                let replacementString = NSAttributedString(attachment: textAttactment)
                replaceCharactersInRange(matchRange, withAttributedString: replacementString)
            }
        }
        
        let wholeRange = NSMakeRange(0, self.string.utf16Count)
        imp.addAttribute(NSFontAttributeName, value: UIFont.appRegularFontWithSize(14), range: wholeRange)
        if !enablePlaceHolderText {
            imp.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: wholeRange)
        }
        
        super.processEditing()
    }
    
    // MARK: Utility methods
    
    func getOriginalText() -> String {
        var result = imp.mutableCopy() as NSMutableAttributedString
        result.enumerateAttribute(NSAttachmentAttributeName, inRange: NSMakeRange(0, self.string.utf16Count), options:NSAttributedStringEnumerationOptions(0), usingBlock: {
            (value, range, stop) -> Void in
                if value != nil {
                    let textAttactment = value! as LINEmoticonTextAttachment
                    result.replaceCharactersInRange(range, withString: textAttactment.emoticonKey)
                }
        })

       return result.string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
   }
    
    func addPlaceHolderForTextViewWithText(text: String) {
       enablePlaceHolderText = true
       setContentForTextViewWithText(text, color: UIColor.lightGrayColor())
    }
    
    func clearPlaceHolderForTextView() {
       enablePlaceHolderText = false
       setContentForTextViewWithText("", color: UIColor.blackColor())
    }
    
    private func setContentForTextViewWithText(text: String, color: UIColor) {
        let placeHolderText = NSMutableAttributedString(string: text)
        placeHolderText.addAttribute(NSForegroundColorAttributeName, value: color, range: NSMakeRange(0, text.utf16Count))
        self.setAttributedString(placeHolderText)
    }
    
    // MARK: Class methods
    
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
    
    class func getRegularExpression() -> NSRegularExpression {
        struct Static {
            static var expression: NSRegularExpression?
        }
        
        if Static.expression == nil {
            let dict = LINParsingEmoticonsTextStorage.getMappingDict()
            let regex = dict["regex"] as String
            Static.expression = NSRegularExpression(pattern: regex, options: NSRegularExpressionOptions.CaseInsensitive, error: nil)
        }
        return Static.expression!
    }
    
    class func serchEmoticonKeyByName(emoticonName: String) -> String {
        let dict = LINParsingEmoticonsTextStorage.getMappingDict()
        return dict.allKeysForObject(emoticonName)[0] as String
    }
}

class LINEmoticonTextAttachment: NSTextAttachment {
    var emoticonKey: String = ""
}
 