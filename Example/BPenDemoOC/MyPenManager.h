//
//  MyPenManager.h
//  BPenDemo
//
//  Created by HFY on 2020/6/22.
//  Copyright © 2020 bbb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BPenPlusSDK/BPenPlusSDK.h>

NS_ASSUME_NONNULL_BEGIN

//不一定用继承，建议自己写代理。
@interface MyPenManager : BPenManager

/// 因为数据可能在多个页面，app长时间使用，所以采用单例。
+(MyPenManager *)sharedInstance;


@end

NS_ASSUME_NONNULL_END
