//
//  MyCanvasView.h
//  BPenDemo
//
//  Created by xingfa on 2020/12/24.
//  Copyright © 2020 bbb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BPenPlusSDK/BPenPlusSDK.h>
#import "MyCanvas.h"

NS_ASSUME_NONNULL_BEGIN
@interface CanvasBackImage : NSObject
@property (nonatomic,strong) UIImage *image;
@property (nonatomic,assign) CGFloat dpi;
@property (nonatomic,readonly) CGSize physicSize; //底图的物理尺寸 单位毫米 mm
@end

@interface MyCanvasView : UIView<BPCanvasRenderDelegate>
@end

NS_ASSUME_NONNULL_END
