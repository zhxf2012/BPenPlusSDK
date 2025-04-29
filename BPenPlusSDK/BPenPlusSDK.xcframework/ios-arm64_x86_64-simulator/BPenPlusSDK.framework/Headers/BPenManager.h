//
//  BPenManager.h
//  BPenSDK
//
//  Created by HFY on 2020/6/17.
//  Copyright © 2020 bbb. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "BPenProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class BPenModel;
@protocol BPenManagerDelegate;
@protocol BPenManagerDrawDelegate;
@protocol BPenRawDataDelegate;


typedef enum : NSUInteger {
    BPenConnectTypeDefault = 0,    //默认连接方式，连接后离线数据会利用空闲时自动同步
    BPenConnectTypeBatchDataAutoSyncClose,   //连接后不主动发送数据，笔内离线数据在应用层发送startSynchronizationBatchDatas时才会开始同步;此行为目前仅智慧笔B8系列固件20版本之后支持，其他系列和老版本固件仍按照旧的自动同步的方式进行数据同步
} BPenConnectType;

typedef enum : NSUInteger {
    BPenSmoothLevelDefault = 0,  //默认平滑类型，当前其行为跟BPenSmoothLevelBase一致
    BPenSmoothLevelNone,         //不做平滑，采用笔采集的原始点，直接回调给应用层
    BPenSmoothLevelBase,         //会对笔硬件返回的点中的补偿点进行纠偏，平滑等操作，以优化笔补偿等效果
    BPenSmoothLevelAdvantage     //会对笔硬件返回的所有点进行平滑，提升密度或降低密度以保证平滑和高精度还原纸面笔迹的情况下保持最低的点密度。暂未实现，目前效果同BPenSmoothLevelNone
} BPenSmoothLevel;

/// 主机发送数据给笔端的方法
@interface BPenManager : NSObject

/// 设置代理
@property (nonatomic, weak) id<BPenManagerDelegate> delegate;
@property (nonatomic, weak) id<BPenManagerDrawDelegate> drawDelegate;
@property (nonatomic, readonly) BOOL isScanning ;//是否正在扫描

///对笔采集的笔迹点平滑策略，其值影响sdk回调输出的坐标点数量以及效果，详见BPenSmoothLevel的说明，默认值为BPenSmoothLevelDefault，建议不做修改。若需要配置此项，请在初始化本实例后马上赋值且避免此后动态修改此项的值
@property (nonatomic,assign) BPenSmoothLevel smoothLevel;

///是否过滤掉笔画结束前过长的笔锋，默认不过滤；若开启，笔锋可能会变短，但会减轻部分客户在意的过长收笔笔锋（也就是所谓的勾笔）
@property (nonatomic,assign) BOOL shouldFilterPointsNearStrokeEnd;

///是否自动恢复之前的连接
/**默认为yes，在笔因为盖上帽子或者待机等断开的状态下自动开启蓝牙扫描直到发现之前的笔而重新连接；
  
 若传入false,则SDK不做自动连接；即笔在闲置超时待机,用户盖上笔帽，升级固件重启后会断开蓝牙连接（有回调），需用户在这个断开的回调中自行扫描实现连接
 
 若需要配置此项，请在初始化本实例后马上赋值且避免此后动态修改此项的值
 */
///
@property (nonatomic, assign) BOOL shouldAutoRecoveryConnect ;

///是否由SDK自动应答离线或批量数据的应答
///
/**
 1.在笔传输批量数据时，数据会分批次传输（每批次约512字节的数据量），需要给笔应答确认收到该批次的完整数据，客户端在接收数据后应答笔之后，笔才会发下一个批次的数据。目前这个应答可以由SDK自动应答或者由用户通过sdk提供的应答方法手动应答
 
 2. shouldAutoReplyWhenSynchronizeData 本属性表示是否开启自动应答，默认true开启，SDK内部自动应答；
 
 3. 如置为false,则需用户在BPenManagerDrawDelegate 的 notifyBatchPointData方法中处理离线数据后调用应答方法sdk本类提供的replyForBatchDataReceived 应答后才会发送下一个批次的离线数据。
 
 4.建议在sdk初始化的时候修改本属性，尽量避免动态改动该值，至少避免在有离线数据的情况下改动该值，以避免应答不成功收不到下一个批次的数据
 */
///
@property (nonatomic,assign) BOOL shouldAutoReplyWhenSynchronizeData ;

/// 是否过滤点数据流中的疑似错误页码的点，这些点通常有如下特征，快速换页且新页内只有两三个点的点又切换回原来的页；
/// 开启此项可以避免应用中收到因纸面码点被破坏而产生的错误页码点的情况，一般建议开启，默认也是开启；
/// 某些情况下，如用到局部铺码 需要判断很小区域内采集到点的情况（可能切换到该页然后笔点击该局部铺码的区域只采集到一两个点  然后又快速换页等极限情况可能会漏掉这些点）时，可以考虑关闭此项
@property (nonatomic,assign) BOOL shouldFilterLessAndFastPageChangedPoints ;

/// 目前本SDK仅支持连接一支笔，currentConnectPen即为当前连接的笔
@property (nonatomic, readonly)  BPenModel * _Nullable currentConnectPen;


/// 扫描智慧笔
- (void)startScan;

/// 停止扫描
- (void)stopScan;

/// 连接智慧笔，连接后同步数据后默认会删除笔内已同步数据，无需应用层确认
/// @param model 要连接的笔信息
- (void)connect:(BPenModel *)model;

/// 连接智慧笔，并指定连接方式，不同方式会产生不同的数据同步策略等
/// @param model 待连接的笔
/// @param connectType 其值的定义和行为详见BPenConnectType的枚举声明
- (void)connect:(BPenModel *)model connectType:(BPenConnectType)connectType;

/// 开始同步离线数据 。发送此命令后才开始同步离线数据，该功能需要特定固件系列支持，如固件不支持则调用后无效果仍按默认的笔空闲时开始传离线数据。
- (void)startSynchronizationBatchDatas;

/// 应用层删除笔内的离线数据 （无论是否同步，直接丢弃这些数据）
- (void)cleanBatchDataInPen;

/// 断开连接
- (void)disconnect;

/// 切换实时，非实时同步数据模式
/// @param model 模式枚举：实时，非实时
- (void)switchSynchronizationModel:(SynchronizationMode)model;

/// 通知智慧笔闪一闪（闪灯）
- (void)notifyFlashLight;

///设置智慧笔休眠（休眠等同于笔盖上笔帽）时间,固件版本号需要512及以上 （笔固件低于该版本调用此方法无效）
///默认笔的休眠时间是10分钟 ，即笔在不使用后10分钟会休眠，休眠灯会熄灭（等同于盖上笔帽），应用层接收到笔断开的回调， 这时候如果用笔书写，会自动激活，如shouldAutoRecoveryConnect为true会自动连接，如其为false则会有发现笔的回调
/// @param timeSpace  时间单位分 ，最大可以设置成255分钟，最小1分钟，超出这个限制直接按上下限处理
//设置后笔上的灯会绿色煽动几次 然后变为之前的蓝色，在连接的笔的情况下，该方法必然成功。应用层自行记录设置好的休眠时间。每次调用下面的方法设置会覆盖之前的值
- (void)setPenSleepTime:(int) timeSpace;

///设置智慧笔的传感器的曝光时间,默认4，设置的值越大则能耗越高采样率越高对反着握笔识别提升，达到14后笔反着（通常习惯笔镜头朝向内侧，反着写即笔沿自身中轴转180度镜头面超外侧）写也有较高采样效果；
///一般不建议设置太大，如无必要建议不要设置此项
///设置完后生效，若笔重启则会恢复默认配置
/// @param timeSpace  曝光时间
- (void)setExposureTime:(int) timeSpace;

///要求笔报告当前未同步的离线数据量，调用后当笔返回相关信息时，sdk会对外回调delegate的unSynchronizationDataPercentToPenDisk报告离线数据占笔内存储的百分比
- (void)askPenToUpdateUnSynchronizationDataPercentToPenDisk;

///在笔传输批量数据时，在notifyBatchPointData中接收完一个批次的数据时调用此方法应答笔才会同步下一个批次的批量数据；仅当shouldAutoReplyWhenSynchronizeData为false时调用此方法才有效，否则不做操作由sdk自身自动应答
- (void)replyForBatchDataReceived;

/// 是否要求笔报告摄像头遮挡的情况 默认不报告，且重连后会重置为默认不报告；若要一直报告请在连接后调用此方法
///  此功能要求笔的固件支持，若应用层的功能场景需要报告摄像头是否被不正确握笔姿势遮挡，请在采购笔时就确认笔的固件支持此功能。若固件不支持此功能则，向笔发送是否报告命令将无任何效果。
/// @param shouldReport 是否报告 默认不报告
- (void)setShouldReportCameraCoveredState:(BOOL)shouldReport;

/// 设置书写时是否开启书写时改变笔上的指示灯颜色，默认不开启；若需开启，在笔连接后调用此方法开启；本功能B8系列需要固件23即以上的版本支持；若硬件类型或者固件版本不支持，则此命令无效
/// @param enableWritingLight 为true则开启书写时改变笔上的指示灯颜色
- (void)setEnableWritingLight:(BOOL)enableWritingLight;


/// 设置实时模式每帧点数，每帧点数越多，则收到的点的时间间隔越长；越小则越频繁，收到的点约及时，但可能造成拥堵而丢实时点；在笔连接后调用此方法开启，本功能B8系列需要固件23即以上的版本支持，若硬件类型或者固件版本不支持，则此命令无效
/// @param maxPointsCountEachFrame 每帧实时数据最大的所点数，可选范围1～9
- (void)setRealtimeMaxOutPointsCountEachFrame:(int)maxPointsCountEachFrame;

/*======Begin  以下三个方法为sdk提供的调试用的方法（开发调试用，不建议作为正式产品功能使用）======*/
/// SDK开始记录原始数据到指定二进制流文件，文件名无需后缀
/// @param path 原始数据写入的文件的路径。若该路径下文件不存在，则创建文件；若文件不可写入，则完成回调返回相关error；如果文件已有内容，后续写入的内容会在当前文件内容后面拼接写入，所以建议传入的文件为空或者不存在，若非空文件建议用sdk写入过内容的文件，其他情况不能保证当前文件已有内容是按照sdk要求的格式写入内容的，这种情况下可能在读取文件时产生错误的数据。
/// @param handel 完成回调，若成功开始写入，则返回true，error为空；若失败则返回相关error
- (void)beginSaveRawDataToFile:(NSString *)path completedHandel:(void (^) (bool,NSError*_Nullable))handel;

/// SDK结束记录原始数据到指定文件。注意：在结束写文件后才可以读取原始数据，同时写和读原始数据可能会冲突
/// @param handel 完成回调，若成功结束写入，则返回true，error为空；若失败则返回相关error
- (void)endSaveRawDataWithCompletedHandel:(void (^) (bool,NSError*_Nullable))handel;

/// 读取指定文件中的原始数据，注意：请在结束写文件后再读取原始数据，同时写和读原始数据可能会冲突
/// @param path 指定原始数据文件的路径
/// @param delegate 读取原始数据后的数据回调
/// @param handel 读取操作的完成回调，若成功读取，则返回true，error为空；若失败则返回相关error
- (void)readRawDataFromFile:(NSString *)path dataDelegate:(id<BPenRawDataDelegate>)delegate completedHandel:(void (^) (bool,NSError*_Nullable))handel;
/*======End  上面三个方法为sdk提供的调试用的方法（调试用，不建议作为正式产品功能使用）======*/
@end

NS_ASSUME_NONNULL_END
