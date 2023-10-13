//
//  BPenModel.h
//  BPenDemo
//
//  Created by HFY on 2020/6/17.
//  Copyright © 2020 bbb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BPenProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/// 智慧笔模型 ，注意此类由SDK创建和初始化，请不要自行创建或初始化实例，也不要持久该对象；如需记录连接过的笔，请保存mac地址，然后在开启扫描，SDK发现笔的回调里，判断回调给的BPenModel的mac跟之前保存的mac是否一致

//@protocol BPenManagerDelegate;

@interface BPenModel : NSObject
/// 笔蓝牙广播的名称
@property (nonatomic, readonly) NSString *name;
/// 笔的mac地址，出厂后唯一，智慧笔硬件的唯一标识，可以作为笔的identity；即两个BPenModel实例的mac一致则他们对应同一支笔
@property (nonatomic, readonly) NSString *mac;

///可为空，蓝牙扫描时会生产该对象，不应该持久该字段
@property (nonatomic, readonly) CBPeripheral  * _Nullable peripheral;

///发现时笔的蓝牙信号相对强度，由蓝牙框架给出 单位是mdb，跟距离正相关
@property (nonatomic, readonly) NSNumber* _Nullable rssi;
 
///笔的固件版本，可能为空，连接笔之后会自动更新
@property (nonatomic, readonly) NSString* _Nullable firmwareVersion;

///笔迹数据点的同步模式，连接笔之后会自动更新，向笔发送模式更改指令后也会更新
@property (nonatomic, readonly) SynchronizationMode dataSyncMode;

///笔的电量信息，连接后会约5秒更新一次，且SDK有当前连接的笔的电量信息更新回调
@property (nonatomic, readonly) NSInteger powerPercent;

///笔身存储已用量，也即未同步的数据占笔总容量的百分比  连接后会更新一次，然后sdk主动请求笔更新数据占比容量时会更新此值
@property (nonatomic, readonly) float diskUsedPercent;

@property (nonatomic, readonly) NSUInteger remainOfflineDataPackages;

///当前固件的版本的简短版本号 可以对用户展示，比如 512 可展示 固件512 ； 若firmwareVersion为空 则返回0
@property (nonatomic, readonly) NSUInteger shortFirmwareVersionNumber;

///笔是否处于连接状态
@property (nonatomic, readonly) BOOL isConnect;

///笔是否处于恢复模式
@property (nonatomic, readonly) BOOL isInDFU;

///笔是否可升级固件
@property (nonatomic, readonly) BOOL canUpdateFirmware;

@property (nonatomic,readonly) BOOL isPlusPen;
 
@end

NS_ASSUME_NONNULL_END
