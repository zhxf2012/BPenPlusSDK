//
//  IdCardManager.swift
//  BPenDemoSwift
//
//  Created by xingfa on 2021/9/18.
//  Copyright © 2021 bbb. All rights reserved.
//

import Foundation
import BPenPlusSDK


struct IdItemList:Codable {
    struct Item :Codable {
        var id:String
        var name:String
    }
     
    var idPrexString: String
    var items:[Item]
    var namePrexString: String
    var title: String
}

struct IdCardGridItem :Identifiable,Equatable {
    static func == (lhs: IdCardGridItem, rhs: IdCardGridItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    let type: BPaperType
    let pageId: CUnsignedLongLong
    let rowCount:Int
    let colCount:Int
    let row:Int
    let col:Int
    
    var id: String {
      return  String(format: "%d-%llu-%d_%d-%d-%d", type.rawValue, pageId,rowCount  ,colCount,row,col)
    }
    
    var bgImage: UIImage? {
        let name = "\(type)_\(pageId).png"
        return UIImage(named: name)
    }
    
    var idItem: IdItemList.Item?
}

/*id功能卡的设计规则： A4纸张留好边距idCardEdgeInsets，然后中间的区域按网格分成小块，每一小块即为一个识别区域，功能卡铺码后笔点到某个位置后，笔会报告的点落到哪个小块，即可以按照如下方式得到对应该区域的编号：
  1.该区域的编号跟功能卡上网格的设计有关，可以自行按照如下规则设置编号 paperType-pageId-rowCount_colCount_row_col
    例如： 0-10000-12_6-0-0  即 - 连接的字段依次为 papertype为0（对应A4P） pageId为10000的这一页作为功能卡，该功能卡页分为12行6列（12_6这个字段不可少，它标识功能卡的设计规格）的网格区域，row 0 col 0 对应第一行第一列。
  2.该编号可由客户绑定自己的模型的唯一标识符，如学生学号、相关功能操作的id等
  3.当笔落到功能卡的相应区域时，应用端可以在实时点回调中按如下方式计算得到编号：a、计算每个网格小块的物理大小（纸张的物理尺寸宽减去边距的left和right再除以colCount即可得到宽，同理得到高） b.笔报告的点PointData (paperType,pageId, x，y） ,判断paperType和pageId是否位于功能卡的paperType和pageid范围（比如某个客户用A4P的1000到1100页用做功能卡，则pageId位于1000~1100均为点击功能卡），若在，则是点击功能卡，否则笔是在一般性的内容书写；x和y为点击在功能卡上的位置，如（25.5，20.4）这个点在知道A4P的纸张大小，边距 网格行列数之后就可以算出来 应该是位于该页的第一个块内 对应的row和col 为（0，0），这样笔在点击功能卡后报告一个点即可得到点击的是哪个具体的编号
 4.编号paperType-pageId-rowCount_colCount_row_col中只有  rowCount_colCount是功能卡中设计使用的，paperType和pageId是功能卡铺码时指定，在笔点击时会报告。这种编号方式记录了功能卡的规格又保证了功能码的唯一性，同时可以方便的地由此编号得到相关参数
 
 目前我们提供一个windows上的工具应用IDCardMaker来设计和制作这个功能卡，生成pdf后再用我们的铺码工具铺码即可使用
 */


class IdItemListManager {
    //以下参数请客户方根据自己制作的功能卡实际情况 调整参数；也可以直接用本项目下Resource目录的0_46572.pdf这个文档，该文档是一个制作好的功能卡文件且已经铺码，直接用600dpi的打印机打印即可配合笔以及本demo使用，查看功能卡效果
    let idCardEdgeInsets :UIEdgeInsets = .init(top: 18, left: 18, bottom: 18, right: 18) //id功能卡上下左右各留18mm的边距
    let idCardPaperType: BPaperType = .A4P  //选用的功能卡纸张规格为A4P
    let idCardPageIdRange :NSRange = .init(location: 46572, length: 10) //预设功能卡pageId 范围为46572~46581共10页
    let idCardRowCount = 10   //id功能卡上的行数，A4纸除掉边距后建议8到16行，其值由您设计功能卡时制定
    let idCardColCount = 4    //id功能卡上的列数，A4纸除掉边距后建议4到10列，其值由您设计功能卡时制定

    
    static let shared = IdItemListManager()
    private var cacheList : [String:IdItemList] = [:]
    
    func getIdItemListFrom(type:BPaperType,pageid:CUnsignedLongLong) -> IdItemList? {
        let configName = "\(type.rawValue)_\(pageid)"
        if let item = cacheList[configName] {
             return item
        }
        
        guard let file = Bundle.main.path(forResource: configName, ofType: "json") else {
            return nil
        }
        
        do {
            let data =  try Data(contentsOf: URL(fileURLWithPath: file))
            let list = try JSONDecoder().decode(IdItemList.self, from: data)
            cacheList[configName] = list
            return list
        } catch {
            print(error)
            return nil
        }
    }
}

extension IdItemListManager {
    func chectIdCartWithPoint(_ point:BPPoint) -> IdCardGridItem? {
        //是否是功能卡idCard的纸张类型
        if point.paperType != idCardPaperType {
            return nil
        }
    
        //检查笔点击的page是否是功能卡
        if !(idCardPageIdRange.contains(Int(point.pageId))) {
             return nil
        }
        
        debugPrint("点击在功能卡\(point.paperType)-\(point.pageId)上")
    
        // 计算点在功能卡上哪个网格块
        let paperSize = BPaperTypeHelper.maxContentSizeInMM(for: point.paperType)//此次采用的是papertype支持的最大铺码纸张，实际使用中应采用功能卡铺码文件的成品尺寸，即底图的物理尺寸  单位为mm
        
        if CGFloat(point.x) < idCardEdgeInsets.left {
            //点击在左边距外
            return nil
        }
        
        if CGFloat(point.x) > (paperSize.width - idCardEdgeInsets.right) {
            //点击在右边距外
            return nil
        }
        
        if CGFloat(point.y) < idCardEdgeInsets.top {
            //点击在上边距外
            return nil
        }
        
        if CGFloat(point.y) > (paperSize.height - idCardEdgeInsets.bottom) {
            //点击在下边距外
            return nil
        }
        
        //id卡上每一个识别块的宽度
        let gridWidth = (paperSize.width - idCardEdgeInsets.left - idCardEdgeInsets.right)/CGFloat(idCardColCount)
        
        //id卡上每一个识别块的高度
        let gridHeight = (paperSize.height - idCardEdgeInsets.top - idCardEdgeInsets.bottom)/CGFloat(idCardRowCount)
        let pointInGrid = CGPoint(x: CGFloat(point.x) - idCardEdgeInsets.left, y: CGFloat(point.y) - idCardEdgeInsets.top)
        let col = Int(ceil(pointInGrid.x / gridWidth))
        let row = Int(ceil(pointInGrid.y / gridHeight))
        
        return IdCardGridItem(type: point.paperType, pageId: point.pageId, rowCount: idCardRowCount, colCount: idCardColCount, row: row,col: col)
    }
}
