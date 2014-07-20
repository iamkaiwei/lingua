//
//  LINBadgeFlowLayout.swift
//  Lingua
//
//  Created by Hoang Ta on 7/9/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

import UIKit

class LINBadgeFlowLayout: UICollectionViewFlowLayout {
   
    var sections = [LINBadgeSection]()
    var contentSize = CGSizeZero
    var recession: CGFloat = 8
    
    override func collectionViewContentSize() -> CGSize {
        return contentSize;
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        sectionInset = UIEdgeInsetsMake(10, 10, 10, 10)
        itemSize = CGSizeMake(48, 53);
        minimumInteritemSpacing = 5
        headerReferenceSize = CGSizeMake(0, 20)
        
        var sectionStartingY: CGFloat = 0
        let fixedWidth = CGRectGetWidth(collectionView.frame)
        let maximumNumberOfItemsPerLine = (fixedWidth + minimumInteritemSpacing - sectionInset.left - sectionInset.right) / (itemSize.width + minimumInteritemSpacing)
        let fixedInteritemSpacing = (fixedWidth - maximumNumberOfItemsPerLine * itemSize.width - sectionInset.left - sectionInset.right) / (maximumNumberOfItemsPerLine - 1)
        
        for (var sectionIndex = 0; sectionIndex < collectionView.numberOfSections() ; sectionIndex++) {
            let section = addSection()
            section.headerFrame = CGRectMake(0, sectionStartingY, fixedWidth, headerReferenceSize.height)
            
            var rowStartingX = sectionInset.left
            var rowStartingY = CGRectGetMaxY(section.headerFrame) + sectionInset.top
            var isOddRow = true
            
            for (var rowIndex = 0; rowIndex < collectionView.numberOfItemsInSection(sectionIndex); rowIndex++) {
                let row = section.addRow()
                row.frame = CGRectMake(rowStartingX, rowStartingY, itemSize.width, itemSize.height)
                rowStartingX += itemSize.width + fixedInteritemSpacing
                
                if (rowStartingX + itemSize.width > fixedWidth - sectionInset.right) { //Drop line here
                    if isOddRow {
                        rowStartingX = sectionInset.left + itemSize.width / 2 + fixedInteritemSpacing / 2
                    }
                    else {
                        rowStartingX = sectionInset.left
                    }
                    rowStartingY += itemSize.height - recession
                    isOddRow = !isOddRow
                }
            }
            
            section.frame = CGRectMake(0, sectionStartingY, fixedWidth, rowStartingY + itemSize.height + sectionInset.bottom - sectionStartingY)
            sectionStartingY = CGRectGetMaxY(section.frame)
        }
        contentSize = CGSizeMake(fixedWidth, sectionStartingY)
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]! {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        for (var sectionIndex = 0 ; sectionIndex < sections.count; sectionIndex++) {
            let section = sections[sectionIndex]
            if !CGRectIntersectsRect(section.frame, rect) {
                continue
            }
            let indexPath = NSIndexPath(forItem:0, inSection: sectionIndex)
            layoutAttributes.append(layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath: indexPath))
            
            for (var rowIndex = 0 ; rowIndex < section.rows.count; rowIndex++) {
                let row = section.rows[rowIndex]
                if !CGRectIntersectsRect(row.frame, rect) {
                    continue
                }
                let indexPath =  NSIndexPath(forItem:rowIndex, inSection: sectionIndex)
                layoutAttributes.append(layoutAttributesForItemAtIndexPath(indexPath))
            }
        }
        
        return layoutAttributes
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath!) -> UICollectionViewLayoutAttributes! {
        let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        let section = sections[indexPath.section]
        let row = section.rows[indexPath.row]
        attributes.frame = row.frame
        return attributes
    }
    
    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String!, atIndexPath indexPath: NSIndexPath!) -> UICollectionViewLayoutAttributes! {
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, withIndexPath: indexPath)
        let section = self.sections[indexPath.section]
        attributes.frame = section.headerFrame
        return attributes
    }
    
    func addSection() -> LINBadgeSection {
        let section = LINBadgeSection()
        sections.append(section)
        return section
    }
}

class LINBadgeRow {
    var frame = CGRectZero
}

class LINBadgeSection {
    
    var frame = CGRectZero
    var headerFrame = CGRectZero
    var rows = [LINBadgeRow]()
    
    func addRow() -> LINBadgeRow {
        let row = LINBadgeRow()
        rows.append(row)
        return row
    }
}