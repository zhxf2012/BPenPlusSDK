//
//  BPCanvasView2.h
//  BPenSDK
//
//  Created by xingfa on 2022/12/9.
//  Copyright © 2022 bbb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BPaperTypeHelper.h"
#import "BPCanvasRenderDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface BPCanvasView2 : UIView<BPCanvasRenderDelegate>
@property (nonatomic,readonly) BPaperType paperType;
@property (nonatomic,readonly) unsigned long long pageId;
@property (nonatomic,assign) CGSize contentPhysicSize; // 画布内容的物理尺寸，应使用笔读到的码点对应的铺码文件的成品尺寸

@end

NS_ASSUME_NONNULL_END
