//
//  BPCanvasView.h
//  BPenSDK
//
//  Created by xingfa.zhou on 2020/12/9.
//  Copyright © 2020 bbb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
 
@protocol BPCanvasRenderDelegate ;
//@class BPenPaperTypeModel;
// 在不缩放的情况下 本类的性能良好，但当ContentsScale过大（位于放大状态时，比如8倍甚至更高），绘制层的寄宿图的内存开销可以达到六七百兆 而触发内存警告导致应用被杀掉
@interface BPCanvasView : UIView<BPCanvasRenderDelegate>
//@property (nonatomic,readonly) BPenPaperTypeModel *paper;
@property (nonatomic,readonly) BPaperType paperType;
@property (nonatomic,readonly) unsigned long long pageId;
@property (nonatomic,assign) CGSize contentPhysicSize; // 画布内容的物理尺寸，应使用笔读到的码点对应的铺码文件的成品尺寸
@end
NS_ASSUME_NONNULL_END
