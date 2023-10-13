//
//  BPPoint.h
//  BPenSDK
//
//  Created by xingfa on 2021/1/12.
//  Copyright © 2021 bbb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BPaperTypeHelper.h"

NS_ASSUME_NONNULL_BEGIN
@class BPaperTypeHelper;

/// 笔返回的坐标点,渲染时请自行将基于物理长度的x,y（单位为毫米）转化为视图基于像素的坐标点
///
/// 笔返回的笔迹点，包含如下字段：纸张类型，纸张上铺码的pageid，笔迹点在纸面内的坐标x,y；笔迹经过该点时的相对线宽width（0~1），笔迹起始结束标志；时间戳（笔返回的同一批次的点会共用一个时间戳）
@interface BPPoint : NSObject

/// 笔识别的铺码码段的纸张尺寸类型
///
/// paperType和pageId一起唯一标识当前点所在的那页。书页上铺码后，某页page就可以而且必须用papertype和pageId一起标识，如papertype 0 pageId 1000页就可以确定是纸张尺寸类型0（A4P）码段下的pageId为1000的页，可以用0_1000来标识这一页
///paperType通过BPaperTypeHelper可以获取该纸张类型所支持的最大铺码纸张尺寸maxContentSizeInMMForPaperType ，但当前page的物理尺寸必定小于或等于此值，page的实际物理尺寸取决于铺码时的原pdf文档的大小和周围出血线的情况，无法从笔返回的点数据中获取，请从自己的业务系统中设置或获取
@property (nonatomic, assign) BPaperType paperType;

/// 纸张上铺码的pageid，某本书铺码后所用的纸张尺寸类型和pageid段详见铺码后的文件名和铺码结果，请自行记录到业务系统中。通常一本书铺码所用的pageid段是连续的 故而当前书的每一页均可通过pageid组合papertype来唯一确定
///  笔收到的pageId 减去 书的第一页的pageId 即为书当前页的页码；
@property (nonatomic, assign) unsigned long long pageId;

/// 单位毫米，纸张上相对于（有效铺码区域也即成品区域）左上角原点的横向距离
@property (nonatomic, readonly) float x;

///单位毫米，纸张上相对于（有效铺码区域也即成品区域）左上角原点的纵向距离
@property (nonatomic, readonly) float y;

/// 当前笔迹点在纸张上铺码坐标系（成品区域左上角为原点）下的位置(x,y);
@property (nonatomic, readonly) CGPoint position;

///笔迹点处的线宽相对值 浮点数取值范围0~1，相对值；界面绘制时线宽像素宽度请自行结合dpi乘以恰当系数变为绝对值
@property (nonatomic, readonly) float width;

/// 是否为笔画的开始
/// 落笔点，通常是笔划的第一个点，可用之分割点序列为笔划；为true则意味着上一笔结束，新的一笔开始
@property (nonatomic, assign) BOOL strokeStart;

/// 抬笔事件，通常是笔画结束的标志
@property (nonatomic, assign) BOOL strokeEnd;

/// 是否是硬件拟合的点，true表明局部采样失败后由硬件基于算法生成的轨迹点；false表明是直接采样生成的实际点。实际点是可靠的，拟合点是特定加强型硬件笔才会根据局部点阵情况生成的，可以正常使用绘制，如对轨迹细节要求非常高，可以针对拟合点进行适当处理，否则无需区分处理实际点和拟合点
@property (nonatomic,readonly) BOOL isVirtual;

///该点书写的时间 自1970的秒数 精确到秒 精确到小数点后三位，即毫秒级
@property (nonatomic, assign) NSTimeInterval timeStamp;

///实时是该点书写的时间，非实时该点所在批量包的点共用一个时间戳
@property (nonatomic, readonly) NSDate* timeStampDate;
 
///  点的坐标信息和线宽信息所压缩成的原始字节流数据；相较于持久点的（x,y,width）时可以选择持久rawData,三个浮点型可能占据3个64位共24字节，而rawData只需6字节，适宜用文件的方式编码和解码点信息；
@property (nonatomic,readonly) NSData *rawData;

///基于原始数据rawData构造点对象； 基于原始字节编码和解码的好处参照rawData的说明
+ (instancetype)pointWithRawData:(NSData *)rawData paperType:(BPaperType)paperType pageId:(unsigned long long) pageId strokeStart:(BOOL) strokeStart strokeEnd:(BOOL)strokeEnd timeStamp:(NSTimeInterval) timeStamp;

///基于对应字段构造点对象
+ (instancetype)pointWithX:(float)x y:(float)y width:(float)width paperType:(BPaperType)paperType pageId:(unsigned long long) pageId strokeStart:(BOOL) strokeStart strokeEnd:(BOOL)strokeEnd timeStamp:(NSTimeInterval) timeStamp isVirtual:(BOOL)isVirtual;
@end

NS_ASSUME_NONNULL_END
