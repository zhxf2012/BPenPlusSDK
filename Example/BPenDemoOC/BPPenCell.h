//
//  BPPenCell.h
//  BPenDemoOC
//
//  Created by Xingfa Zhou on 2023/3/18.
//  Copyright © 2023 bbb. All rights reserved.
//

#import <UIKit/UIKit.h>
@import BPenPlusSDK;

NS_ASSUME_NONNULL_BEGIN

static NSString * kBPPenCellReuseIdentifier = @"kBPPenCellReuseIdentifier";

@interface BPPenCell : UITableViewCell
@property (copy, nonatomic) void (^connectOrDisConnectHandel)(BPenModel*);
@property (copy, nonatomic) void (^penSyncDataModeChangeHandel)(BPenModel*);
@property (copy, nonatomic) void (^penFlashHandel)(BPenModel*);
@property (copy, nonatomic) void (^fireworkCheckHandel)(BPenModel*);
@property (copy, nonatomic) void (^fireworkOTAHandel)(BPenModel*);
@property (copy, nonatomic) void (^updateUnSyncDataPercentHandel)(BPenModel*);
@property (copy, nonatomic) void (^sleepTimeSetHandel)(BPenModel*);
@property (copy, nonatomic) void (^startSyncHandel)(BPenModel*);
@property (copy, nonatomic) void (^clearFlashDataniuHandel)(BPenModel*);


- (void) configWithPen:(BPenModel*) pen;
@end

NS_ASSUME_NONNULL_END
