//
//  MyCanvas.h
//  BPenDemo
//
//  Created by xingfa on 2021/2/3.
//  Copyright © 2021 bbb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <BPenPlusSDK/BPenPlusSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyCanvas : UIView
@property (nonatomic,assign) CGFloat strokeWidthScale;
@property (nonatomic,assign) CGSize paperPhysicSize;
@property (nonatomic,readonly) CGRect canvasRect;
- (void)drawingWithOgrinalPoints:(NSArray<BPPoint *> *)data strokeColor:(UIColor *)color strokeWidthScale:(CGFloat)strokeWidthScale;
- (void)clearCanvas;
@end

NS_ASSUME_NONNULL_END
