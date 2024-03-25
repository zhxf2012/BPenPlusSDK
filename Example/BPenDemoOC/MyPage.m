//
//  MyPage.m
//  BPenDemo
//
//  Created by xingfa on 2021/2/3.
//  Copyright © 2021 bbb. All rights reserved.
//

#import "MyPage.h"

@interface MyStroke()
@property (nonatomic, assign) CGFloat minX;
@property (nonatomic, assign) CGFloat minY;
@property (nonatomic, assign) CGFloat maxX;
@property (nonatomic, assign) CGFloat maxY;
@property (nonatomic, strong) NSMutableArray<BPPoint *>* allPoints;
@end

@implementation MyStroke
- (instancetype)init {
    self = [super init];
    if (self) {
        self.minX = CGFLOAT_MAX;
        self.minY = CGFLOAT_MAX;
        self.maxX = 0;
        self.maxY = 0;
        self.color = [UIColor blackColor];
    }
    return self;
}

- (NSMutableArray<BPPoint *> *)allPoints {
    if (_allPoints == nil) {
        _allPoints = [NSMutableArray array];
    }
    return _allPoints;
}

- (NSArray<BPPoint *> *)points {
    return self.allPoints;
}

- (CGRect)boundingBox {
    return  CGRectMake(self.minX , self.minY , self.maxX - self.minX, self.maxY - self.minY);
}

- (void)appendPoint:(BPPoint *)point {
    [self.allPoints addObject:point];
    self.minX = MIN(self.minX, point.position.x-point.width);
    self.minY = MIN(self.minY, point.position.y-point.width);
    self.maxX = MAX(self.maxX, point.position.x+point.width);
    self.maxY = MAX(self.maxY, point.position.y+point.width);
}
@end

@interface MyPage()
@property (nonatomic,strong) NSMutableArray<MyStroke *> *allStrokes;
@property (nonatomic,assign) BPaperType paperType;
@property (nonatomic,assign) unsigned long long pageId;
@end

@implementation MyPage
- (NSMutableArray<MyStroke *> *)allStrokes {
    if (_allStrokes == nil) {
        _allStrokes = [NSMutableArray array];
    }
    return  _allStrokes;
}

- (NSArray<MyStroke *> *)strokes {
    return self.allStrokes;
}

- (void)addPoint:(BPPoint *)point {
    if (point.strokeEnd == true) {
        // 可以自行在此处实现笔锋效果
        return;
    }
    
    if (point.strokeStart) {
        MyStroke *stroke = [[MyStroke alloc] init];
        [stroke appendPoint:point];
        stroke.color = self.currentStrokeColor;
        [self.allStrokes addObject:stroke];
        return;
    }
    
    MyStroke *last = self.strokes.lastObject;
    if (last != nil) {
        [last appendPoint:point];
    }
}

- (void)appendPoints:(NSArray<BPPoint *> *)points dirtyRectHandel:(void (^)(CGRect))handel {
    [points enumerateObjectsUsingBlock:^(BPPoint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.paperType != self.paperType || obj.pageId != self.pageId) {
            [self.allStrokes removeAllObjects];
            self.pageId = obj.pageId;
            self.paperType = obj.paperType;
            [self addPoint:obj];
            
            if (handel != nil) {
                handel(CGRectZero);
            }
        } else if (obj.strokeEnd == true){
            [self addPoint:obj];
            MyStroke *last = self.strokes.lastObject;
            if (handel != nil && last != nil) {
                handel(last.boundingBox);
            }
        } else {
            [self addPoint:obj];
        }
    }];
    
    MyStroke *last = self.strokes.lastObject;
    if (handel != nil && last != nil) {
        handel(last.boundingBox);
    }
}
@end
