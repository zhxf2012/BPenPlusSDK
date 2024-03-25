//
//  DrawViewController.h
//  BPenDemo
//
//  Created by HFY on 2020/6/22.
//  Copyright © 2020 bbb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BPenPlusSDK/BPenPlusSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface DrawViewController : UIViewController
/// 初始化，必须传入Frame
/// @param frame 必须传入Frame
- (instancetype)initWithFrame:(CGRect)frame;

/// 实时数据绘制
- (void)realTimeDrawing:(NSArray<BPPoint *> *)data;

/// 批量数据绘制
- (void)batchDrawing:(NSArray<BPPoint *> *)data;
@end

NS_ASSUME_NONNULL_END
