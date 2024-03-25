//
//  BPPenCell.m
//  BPenDemoOC
//
//  Created by Xingfa Zhou on 2023/3/18.
//  Copyright © 2023 bbb. All rights reserved.
//

#import "BPPenCell.h"


@interface BPPenCell()
@property (weak, nonatomic) IBOutlet UILabel* nameLabel;
@property (weak, nonatomic) IBOutlet UILabel* macLabel;
@property (weak, nonatomic) IBOutlet UIButton* connectButton;
@property (weak, nonatomic) IBOutlet UILabel* powerInforLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl* penSyncDataModeSegement;
@property (weak, nonatomic) IBOutlet UIButton* flashButton;
@property (weak, nonatomic) IBOutlet UILabel* fireworkLabel;
@property (weak, nonatomic) IBOutlet UIButton* fireworkCheckButton;
@property (weak, nonatomic) IBOutlet UIButton* fireworkOTAButton;
@property (weak, nonatomic) IBOutlet UILabel* unSyncDataPercentInforLabel;
@property (weak, nonatomic) IBOutlet UIButton* updateUNSyncDataPercentButton;
@property (weak, nonatomic) IBOutlet UIButton* sleepTimeSetButton;

@property (weak, nonatomic) IBOutlet UIView* backBgView;
@property (weak, nonatomic) IBOutlet UIStackView* stateStack1;
@property (weak, nonatomic) IBOutlet UIStackView* stateStack2;
@property (weak, nonatomic) IBOutlet UIStackView* stateStack3;
@property (weak, nonatomic) IBOutlet UIStackView* stateStack4;

@property (weak, nonatomic) IBOutlet UIButton* startSyncButton;
@property (weak, nonatomic) IBOutlet UIButton* clearFlashDataButton;


@property (strong, nonatomic) BPenModel* pen;
@end

@implementation BPPenCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) configWithPen:(BPenModel*) pen {
    self.pen = pen;
    [self adjustUIForPen:pen];
}

-(void)adjustUIForPen:(BPenModel*) pen {
    self.nameLabel.text = [NSString stringWithFormat:@"name:%@",pen.name];//"name:\(pen.name)"
    self.macLabel.text = [NSString stringWithFormat:@"mac:%@",pen.mac];//"mac:\(pen.mac)"
    if (pen.isConnect) {
        [self.connectButton setTitle:@"断开连接" forState:UIControlStateNormal];
        self.stateStack1.hidden = false;
        self.stateStack2.hidden = false;
        self.stateStack3.hidden = false;
        self.stateStack4.hidden = false;
        self.penSyncDataModeSegement.selectedSegmentIndex = pen.dataSyncMode;
        self.fireworkOTAButton.enabled = pen.canUpdateFirmware;
        self.fireworkLabel.text = [NSString stringWithFormat:@"固件版本:%@",pen.firmwareVersion];//"固件版本:\(pen.firmwareVersion ?? "-")"
        self.fireworkCheckButton.enabled = pen.firmwareVersion.length > 0;// !(pen.firmwareVersion.isEmpty ?? true)
        self.powerInforLabel.text = [NSString stringWithFormat:@"电量:%ld%%",(long)pen.powerPercent];//"电量:\(pen.powerPercent)%"
        self.unSyncDataPercentInforLabel.text = [NSString stringWithFormat:@"已用笔内空间:%ld%%",(long)pen.diskUsedPercent];//"未同步数据占比:\(pen.diskUsedPercent)%"
         
    } else {
       
        [self.connectButton setTitle:pen.isInDFU ? @"更新固件": @"连接设备" forState:UIControlStateNormal];
        self.stateStack1.hidden = true;
        self.stateStack2.hidden = true;
        self.stateStack3.hidden = true;
        self.stateStack4.hidden = true;
    }
}

- (IBAction)connectButtonTouched:(id) sender  {
    if(self.connectOrDisConnectHandel) {
        self.connectOrDisConnectHandel(self.pen);
    }
}

- (IBAction)swithSyncDataModeSegementValueChanged:(id) sender{
    if(self.penSyncDataModeChangeHandel) {
        self.penSyncDataModeChangeHandel(self.pen);
    }
}

- (IBAction)flashButtonTouched:(id) sender{
    if(self.penFlashHandel) {
        self.penFlashHandel(self.pen);
    }
}

- (IBAction)firewareVersionCheckButtonTouched:(id) sender{
    if(self.fireworkCheckHandel) {
        self.fireworkCheckHandel(self.pen);
    }
}


- (IBAction)otaButtonTouched:(id) sender{
    if(self.fireworkOTAHandel) {
        self.fireworkOTAHandel(self.pen);
    }
}

- (IBAction)updateUnSyncDataPercentButtonTouched:(id) sender{
    if(self.updateUnSyncDataPercentHandel) {
        self.updateUnSyncDataPercentHandel(self.pen);
    }
}

- (IBAction)sleeptimeSetButtonTouched:(id) sender{
    if(self.sleepTimeSetHandel) {
        self.sleepTimeSetHandel(self.pen);
    }
}

- (IBAction)startSyncButtonTouched:(id) sender{
    if(self.startSyncHandel) {
        self.startSyncHandel(self.pen);
    }
}

- (IBAction)clearFlashDataButtonTouched:(id) sender{
    if(self.clearFlashDataniuHandel) {
        self.clearFlashDataniuHandel(self.pen);
    }
}
@end
