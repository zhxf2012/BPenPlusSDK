//
//  BPCanvasImageRender.h
//  BPenSDK
//
//  Created by xingfa on 2021/5/10.
//  Copyright © 2021 bbb. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "BPCanvasRenderProtocol.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol BPCanvasRenderDelegate ;
@interface BPCanvasImageRender : NSObject<BPCanvasRenderDelegate>
@property(nonatomic,assign) CGFloat dpi; //图片的dpi，如不设置或设置低于72dpi的值时则默认72 即72像素每英寸；BPCanvasRenderDelegate中传入底图和底图dpi时，会使用底图dpi

//基于之前 BPCanvasRenderDelegate传入的点绘制图片，若实现updateCanvasWtihBackImage:dpi: 且drawBackImage为true则绘制底图，否则只有纯笔迹
- (UIImage *)getCurrentCavasImageWithBackImage:(BOOL)drawBackImage;
@end

NS_ASSUME_NONNULL_END
