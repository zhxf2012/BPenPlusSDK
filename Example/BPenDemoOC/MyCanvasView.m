//
//  MyCanvasView.m
//  BPenDemo
//
//  Created by xingfa on 2020/12/24.
//  Copyright © 2020 bbb. All rights reserved.
//

#import "MyCanvasView.h"
@import BPenPlusSDK;
 
@implementation CanvasBackImage
- (CGSize )physicSize {
    CGSize size = self.image.size;
    if (self.dpi > 0) {
        CGFloat width =  size.width / self.dpi * 25.4; //一英寸25.4mm
        CGFloat height =  size.height / self.dpi * 25.4;
        return  CGSizeMake(width, height);
    }
    return  size;
}
@end

//本类为演示 自定义实现笔迹和底图对齐,线宽，颜色等功能的 示例。实现笔迹和背景底图对齐的方案说明详见随SDK附带的文档 “画布与底图对齐实现的技术细节.pdf”，本类中相关数据处理和绘制实现仅仅演示如何实现，不保证性能和好的效果,若觉得自定义绘制过于复杂和难以优化性能，也可以直接采用SDK中性能效果更好的BPCanvasView。如有更好效果更高效率的实现，可以联系本人交流：zhouxingfa@bibibetter.com

@interface MyCanvasView ()
@property (nonatomic, strong) UIColor* strokeColor;

@property (nonatomic,strong) UIImageView *backView;
@property (nonatomic,strong) MyCanvas *canvas;
@property (nonatomic,strong)  CanvasBackImage *backImage;
@end

@implementation MyCanvasView
//@synthesize strokeWidthScale = _strokeWidthScale;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void) commonInit {
    self.canvas = [[MyCanvas alloc] initWithFrame:self.bounds];
    self.backView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self addSubview:self.backView];
    [self addSubview:self.canvas];
    self.canvas.backgroundColor = [UIColor clearColor];
    [self sendSubviewToBack:self.backView];
}

//- (void)setStrokeWidthScale:(CGFloat)strokeWidthScale {
//    if (_strokeWidthScale != strokeWidthScale) {
//        _strokeWidthScale = strokeWidthScale ;
//        self.canvas.strokeWidthScale= strokeWidthScale;
//    }
//}

- (void)setStrokeColor:(UIColor *)strokeColor {
    if (_strokeColor != strokeColor) {
        _strokeColor = strokeColor;
        [self setNeedsDisplay];
    }
}

- (void)setContentScaleFactor:(CGFloat)contentScaleFactor {
    [super setContentScaleFactor:contentScaleFactor];
    [self setNeedsDisplay];
}

- (void)clearCanvas {
    [self.canvas clearCanvas];
}

- (void)updateCanvasWtihBackImage:(UIImage *)image imageDPI:(CGFloat)dpi {
    _backImage = [[CanvasBackImage alloc] init];
    _backImage.image = image;
    _backImage.dpi = dpi;
    self.canvas.paperPhysicSize = _backImage.physicSize;
    self.backView.image = self.backImage.image;
    self.backView.frame = self.canvas.canvasRect;
}

- (void)drawingWithNonRealtimePoints:(nonnull NSArray<BPPoint *> *)data strokeColor:(nonnull UIColor *)color  strokeWidthScale:(CGFloat)strokeWidthScale{
    [self.canvas drawingWithOgrinalPoints:data strokeColor:color strokeWidthScale:strokeWidthScale];
}

- (void)drawingWithRealtimePoints:(nonnull NSArray<BPPoint *> *)data strokeColor:(nonnull UIColor *)color strokeWidthScale:(CGFloat)strokeWidthScale{
    [self.canvas drawingWithOgrinalPoints:data strokeColor:color strokeWidthScale:strokeWidthScale];
}

- (void)updateCanvasWtihContentPhysicSize:(CGSize)physicSize {
     
}

@end
