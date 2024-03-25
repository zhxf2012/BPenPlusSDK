//
//  MyPenManager.m
//  BPenDemo
//
//  Created by HFY on 2020/6/22.
//  Copyright © 2020 bbb. All rights reserved.
//

#import "MyPenManager.h"

@interface MyPenManager() <NSCopying, NSMutableCopying>

@end

@implementation MyPenManager

static MyPenManager *_sharedInstance = nil;

#pragma mark - 单例
+(MyPenManager *)sharedInstance {
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        if (_sharedInstance == nil) {
            _sharedInstance = [[self alloc] init];
        }
    });
    return _sharedInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [super allocWithZone:zone];
    });
    return _sharedInstance;
}

- (id)copyWithZone:(NSZone *)zone {
    return _sharedInstance;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return _sharedInstance;
}
@end
