//
//  BPCanvasRender.h
//  BPenSDK
//
//  Created by xingfa.zhou on 2020/12/7.
//  Copyright © 2020 bbb. All rights reserved.
//

//#import <Foundation/Foundation.h>
//#import <UIKit/UIKit.h>

#import "BPRenderAble.h"

NS_ASSUME_NONNULL_BEGIN


@class BPPoint;
//@class BPenPaperTypeModel;

//本类会计算出当前需要重绘的区域
@interface BPCanvasRender :NSObject<BPCGRender>

//@property (nonatomic,assign) CGSize canvasSize;
//@property (nonatomic,assign) CGSize paperSize; // 注意 此项单位为mm，为实际纸张大小
//@property (nonatomic,assign) CGFloat dpi ; //跟paperSize一起可以算出contentSize
//@property (nonatomic,readonly) CGSize contentSize; //单位为pt

//@property (nonatomic, assign) CGFloat strokeWidthScale;
//@property (nonatomic, strong) UIColor *strokeColor;

//@property (nonatomic,readonly) BPenPaperTypeModel * currentPaper;
//@property (nonatomic,readonly) BPaperType currentPaperType;
//@property (nonatomic,readonly) unsigned long long currentPageId;
////@property (nonatomic,readonly) NSArray<BPPoint*> *allPoints;
//
//@property (nonatomic,copy) void (^updateCanvasWhole)(void);
//
//@property (nonatomic,copy) void (^updateCanvasInRect)(CGRect);
//
///// draw the model's strokes to the input context
//- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context;
//
//- (void)drawingWithNonRealtimePoints:(NSArray<BPPoint *> *)data strokeColor:(UIColor *)color strokeWidth:(CGFloat)strokeWidthScale;
//
////实时的点流
//- (void)drawingWithRealtimePoints:(NSArray<BPPoint *> *)data strokeColor:(UIColor *)color strokeWidth:(CGFloat)strokeWidthScale;
//
//- (void)redrawContent ;
//
//- (void)clearContent;
@end

//@interface BPCGCanvasRender  :BPCanvasRender
//
//@end



NS_ASSUME_NONNULL_END
