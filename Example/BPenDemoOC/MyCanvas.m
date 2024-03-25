//
//  MyCanvas.m
//  BPenDemo
//
//  Created by xingfa on 2021/2/3.
//  Copyright © 2021 bbb. All rights reserved.
//

#import "MyCanvas.h"
#import "MyCanvasRender.h"

@interface MyCanvas ()
@property (nonatomic,strong) MyCanvasRender *render;
@property (nonatomic,assign) CGRect canvasRect;
@end

@implementation MyCanvas
@synthesize strokeWidthScale = _strokeWidthScale;

- (MyCanvasRender *)render {
    if (_render == nil) {
        _render = [[MyCanvasRender alloc] init];
        __weak typeof(self) weakSelf = self;
        _render.dirtyRectDisplayHandel = ^(CGRect rect){
            CGRect dirtyRect = [weakSelf rectInViewForPaperArea:rect];
            [weakSelf updateNowWithRect:dirtyRect];
        };
    }
    return _render;
}

- (void)setStrokeWidthScale:(CGFloat)strokeWidthScale {
    if (_strokeWidthScale != strokeWidthScale ) {
        _strokeWidthScale = strokeWidthScale;
        [self updateNowWithRect:CGRectZero];
    }
}

- (void)doInMainThreadWith:(dispatch_block_t)block {
    if ([[NSThread currentThread] isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            block();
        });
    }
}

- (void)updateNowWithRect:(CGRect)rect {
    [self doInMainThreadWith:^{
        if (CGRectIsEmpty(rect)) {
            [self setNeedsDisplay];
        } else {
            [self setNeedsDisplayInRect:rect];
        }
    }];
}

- (CGRect)canvasRect {
    if (CGRectIsNull(_canvasRect)) {
        [self getTheCanvasRect];
    }
    return _canvasRect;
}

- (void)getTheCanvasRect {
    CGSize viewSize = self.safeAreaLayoutGuide.layoutFrame.size;
    CGSize paperPhysicSize =  [self getThePaperPhysicSize];
    
    CGSize drawSize = viewSize;
    if ((viewSize.width / viewSize.height) > (paperPhysicSize.width / paperPhysicSize.height)) {
        drawSize.width =  viewSize .height * paperPhysicSize.width / paperPhysicSize.height;
        drawSize.height = drawSize.width * paperPhysicSize.height / paperPhysicSize.width;
    } else {
        drawSize.height =  viewSize.width * paperPhysicSize.height / paperPhysicSize.width;
        drawSize.width = drawSize.height * paperPhysicSize.width / paperPhysicSize.height;
    }
    self.canvasRect = CGRectMake(self.center.x - drawSize.width/2.0,self.center.y - drawSize.height/2.0, drawSize.width, drawSize.height);
}

-(CGPoint)positonInViewForPaperPoint:(CGPoint)point {
    CGRect canvasRect  = self.canvasRect;
   
    CGSize canvasSize = canvasRect.size;
    CGPoint canvasOrigin = canvasRect.origin;
    CGSize paperPhysicSize =  [self getThePaperPhysicSize];
    
    CGFloat x = canvasOrigin.x + point.x / paperPhysicSize.width * canvasSize.width ;
    CGFloat y = canvasOrigin.y + point.y / paperPhysicSize.height * canvasSize.height;
    return CGPointMake(x, y);
}

- (CGSize)getThePaperPhysicSize {
    CGSize paperSize =  self.paperPhysicSize;
    if (paperSize.width == 0 || paperSize.height == 0) {
//        BPenPaperTypeModel *paper  = [BPenPaperTypeModel itemWithType: self.render.page.paperType];
//        paperSize =  paper.size;
        paperSize = [BPaperTypeHelper maxContentSizeInMMForPaperType:self.render.page.paperType];
    }
    return  paperSize;
}

-(CGRect) rectInViewForPaperArea:(CGRect) area {
    CGPoint newOrigin =[self positonInViewForPaperPoint:area.origin];
    CGSize paperPhysicSize = [self getThePaperPhysicSize];
    CGRect canvasRect  = self.canvasRect;
    if (CGRectIsEmpty(canvasRect)) {
        [self getTheCanvasRect];
    }
    
    CGFloat width = area.size.width / paperPhysicSize.width * canvasRect.size.width;
    CGFloat height = area.size.height / paperPhysicSize.height * canvasRect.size.height;
    return CGRectMake(newOrigin.x, newOrigin.y, width, height);
}

- (void)drawingWithOgrinalPoints:(NSArray<BPPoint *> *)data strokeColor:(UIColor *)color  strokeWidthScale:(CGFloat)strokeWidthScale{
    [self.render appendPoints:data strokeColor:color];
}

- (void)clearCanvas {
     
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext() ;
    UIGraphicsPushContext(context);
    
#ifdef DEBUG
    double date_begain = CFAbsoluteTimeGetCurrent();
#endif
    
    CGFloat lineWidthScale = (self.strokeWidthScale > 0) ? self.strokeWidthScale * 2 : 1 ;
    
    MyPage *content = self.render.page;
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    CGContextSetFlatness(context, 0.7);
    CGContextSetAllowsAntialiasing(context, YES);
    CGContextSetShouldAntialias(context, YES);
    
    [content.strokes enumerateObjectsUsingBlock:^(MyStroke * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (CGRectIntersectsRect(rect, [self rectInViewForPaperArea:obj.boundingBox])) {
            UIColor *color = (obj.color != nil) ? obj.color : [UIColor blackColor];
            [color setFill];
            [color setStroke];
            
            [obj.points enumerateObjectsUsingBlock:^(BPPoint * _Nonnull objP, NSUInteger idxP, BOOL * _Nonnull stop) {
                if (idxP > 0) {
                    CGPoint prePoint = [self positonInViewForPaperPoint:obj.points[idxP-1].position];
                    CGContextMoveToPoint(context, prePoint.x, prePoint.y);
                    CGPoint point = [self positonInViewForPaperPoint:objP.position];
                    CGContextAddLineToPoint(context, point.x, point.y);
                    CGContextSetLineWidth(context, objP.width * lineWidthScale);
                    CGContextDrawPath(context, kCGPathFillStroke);
                     
                    UIColor* drawColor = objP.isVirtual ? UIColor.redColor : UIColor.blueColor;
                    [drawColor setFill];
                    [drawColor setStroke];
                    CGContextFillEllipseInRect(context, CGRectMake(point.x - 1, point.y - 1, 2, 2));
                }
            }];
            
        }
    }];
#ifdef DEBUG
    double date_end =  CFAbsoluteTimeGetCurrent();
    
    NSLog(@"MyCanvas draw：%@ in ctx  with Time: %.0f 毫秒",NSStringFromCGRect(rect),roundf(1000 *(date_end - date_begain)));
#endif
    UIGraphicsPopContext();
}

@end
