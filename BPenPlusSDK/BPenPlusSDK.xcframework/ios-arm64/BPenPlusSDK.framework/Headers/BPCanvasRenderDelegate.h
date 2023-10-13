//
//  BPCanvasRenderDelegate.h
//  BPenSDK
//
//  Created by xingfa on 2021/5/10.
//  Copyright © 2021 bbb. All rights reserved.
//

#ifndef BPCanvasRenderProtocol_h
#define BPCanvasRenderProtocol_h
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class BPPoint;

@protocol BPCanvasRenderDelegate <NSObject>
@required
/// 非实时的，批量的点，不是由笔实时产生的点请用此方法绘制
/// @param points 实时待绘制的点
/// @param color 这一批点轨迹用的颜色
/// @param strokeWidthScale 笔迹线宽系数。一个笔画stroke内的原始线宽是有粗细的（会基于点的width生成笔划各处的粗细）， 传入非0的strokeWidthScale会在此基础上将笔划内各处的线宽乘以系数strokeWidthScale
- (void)drawingWithNonRealtimePoints:(NSArray<BPPoint *> *_Nonnull)points strokeColor:(UIColor *_Nonnull)color strokeWidthScale:(CGFloat)strokeWidthScale;

//实时的点流用此方法绘制
/// @param points 实时待绘制的点
/// @param color 这一批点轨迹用的颜色
/// @param strokeWidthScale 笔迹线宽系数。一个笔画stroke内的原始线宽是有粗细的（会基于点的width生成笔划各处的粗细）， 传入非0的strokeWidthScale会在此基础上将笔划内各处的线宽乘以系数strokeWidthScale
- (void)drawingWithRealtimePoints:(NSArray<BPPoint *> *_Nonnull)points strokeColor:(UIColor *_Nonnull)color strokeWidthScale:(CGFloat)strokeWidthScale;


/// 清除当前画布的颜色
- (void)clearCanvas;

/*以下两个方法会更新画布内容的大小，区别在于：
  1.方法updateCanvasWtihBackImage:imageDPI: 会根据底图image和imageDPI计算物理尺寸，设置画布中内容的显示区域（通常是画布视图中居中且尽可能大），笔迹会在此区域显示，然后在内容区域加载底图image并与笔迹对齐
  2.方法updateCanvasWtihContentPhysicSize： 会根据传入的size设置画布中内容的显示区域（通常是画布视图中居中且尽可能大），笔迹点会在此区域显示
 */

/// 画板底图，其大小和长宽比决定画板的实际内容区域 ，imageDPI 图片的dpi 即point per inch ,如300 dpi 就是每英寸300个点，笔迹和底图会在实际内容区域显示并对齐
/// @param image 底图，为铺码pdf的成品区域，通常可以通过铺码工具自动生成
/// @param dpi 底图的dpi (即point per inch ,如300 dpi 就是每英寸300个点), 如果是铺码工具生成的底图则默认为300 dpi ，即每英寸300个像素；如果是自己根据原pdf或者其他方式生成，则需要保证底图就是我们铺码的成品区域，dpi可以用底图像素长度值除以成品区域的物理尺寸（如8.7 inch 8.7英寸）
- (void)updateCanvasWtihBackImage: (nullable UIImage *)image imageDPI:(CGFloat)dpi;

/// 通过传入的内容的物理尺寸physicSize设置画布中内容的显示区域（通常是画布视图中居中且尽可能大），笔迹点会在此区域显示
/// @param physicSize 内容的尺寸，通常为铺码内容的成品区域，单位为毫米mm。如A4内容为210 mm *  297 mm 则传入（210，297）
- (void)updateCanvasWtihContentPhysicSize:(CGSize)physicSize;
@end

#endif /* BPCanvasRenderProtocol_h */
