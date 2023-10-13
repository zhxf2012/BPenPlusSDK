//
//  BPaperTypeHelper.h
//  BPenSDK
//
//  Created by xingfa on 2021/10/18.
//  Copyright © 2021 bbb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, BPaperType) {
    BPaperTypeA4P = 0,
    BPaperTypeA4L = 1,
    BPaperTypeA5P = 2,
    BPaperTypeA5L = 3,
    BPaperTypeA3L = 4,
    BPaperTypeA3P = 5,
    BPaperTypeA2 = 6,
    BPaperTypeB5P = 7,
    BPaperTypeB5L = 8,
    BPaperTypeB4P = 9,
    BPaperTypeB4L = 10,
    BPaperTypeBig4K = 11,
    BPaperTypeBig8K = 12,
    BPaperTypeNormal8K = 13,
    BPaperTypeBig16KP = 14,
    BPaperTypeBig16KL  = 15,
    BPaperTypeNormal16KP = 16,
    BPaperTypeNormal16KL = 17,
    BPaperTypeSNormal16K = 18,
    BPaperTypeNormal32KP = 19,
    BPaperTypeNormal32KL = 20,
    BPaperTypeSpecial32KP = 21,
    BPaperTypeSpecial32KL = 22, //自iOS 1.9.1版本起 原BPaperTypeSNormal32KL重命名为BPaperTypeSpecial32KL，值不变，只是命名上规范一下
    BPaperTypeLetter = 23,
    BPaperTypeLegal = 24,
    BPaperTypeStick = 25,
    BPaperTypeBigBoard = 26,
    BPaperTypeIdArea = 27  
};

@interface BPaperTypeHelper : NSObject

/// 本方法返回BBB预定义的纸张尺寸类型所支持的最大内容尺寸，实际打印或印刷品上铺码的页面实际尺寸小于或等于此尺寸，单位是mm，如：BPaperTypeA4P返回 210 * 297 即BPaperTypeA4P支持的最大成品尺寸是210毫米乘以297毫米
/// @param paperType   BBB预定义的纸张尺寸类型BPaperType
+ (CGSize)maxContentSizeInMMForPaperType:(BPaperType)paperType ;

/// 本方法返回BBB预定义的纸张尺寸类型的名称，可用于编码或者匹配BBB工具中的类型，如 BPaperTypeA4P 返回 "Paper_A4P"；BPaperTypeNormal16KP则返回Paper_Normal16KP
/// @param paperType   BBB预定义的纸张尺寸类型BPaperType
+ (NSString *)nameForPaperType:(BPaperType)paperType ;


/// 本方法返回BBB预定义的纸张尺寸类型的描述，可用于调试查看信息等，如 BPaperTypeA4P 返回 "A4/特度大16开 (210x297)"；BPaperTypeNormal16KP则返回 "正度16开 (185x260)"
/// @param paperType    BBB预定义的纸张尺寸类型BPaperType
+ (NSString *)descriptionForPaperType:(BPaperType)paperType ;
@end



NS_ASSUME_NONNULL_END
