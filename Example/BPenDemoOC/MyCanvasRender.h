//
//  MyCanvasRender.h
//  BPenDemo
//
//  Created by xingfa on 2021/2/3.
//  Copyright © 2021 bbb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyPage.h"

NS_ASSUME_NONNULL_BEGIN

@interface MyCanvasRender : NSObject
@property (nonatomic,readonly) MyPage *page;
@property (nonatomic,copy) void (^dirtyRectDisplayHandel)(CGRect);

- (void)appendPoints:(NSArray<BPPoint *> *) points strokeColor: (UIColor *)color;

@end

NS_ASSUME_NONNULL_END
