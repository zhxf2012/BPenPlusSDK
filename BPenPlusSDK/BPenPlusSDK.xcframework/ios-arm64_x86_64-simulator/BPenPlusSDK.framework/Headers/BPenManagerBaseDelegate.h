//
//  BPenManagerBaseDelegate.h
//  BPenSDK
//
//  Created by xingfa on 2023/4/17.
//  Copyright © 2023 bbb. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class BPPoint;
@class BPenModel;

typedef NS_ENUM(NSInteger, SynchronizationMode) {
    RealTime = 0,  //实时绘制 智慧笔写字时实时返回笔迹数据
    BatchPointData  //批量绘制 智慧笔每写一定量的笔迹点时返回笔迹数据
};

typedef NS_ENUM(NSInteger, BPChargeState) {
    ChargeStateNoCharge = 0 ,  //未充电
    ChargeStateInCharging, //充电中
    ChargeStateFullPower    // 已充满
} ;

/// 智慧笔返回数据给主机的方法回调
@protocol BPenManagerBaseDelegate <NSObject>
@required
/// 已开始扫描的回调
- (void)didStartScan;

/// 扫描到智慧笔
/// @param model 笔信息
- (void)didDiscoverWithPen:(BPenModel *__nonnull)model;

/// 已停止扫描的回调
- (void)didStopScan;

/// 连接成功
- (void)didConnectSuccess;

/// 连接失败回调
/// @param error 失败信息
- (void)didConnectFail:(NSError * __nullable)error;

/// 断开连接回调
/// @param model 断开的智慧笔信息
/// @param error 断开失败的原因，为空时成功
- (void)didDisconnect:(BPenModel *__nonnull)model error:(NSError *__nullable)error;

/// 智慧笔剩余电量（每5s获得一次）
- (void)notifyBattery:(NSInteger)battery;

/// 智慧笔里未同步的数据占笔的flash的百分比 ，percent位于0~100 ；0表示数据同步完成，100表示笔里的disk已被离线数据占满
// 笔连接之后会回调一次,此后仅当应用层调用penManager的askPenToUpdateReminingDataBytes时会回调
- (void)unSynchronizationDataPercentToPenDisk:(float)percent;

/// 智慧笔里的离线数据量同步完成的回调
- (void)synchronizationDataDidCompleted;

/// 智慧笔当前固件版本
- (void)notifyFirmwareVersion:(NSString *__nonnull)currentVersion;

/// 智慧笔报告坐标点数据同步模式
/// @param mode 模式
- (void)notifyDataSynchronizationMode:(SynchronizationMode)mode;

/// 提示已绑定的手机号码（笔连接的设备无变化时无需提示用户, 只有连上非之前连接的设备才有此回调） 。本SDK当前版本不支持绑定手机号，如当前的笔绑定过手机号，则一定是通过棒棒手记绑定的。基于用户的设备和数据安全，本SDK遇到这种情况会断开笔的连接（笔未绑定手机号时本SDK才可用），可在此回调中提醒用户用用棒棒手记连接笔再解除之前绑定的手机号。
- (void)notifyVerifyPhoneNumber: (NSString *__nonnull)endOfTheNumber;

/// 可以继续使用
- (void)notifyContinueToUseSuccess;

/// 无法继续使用
- (void)notifyContinueToUseFail;

/// 蓝牙未开启
- (void)notifyBluetoothPoweredOff;

/// 不支持蓝牙
- (void)notifyBluetoothUnsupported;

///// 持蓝牙未授权
- (void)notifyBluetoothUnauthorized;

///以下回调可选实现。 以下供可选的回调方法一般对应笔的特殊硬件功能或者特殊固件功能，也即不是所有的笔都支持的功能 ，故可能智慧笔的型号不具备该硬件功能而不提供回调，也可能该笔的固件版本不提供该功能，这两种情况下下面的方法回调不会发生。即以下功能受限于特定的智慧笔硬件或者特定的智慧笔固件，需结合具体的智慧笔使用
@optional

/// 笔的传感器摄像头被遮挡，此方法仅在支持摄像头遮挡提醒的固件上提供，可用于提示不当握笔姿势的情况
- (void)notifyCameraHasBeenCovered;

/// 笔报告是否在充电 ； 笔在蓝牙连接后、充电开始、充电结束 这三种情况下会主动报告是否在充电。应用层若需要显示笔充电状态可在回调中更新笔的充电状态显示，sdk也会更新当前笔是否充电的状态字段;
/// 注意 若固件不支持此功能 则不会有此回调
/// @param chargeState 笔当前充电状态 ,详见该类型BPChargeState的枚举说明
- (void)notifyPenChargeState:(BPChargeState) chargeState;

/// 若笔含重力加速计硬件，则返回笔上面的加速计给的数据，仅带3轴加速计的笔支持改功能并给出对应回调；每秒回调一次别是xyz方向的加速度: ax,ay,az 单位是mg （即重力加速度g的千分之一）,量程范围为 -2g ~ 2g ,
/// @param ax  重力加速度相对于笔身的正交直角坐标系的分量
/// @param ay 重力加速度相对于笔身的正交直角坐标系的分量
/// @param az 重力加速度相对于笔身的正交直角坐标系的分量
/// @param rotation 为摄像头方向与纸面码点相对的旋转角,目前会返回四个值中的一个 0,90,180,270,分别对应旋转0度 90度 180度 270度
- (void)accelerometerDataSendFromPenOnXYZ:(float)ax ay:(float) ay az:(float) az rotation:(short) rotation;
@end

/// 智慧笔返回数据给主机的方法回调
@protocol BPenManagerDrawDelegate <NSObject>
@required
/// 实时坐标点数组
- (void)notifyRealTimePointData:(NSArray<BPPoint *> *__nonnull)pointDrawArray;

/// 同步批量数据点 即将废弃，由notifyWrittingBatchPointData 和notifyOfflineBatchPointData代替
/// 两种情况产生的点会走这个回调返回：1.笔在未连接时书写的点（离线产生的点）在笔再次连接后会通过此回调返回 2.笔在连接状态处于批量绘制模式（笔当前的模式详见notifyDataSynchronizationMode回调所给的值）时书写的点会走这个回调；
///  上述两种情况在后续SDK和固件中将分别由notifyOfflineBatchPointData 和notifyWrittingBatchPointData代替
/// @param pointDrawArray 实时坐标点集
- (void)notifyBatchPointData:(NSArray<BPPoint *> *__nonnull)pointDrawArray;

/// 笔连接且处于批量模式时的书写数据，会多次回调，每次返回不超过八九个点
/// @param pointDrawArray 批量坐标点集 通常单次不超过8个点
- (void)notifyWrittingBatchPointData:(NSArray<BPPoint *> *__nonnull)pointDrawArray;

///笔离线时书写的数据，会多次回调，每次返回一帧约八个点 。本方法回调约10次即发完一包.
///离线 点传输完成会有synchronizationDataDidCompleted回调。
/// @param pointDrawArray  批量坐标点集 通常单次不超过8个点
/// @param remainPackages 笔内剩余离线数据包数。约十次本回调会更新一次剩余包数（减一）；若remainPackages为-1则表示当前固件不支持此剩余信息
- (void)notifyOfflineBatchPointData:(NSArray<BPPoint *> *__nonnull)pointDrawArray remainPackages:(NSInteger)remainPackages;
@end

@protocol BPenRawDataDelegate <NSObject>

- (void) realtimeDataFromPen:(NSString * __nonnull) penMac points:(NSArray<BPPoint *> *__nonnull)points;

- (void) batchDataFromPen:(NSString * __nonnull) penMac points:(NSArray<BPPoint *> *__nonnull)points;

@end

NS_ASSUME_NONNULL_END
