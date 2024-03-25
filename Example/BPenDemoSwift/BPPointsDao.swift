//
//  BPPointsDao.swift
//  BPenSDKDemo
//
//  Created by Xingfa Zhou on 2023/6/30.
//  Copyright © 2023 bbb. All rights reserved.
//

import Foundation
import BPenPlusSDK

class BPSingleStroke : NSObject {
    private(set) var points: [BPPoint] = []
    
    func appendPoint(_ point:BPPoint) -> Bool {
        points.append(point)
        return true
    }
}

class BPSinglePage : NSObject {
    private(set) var points:[BPPoint] = []
    
    private(set) var strokes:[BPSingleStroke] = []
    
    var paperType: BPaperType = .A4P
    
    var pageId: CUnsignedLongLong = 0
    
     var indexKey: String {
         return BPSinglePage.keyForPapertype(paperType, pageId: pageId)
    }
    
    static func keyForPapertype(_ papertype: BPaperType,pageId:CUnsignedLongLong) -> String {
        return "\(papertype.rawValue)-\(pageId)"
    }
    
    func appendPoint(_ point:BPPoint) -> Bool {
        if self.points.isEmpty {
            pageId = point.pageId
            paperType = point.paperType
        }
        
        guard pageId == point.pageId else {
            return false
        }
        
        guard paperType == point.paperType else {
            return false
        }
        
        points.append(point)
        
        if point.strokeStart {
            let currentStroke = BPSingleStroke()
            let result =  currentStroke.appendPoint(point)
            self.strokes.append(currentStroke)
            return result
        }  else {
            if let current = strokes.last {
                return  current.appendPoint(point)
            } else {
                let currentStroke = BPSingleStroke()
                let result =  currentStroke.appendPoint(point)
                self.strokes.append(currentStroke)
                return result
            }
        }
    }
}


class BPPointsDAO: NSObject {
    private(set) var pages: [BPSinglePage] = []
    private(set) var indexDic: [String:BPSinglePage] = [:]
    var currentPageInex:Int?
    var currentPage: BPSinglePage?
    
    func findPageWith(_ paperType: BPaperType,pageId:CUnsignedLongLong) -> BPSinglePage? {
        let key = BPSinglePage.keyForPapertype(paperType, pageId: pageId)
        return self.indexDic[key]
    }
    
    func processPoints(_ points:[BPPoint],completed:((Bool,BPSinglePage,[BPPoint]) -> ())) {
        var currentPaperType = currentPage?.paperType ?? .A4P
        var curremtpageId: UInt64 = currentPage?.pageId ?? 0
        var redrawPoints: [BPPoint] = []
       // var currentPage = findPageWith(currentPaperType, pageId: curremtpageId)
        var hasChangePage = false
        
        for (_,item) in points.enumerated() {
            if ((item.paperType != currentPaperType)||(item.pageId != curremtpageId)) {
                curremtpageId = item.pageId
                currentPaperType = item.paperType
                currentPage = findPageWith(currentPaperType, pageId: curremtpageId)
                hasChangePage = true
                redrawPoints.removeAll()
                if let currentPage = currentPage {
                    currentPageInex = pages.firstIndex(of: currentPage)
                    redrawPoints.append(contentsOf:currentPage.points)
                }
            }
            
            if let currentPage = currentPage {
                _ = currentPage.appendPoint(item)
            } else {
                let page = BPSinglePage.init()
                if page.appendPoint(item) {
                    pages.append(page)
                    indexDic[page.indexKey] = page
                    currentPage = page
                    currentPageInex =  pages.count-1;
                }
                hasChangePage = true
                redrawPoints.removeAll()
            }
            
            redrawPoints.append(item)
        }
        
        completed(hasChangePage,currentPage ?? BPSinglePage() ,redrawPoints);
        
    }
}
