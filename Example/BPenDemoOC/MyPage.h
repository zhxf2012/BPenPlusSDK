//
//  MyPage.h
//  BPenDemo
//
//  Created by xingfa on 2021/2/3.
//  Copyright © 2021 bbb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BPenPlusSDK/BPenPlusSDK.h>

NS_ASSUME_NONNULL_BEGIN
@interface MyStroke : NSObject
@property (nonatomic,readonly) NSArray<BPPoint *> *points;
@property (nonatomic,readonly) CGRect boundingBox;
@property (nonatomic,strong) UIColor *color;

- (void)appendPoint:(BPPoint *)point;
@end

@interface MyPage : NSObject
@property (nonatomic,readonly) NSArray<MyStroke *> *strokes;
@property (nonatomic,readonly) BPaperType paperType;
@property (nonatomic,readonly) unsigned long long pageId;
@property (nonatomic,strong) UIColor *currentStrokeColor;

- (void)appendPoints:(NSArray<BPPoint *> *) points dirtyRectHandel: (void (^)(CGRect))handel;
@end

NS_ASSUME_NONNULL_END
