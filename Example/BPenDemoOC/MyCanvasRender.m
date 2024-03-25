//
//  MyCanvasRender.m
//  BPenDemo
//
//  Created by xingfa on 2021/2/3.
//  Copyright © 2021 bbb. All rights reserved.
//

#import "MyCanvasRender.h"

@interface MyCanvasRender()
@property (nonatomic, strong) MyPage *page;
@end

@implementation MyCanvasRender
- (MyPage *)page {
    if (_page == nil ) {
        _page = [[MyPage alloc] init];
    }
    return  _page;
}

- (void)appendPoints:(NSArray<BPPoint *> *)points strokeColor:(UIColor *)color {
    self.page.currentStrokeColor = color;
    [self.page appendPoints:points dirtyRectHandel:self.dirtyRectDisplayHandel];
}
@end
