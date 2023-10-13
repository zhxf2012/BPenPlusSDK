//
//  BPenManager+Plus.h
//  BPenPlusSDK
//
//  Created by xingfa on 2022/2/12.
//  Copyright © 2022 bbb. All rights reserved.
//

#import <BPenPlusSDK/BPenManager.h>

NS_ASSUME_NONNULL_BEGIN

@interface BPenManager ()
/// 检查当前连接的笔有无新固件。建议在连接笔之后收到当前固件版本的回调notifyFirmwareVersion之后再check新固件调用
/// 此接口会用到网络，若调用此接口时应用没有联网权限，可能会弹出网络授权请求；若请求通过后请再调用一次此接口。（iOS的一个系统bug，即授权后授权之前已发送的请求仍会返回无网络，但授权又必须发送一个联网请求才触发，触发后如果获得联网权限，需要把之前的请求再发送一次才会有正确的网络回调）
/// @param handel 检查结果回调。有新版本固件时会回调固件版本号，可供界面使用；若出错返回错误；若newVersion为空，且error为空则无需升级
- (void)checkNewFirmwareVersionWithHandel:(void (^ _Nullable)(NSString * _Nullable newVersion,NSError *_Nullable error))handel;

/// 本方法用于升级当前连接的笔或者升级失败处于恢复模式的笔（笔闪红灯，isInDFU为true）到最新版 。此ota升级会依次经过三个步骤：1.加载固件 2.准备升级 3.正式更新固件，本方法提供这个三个步骤的进度回调和最后的完成回调
/// @param dfuPen  处于恢复模式的笔（isInDFU为true）或当前正常连接的笔。如果笔不是处于恢复模式或者笔没连接，则会报错
/// @param loadProgressHandel    固件加载的进度回调 参数percent为0~100的数字，百分比的值，界面可显示为percent%，如60即可表示为 60% /
/// @param prepareHandel    准备升级的过程回调，参数start为true表示准备开始 ,  finished为true表示准备结束
/// @param otaProgressHandel 正式更新固件的进度回调， 参数percent为0~100的数字，百分比的值，界面可显示为percent%，如60即可表示为 60%  //此回调中除了可以显示固件升级进度外，建议提示不要关掉笔也不要退出App，否则升级可能失败。若失败，可以尝试重新调用此方法升级固件
/// @param completedHandel 笔ota完成的回调 参数finished 为true表示升级成功，error为失败的原因
- (void)otaWithPen:(BPenModel *)dfuPen loadFirmwareProgress:(void(^ _Nullable)(int percent)) loadProgressHandel prepareHandel:(void(^ _Nullable)(BOOL start,BOOL finished)) prepareHandel otaProgressHandel:(void(^ _Nullable)(int percent))otaProgressHandel completedHandel:(void(^ _Nullable)(BOOL finished,NSError * _Nullable error))completedHandel;

/// 本方法用于已经获取到新固件的文件，直接传入本地固件文件进行ota升级。
/// @param dfuPen 处于恢复模式的笔（isInDFU为true）或当前正常连接的笔。如果笔不是处于恢复模式或者笔没连接，则会报错
/// @param firmwareFilePath 已下载到本地的固件文件的全路径
/// @param prepareHandel   准备升级的过程回调，参数start为true表示准备开始 ,  finished为true表示准备结束
/// @param otaProgressHandel 式更新固件的进度回调， 参数percent为0~100的数字，百分比的值，界面可显示为percent%，如60即可表示为 60%  //此回调中除了可以显示固件升级进度外，建议提示不要关掉笔也不要退出App，否则升级可能失败。若失败，可以尝试重新调用此方法升级固件
/// @param completedHandel  笔ota完成的回调 参数finished 为true表示升级成功，error为失败的原因
- (void)otaWithPen:(BPenModel *)dfuPen loadFirmwareFromFile:(NSString *) firmwareFilePath prepareHandel:(void(^ _Nullable)(BOOL start,BOOL finished)) prepareHandel otaProgressHandel:(void(^ _Nullable)(int percent))otaProgressHandel completedHandel:(void(^ _Nullable)(BOOL finished,NSError * _Nullable error))completedHandel;

/// 继续使用智慧笔（如果不绑定手机号，调用此方法）
- (void)continueToUse;

//MARK:绑定解绑认证手机号功能已经作废，故而以下三个接口已废弃，请勿使用
/// 绑定手机号码
- (void)bindWithPhoneNumber:(NSString *)phoneNumber;

/// 验证已绑定的手机号码
- (void)verifyBindedWithPhoneNumber:(NSString *)phoneNumber;

/// 解绑手机号码，连接使用中状态（智慧笔亮蓝灯）才能解绑
- (void)unbindWithPhoneNumber:(NSString *)phoneNumber;

@end

NS_ASSUME_NONNULL_END
