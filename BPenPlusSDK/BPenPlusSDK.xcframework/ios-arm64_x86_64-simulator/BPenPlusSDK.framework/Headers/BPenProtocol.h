//
//  BPenProtocol.h
//  BPenPlusSDK
//
//  Created by xingfa on 2021/2/3.
//  Copyright © 2021 bbb. All rights reserved.
//

#ifndef BPenProtocol_h
#define BPenProtocol_h

#import "BPenManagerBaseDelegate.h"

@protocol BPenManagerDelegate <BPenManagerBaseDelegate>

//可选功能
@optional
/*====Start：笔绑定特定手机号功能的相关回调 不建议使用绑定手机号相关实现====*/
/// 是否绑定手机号码，如果不绑定，主机调用continueToUse方法。
- (void)notifyUserWhetherBindPhoneNumber;

/// 绑定手机号码成功
- (void)notifyPhoneNumberBindSuccess;

/// 绑定手机号码失败
- (void)notifyPhoneNumberBindFail;
 
/// 解绑手机号码成功
- (void)notifyPhoneNumberUnBindSuccess;
 
/// 解绑手机号码失败
- (void)notifyPhoneNumberUnBindFail;

/// 验证手机号码成功
- (void)notifyPhoneNumberVerifySuccess;

/// 验证手机号码失败
- (void)notifyPhoneNumberVerifyFail;
/*====End:笔绑定特定手机号功能的相关回调 不建议使用绑定手机号相关实现====*/
@end
 
#endif /* BPenProtocol_h */
