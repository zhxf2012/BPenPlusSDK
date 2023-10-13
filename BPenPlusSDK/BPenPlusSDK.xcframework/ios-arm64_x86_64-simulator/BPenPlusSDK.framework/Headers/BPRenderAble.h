//
//  BPRenderAble.h
//  BPenSDK
//
//  Created by xingfa on 2022/9/16.
//  Copyright © 2022 bbb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BPaperTypeHelper.h"

NS_ASSUME_NONNULL_BEGIN

@class BPPoint;

@protocol BPRenderAble<NSObject>
@property (nonatomic,assign) CGSize canvasSize;
@property (nonatomic,assign) CGSize paperSize; // 注意 此项单位为mm，为实际纸张大小
//@property (nonatomic,assign) CGFloat dpi ; //跟paperSize一起可以算出contentSize

@property (nonatomic,readonly) BPaperType currentPaperType;
@property (nonatomic,readonly) unsigned long long currentPageId;
//@property (nonatomic,readonly) NSArray<BPPoint*> *allPoints;

//@property (nonatomic,copy) void (^updateCanvasWhole)(void);
//
//@property (nonatomic,copy) void (^updateCanvasInRect)(CGRect);

/// draw the model's strokes to the input context
//- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context;

//- (void)drawContentInContext:(CGContextRef)context ;

- (void)drawingWithNonRealtimePoints:(NSArray<BPPoint *> *)data strokeColor:(UIColor *)color strokeWidth:(CGFloat)strokeWidthScale;

//实时的点流
- (void)drawingWithRealtimePoints:(NSArray<BPPoint *> *)data strokeColor:(UIColor *)color strokeWidth:(CGFloat)strokeWidthScale;

- (void)redrawContent ;
    
- (void)clearContent;
@end

@protocol BPCGRender<BPRenderAble>
@property (nonatomic,copy) void (^updateCanvasWhole)(void);

@property (nonatomic,copy) void (^updateCanvasInRect)(CGRect);

/// draw the model's strokes to the input context
- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context;
@end


NS_ASSUME_NONNULL_END
