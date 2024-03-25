//
//  ViewController.m
//  BPenDemo
//
//  Created by HFY on 2020/6/17.
//  Copyright © 2020 bbb. All rights reserved.
//

#import "ViewController.h"
#import "MyPenManager.h"
#import "DrawViewController.h"
#import "BPPenCell.h"
#import "UIViewController+ShowToast.h"


@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,BPenManagerDelegate,BPenManagerDrawDelegate,BPenRawDataDelegate>

@property (nonatomic, strong) DrawViewController *drawViewController;
@property (nonatomic, strong) NSMutableArray<BPenModel *> *penArray;
@property (weak, nonatomic) IBOutlet UIButton *scanButton;
@property (weak, nonatomic) IBOutlet UITableView* tableView;

@property (weak, nonatomic) IBOutlet UISwitch *autoReplayReceivedDataSwtich;
@property (weak, nonatomic) IBOutlet UISwitch *autoReconnectSwtich;
@property (weak, nonatomic) IBOutlet UIButton *batchDataReceivedUserReplayButton;

@property (weak, nonatomic) IBOutlet UISwitch *strokeEndPointsFilterSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *wrongPageFilterSwtich;


@property (weak, nonatomic) IBOutlet UIButton* drawButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView* scanIndicator;

@property (weak, nonatomic) IBOutlet UIButton *rawDataActionButton;
@property (weak, nonatomic) IBOutlet UIButton *readRawDataButton;

@property (weak, nonatomic) IBOutlet UIStackView *batchDataPackageConfirmStack;

@property (weak, nonatomic) IBOutlet UILabel *batchDataAutoSyncLabel;

@property (weak, nonatomic) IBOutlet UISwitch *batchDataAutoSyncSwtich;

@property (weak, nonatomic) IBOutlet UISwitch *enableWritinglightSwitch;

@property (weak, nonatomic) IBOutlet UISegmentedControl *realtimeFramePointCountMaxSegements;
@property (weak, nonatomic) IBOutlet UIStackView *realtimeFramePointCountMaxStack;

@property (strong,nonatomic) BPenModel *currentConnectPen;

@property (nonatomic, assign) BOOL isSavingRawData;


@property(nonatomic,readonly) BPenConnectType connectType;
@end

@implementation ViewController

- (BPenConnectType)connectType {
    if (!self.batchDataAutoSyncSwtich.isOn) {
        return BPenConnectTypeBatchDataAutoSyncClose;
    }
    return BPenConnectTypeDefault;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
  //  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"BPPenCell" bundle:nil] forCellReuseIdentifier:kBPPenCellReuseIdentifier];
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.batchDataPackageConfirmStack setHidden:true];
    
    [self.batchDataAutoSyncSwtich setOn:true];
    
    [MyPenManager sharedInstance].delegate = self;
    [MyPenManager sharedInstance].drawDelegate = self;
    
    [MyPenManager sharedInstance].smoothLevel = BPenSmoothLevelNone ;
    // 开启勾笔消除设置
    [MyPenManager sharedInstance].shouldFilterPointsNearStrokeEnd = true;
    self.strokeEndPointsFilterSwitch.on = [MyPenManager sharedInstance].shouldFilterPointsNearStrokeEnd ;
    
    
    self.wrongPageFilterSwtich.on =  [MyPenManager sharedInstance].shouldFilterLessAndFastPageChangedPoints;
    
//    [self.synchronizationModeSeg setTitle:@"实时绘制" forSegmentAtIndex:0];
//    [self.synchronizationModeSeg setTitle:@"批量绘制" forSegmentAtIndex:1];
    
    self.scanButton.layer.borderWidth = 1.0;
    self.scanButton.layer.borderColor = self.view.tintColor.CGColor ;
    self.scanButton.layer.cornerRadius = 3 ;
    
    [self adjustScanButton];
    //[self adjustShowingInforForConnectPen];
}

- (DrawViewController *)drawViewController {
    if (!_drawViewController) {
        _drawViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DrawViewController"];//[[DrawViewController alloc] initWithFrame:self.view.bounds];
        _drawViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    return _drawViewController;
}

- (NSMutableArray<BPenModel *> *)penArray {
    if (!_penArray) {
        _penArray = [[NSMutableArray alloc] init];
    }
    return _penArray;
}

- (void)disconnectAction {
    [[MyPenManager sharedInstance] disconnect];
}
 
- (void)canBeUse {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.drawViewController.presentingViewController != nil) {
            return;
        }
        
        [self presentViewController:self.drawViewController animated:YES completion:nil];
    });
}

- (void)adjustScanButton {
    BOOL isScanning = [[MyPenManager sharedInstance] isScanning];
    NSString *title = isScanning ? @"结束扫描" : @"扫描棒棒笔" ;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.scanButton setTitle:title forState:UIControlStateNormal];
        if (isScanning) {
            [self.scanIndicator setHidden:NO];
            [self.scanIndicator startAnimating];
        } else {
            [self.scanIndicator setHidden:YES];
            [self.scanIndicator stopAnimating];
        }
    });
}

- (void)adjustRawDataButtonState {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *title = self->_isSavingRawData ? @"结束存" : @"开始存" ;
        [self.rawDataActionButton setTitle:title forState:UIControlStateNormal];
    });
}

- (void)setIsSavingRawData:(BOOL)isSavingRawData {
    if(_isSavingRawData != isSavingRawData) {
        _isSavingRawData = isSavingRawData;
        [self adjustRawDataButtonState];
    }
}

-(NSString *) rawDataPathWithFileName:(NSString *)name {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject;
    return [path stringByAppendingPathComponent:name];
}

- (IBAction)beginToSaveRawDataToFile:(id)sender {
    __weak typeof(self) weakSelf = self;
    if(!self.isSavingRawData) {
        self.isSavingRawData = true ;
        [[MyPenManager sharedInstance] beginSaveRawDataToFile:[self rawDataPathWithFileName:@"test"] completedHandel:^(bool successed, NSError * _Nullable error) {
            weakSelf.isSavingRawData = successed;
            if(error) {
                [weakSelf showMessageWithTitle:@"开启原始数据记录失败" msg:error.localizedFailureReason disapperAfterDelay:2.0];
            }
        }];
    } else {
        self.isSavingRawData = false ;
        [[MyPenManager sharedInstance] endSaveRawDataWithCompletedHandel:^(bool successed, NSError * _Nullable error) {
            if(error) {
                weakSelf.isSavingRawData = true ;
                [weakSelf showMessageWithTitle:@"结束原始数据记录失败" msg:error.localizedFailureReason disapperAfterDelay:2.0];
            }
        }];
    }
}

- (IBAction)readRawDataFromFile:(UIButton *)sender {
    NSString* path =  [self rawDataPathWithFileName:@"test"];
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:path]) {
        path = [[NSBundle mainBundle]  pathForResource:@"dots6" ofType:nil];//path(forResource: "store_2022-12-16_101131", ofType: nil)!
    }
    
//    NSString* textPath = [self rawDataPathWithFileName:@"rawData.txt"];
//    if (![manager fileExistsAtPath:textPath]) {
//         [manager createFileAtPath:textPath contents:nil attributes:nil];
//    }
    
//    [BPRawDataHelper readRawDataFromFile:path andExportToTxtFile:textPath completedHandel:^(bool finished, NSError * _Nullable error) {
//        if(error) {
//            NSLog(@"error:%@ %s %d",[error localizedDescription],__FUNCTION__,__LINE__);
//        } else {
//            NSLog(@"\n\n\n\n\n readRawDataFromFile andExportToTxtFile finished!\n\n\n\n\n\n");
//        }
//    }];
    
    
    [[MyPenManager sharedInstance] readRawDataFromFile:path dataDelegate:self completedHandel:^(bool finished, NSError * _Nullable error) {
        if(error) {
            NSLog(@"error:%@ %s %d",[error localizedDescription],__FUNCTION__,__LINE__);
        }
    }];
    
}

- (void)setSleepTimeForPen:(BPenModel *)pen {
         UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"设置笔休眠时间" message:@"笔休眠时间可以设置为1 - 255分钟，超出范围将分别取上下限" preferredStyle:UIAlertControllerStyleAlert];
         
         [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
             textField.keyboardType = UIKeyboardTypeDecimalPad;
             textField.placeholder = @"请输入1至255之间的数字";
         }];
         
         UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
             NSString *minutesString = alert.textFields.firstObject.text;
             NSInteger minutes = [minutesString integerValue];
             if (minutes >= 1 && minutes <= 255) {
                 [[MyPenManager sharedInstance] setPenSleepTime:(int)minutes];
             }
         }];
         
         [alert addAction:okAction];
         [self presentViewController:alert animated:YES completion:nil];
}

- (void)otaWithPenNow:(BPenModel *)pen fromLocal:(BOOL)fromLocal {
    // 如果没有自行管理笔的固件，请保证调用本方法时fromLocal传false ，传true的前提是你能拿到正确版本的固件文件且已下到本地
    if (fromLocal) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Ubtech_V24.0.0" ofType:@"zip"];
        [[MyPenManager sharedInstance] otaWithPen:pen loadFirmwareFromFile:path prepareHandel:^(BOOL start, BOOL finished) {
            //固件升级准备中
            if (start) {
                NSString *title = @"正在准备升级";
                NSString *progress = @"固件升级准备中";
                [self showProgressWith:title progressMsg:progress];
            } else if (finished) {
                [self hideAllHud];
            }
        } otaProgressHandel:^(int percent) {
            //固件升级进度
            NSString *title = [NSString stringWithFormat:@"固件升级进度:%ld%%", (long)percent];
            NSString *progress = @"正在升级固件，请勿关闭笔电源，也不要退出App;若升级失败，请重新连接笔并检查更新";
            [self showProgressWith:title progressMsg:progress];
        } completedHandel:^(BOOL finished, NSError * _Nullable error) {
            //固件升级结果回调
            [self hideAllHud];
            //升级完成
            if (finished) {
                NSString *title = @"固件升级完成";
                NSString *progress = @"稍后笔会重启，并自动连接";
                [self showMessageWithTitle:title msg:progress disapperAfterDelay:5];
            } else {
                [self showMessageWithTitle:@"固件失败" msg: error.localizedDescription.length > 0 ? error.localizedDescription: @"未知错误" disapperAfterDelay:2];
            }
        }];
    } else {
        //MARK: 13.2 固件更新
        [[MyPenManager sharedInstance] otaWithPen:pen loadFirmwareProgress:^(int percent) {
            //固件下载进度
            NSString *title = @"正在加载固件";
            NSString *progress = [NSString stringWithFormat:@"固件加载进度:%ld%%", (long)percent];
            [self showProgressWith:title progressMsg:progress];
        } prepareHandel:^(BOOL start, BOOL finished) {
            //固件升级准备中
            if (start) {
                NSString *title = @"正在准备升级";
                NSString *progress = @"固件升级准备中";
                [self showProgressWith:title progressMsg:progress];
            } else if (finished) {
                [self hideAllHud];
            }
        } otaProgressHandel:^(int percent) {
            //固件升级进度
            NSString *title = [NSString stringWithFormat:@"固件升级进度:%ld%%", (long)percent];
            NSString *progress = @"正在升级固件，请勿关闭笔电源，也不要退出App;若升级失败，请重新连接笔并检查更新";
            [self showProgressWith:title progressMsg:progress];
        } completedHandel:^(BOOL finished, NSError * _Nullable error) {
            //固件升级结果回调
            [self hideAllHud];
            //升级完成
            if (finished) {
                NSString *title = @"固件升级完成";
                NSString *progress = @"稍后笔会重启，并自动连接";
                [self showMessageWithTitle:title msg:progress disapperAfterDelay:5];
            } else {
                [self showMessageWithTitle:@"固件失败" msg: error.localizedDescription.length > 0 ? error.localizedDescription: @"未知错误" disapperAfterDelay:2];
            }
        }];
        
    }
}

-(void)sendConfigToPen:(BPenModel *)pen {
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 0);
        
        dispatch_after(time, dispatch_get_main_queue(), ^{
            [[MyPenManager sharedInstance] setEnableWritingLight:self.enableWritinglightSwitch.on];
        });
    
    // 延迟100毫秒后设置另外一项
    dispatch_after(dispatch_time(time, 200 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
        [[MyPenManager sharedInstance] setRealtimeMaxOutPointsCountEachFrame:(int)(self.realtimeFramePointCountMaxSegements.selectedSegmentIndex + 1)];
    });

      
    //若要继续发其他命令 建议在time的基础上再延个几百毫秒，以保证上一个蓝牙命令通讯完成
}

#pragma mark: == 回调方法 Action
- (IBAction)batchDataAutoSyncSwitchValueChanged:(id)sender {
    NSString* msg = @"";
    if (self.batchDataAutoSyncSwtich.isOn) {
        msg = @"已切换连接方式为：连接后自动同步笔内flash上的数据.";
    } else {
        
        msg = @"已切换连接方式为：连接后不自动同步，需要应用层手动同步笔内flash上的数据.目前B8系列固件版本20及以上支持此行为";
    }
    msg = [msg stringByAppendingString:@"\n下次连接笔时生效"];
    [self showMessageWithTitle:@"连接后离线数据同步方式已更改" msg:msg disapperAfterDelay:3];
}


- (IBAction)strokeEndPointsFilterSwitchOn:(id)sender {
    [MyPenManager sharedInstance].shouldFilterPointsNearStrokeEnd  =  self.strokeEndPointsFilterSwitch.on;
}

- (IBAction)wrongPageFilterSwtichOn:(id)sender {
    [MyPenManager sharedInstance].shouldFilterLessAndFastPageChangedPoints  =  self.wrongPageFilterSwtich.on;
}

- (IBAction)scanButtonTouched:(id)sender {
    if ([MyPenManager sharedInstance].isScanning) {
        [[MyPenManager sharedInstance] stopScan];
    } else {
        [self.penArray removeAllObjects];
        [self.tableView reloadData];
        
//        //启动扫描
        [[MyPenManager sharedInstance] startScan];
    }
}

- (IBAction)autoReconnectPenBySDK:(id)sender {
    [[MyPenManager sharedInstance] setShouldAutoRecoveryConnect:self.autoReconnectSwtich.isOn];
    [MyPenManager sharedInstance].smoothLevel = self.autoReconnectSwtich.isOn ? BPenSmoothLevelAdvantage : BPenSmoothLevelBase ;
}

//MARK: 9 .关闭sdk自动应答批量数据接收 ，若关闭则需应用层应答
//应用层开启自动应答或关闭自动应答示例
- (IBAction)batchDataRecivedReplaySwtichChanged:(id)sender {
    //开启SDK自动应答，则无需客服端应答
    [[MyPenManager sharedInstance] setShouldAutoReplyWhenSynchronizeData:self.autoReplayReceivedDataSwtich.isOn];
}

- (IBAction)drawButtonTouched:(id)sender {
    [self canBeUse];
}

#pragma mark: == 回调方法 BPenManagerDelegate
- (void)notifyContinueToUseFail {
    NSLog(@"%s,%d",__func__,__LINE__);
    [self  reloadPenList];
}

- (void)notifyContinueToUseSuccess {
    NSLog(@"%s,%d",__func__,__LINE__);
    [self sendConfigToPen:self.currentConnectPen];
    [self  reloadPenList];
    [self canBeUse];
}

- (void)didDisconnect:(BPenModel *)model error:(NSError *)error {
    //断开连接
    NSLog(@"%s,%d %@",__func__,__LINE__,error);
    self.currentConnectPen = nil;
    [self  reloadPenList];
}

- (void)didDiscoverWithPen:(BPenModel *)model {
    NSLog(@"%s,%d",__func__,__LINE__);
    if (![self.penArray containsObject:model]) {
        [self.penArray addObject:model];
    }
    
    [self  reloadPenList];
}

- (void)notifyBattery:(NSInteger)battery {
    NSLog(@"%s,%d %ld",__func__,__LINE__, (long)battery);
    [self  reloadPenList];
}

- (void)didConnectFail:(NSError *)error {
    NSLog(@"%s,%d %@",__func__,__LINE__,error);
    [self  reloadPenList];
}

- (void)didConnectSuccess {
   // [self adjustShowingInforForConnectPen];
    [self adjustScanButton];
    [self  reloadPenList];
}

- (void)notifyBluetoothUnauthorized {
    NSLog(@"%s,%d 智慧笔连接App需要蓝牙，提示用户授权此App使用蓝牙",__func__,__LINE__);
}

- (void)notifyBluetoothPoweredOff {
    NSLog(@"%s,%d 手机未打开蓝牙，提示用户授权此App使用蓝牙 ",__func__,__LINE__);
}

- (void)notifyBluetoothUnsupported {
    NSLog(@"%s,%d 该设备不支持蓝牙 报错信息给用户",__func__,__LINE__);
}

- (void)notifyDataSynchronizationMode:(SynchronizationMode)mode {
    NSLog(@"%s,%d",__func__,__LINE__);
    NSLog(@"DataSynchronizationMode:%ld",(long)mode);
    [self  reloadPenList];
}

- (void)notifyFirmwareVersion:(NSString *)currentVersion {
    NSLog(@"%s,%d",__func__,__LINE__);
    [self  reloadPenList];
}

- (void)notifyVerifyPhoneNumber:(NSString *)endOfTheNumber {
    NSLog(@"基于数据和设备安全，此智能笔已绑定尾号为:%@ 的手机号。本App暂不支持绑定手机号，请联系该手机号的机主解除手机号与笔的绑定，之后才可以在此App中使用",endOfTheNumber);
}

- (void)synchronizationDataDidCompleted {
    NSLog(@"笔内离线数据已发送完毕,%s,%d",__func__,__LINE__);
}

- (void)unSynchronizationDataPercentToPenDisk:(float)percent {
    NSLog(@"笔内数据已占空间：%f,%s,%d",percent,__func__,__LINE__);
}

- (void)didStartScan {
    [self adjustScanButton];
}


- (void)didStopScan {
    [self adjustScanButton];
}


#pragma mark == 代理方法 BPenManagerDrawDelegate
- (void)notifyRealTimePointData:(NSArray<BPPoint *> *)pointDrawArray {
    NSLog(@"%s,%d pointsCount：%lu",__func__,__LINE__,pointDrawArray.count);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.drawViewController realTimeDrawing:pointDrawArray];
    });
}

- (void)notifyBatchPointData:(NSArray<BPPoint *> *)pointDrawArray {
    NSLog(@"%s,%d",__func__,__LINE__);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.drawViewController batchDrawing:pointDrawArray];
    });
}

- (void)notifyOfflineBatchPointData:(NSArray<BPPoint *> * _Nonnull)pointDrawArray remainPackages:(NSInteger)remainPackages {
    NSLog(@"%s,%d 剩余包数：%ld",__func__,__LINE__,(long)remainPackages);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.drawViewController batchDrawing:pointDrawArray];
    });
}

- (void)notifyWrittingBatchPointData:(NSArray<BPPoint *> * _Nonnull)pointDrawArray {
    NSLog(@"%s,%d pointsCount：%lu",__func__,__LINE__,(unsigned long)pointDrawArray.count);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.drawViewController batchDrawing:pointDrawArray];
    });
}

#pragma mark == 代理方法 BPenRawDataDelegate
- (void)batchDataFromPen:(NSString * _Nonnull)penMac points:(NSArray<BPPoint *> * _Nonnull)points {
    [self canBeUse];
    NSLog(@"%s,%d",__func__,__LINE__);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.drawViewController batchDrawing:points];
    });
}

- (void)realtimeDataFromPen:(NSString * _Nonnull)penMac points:(NSArray<BPPoint *> * _Nonnull)points {
    [self canBeUse];
    NSLog(@"realtimeData%@，%s,%d",points,__func__,__LINE__);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.drawViewController realTimeDrawing:points];
    });
}

#pragma mark == 代理方法 UITableViewDelegate,UITableViewDataSource
- (void)reloadPenList {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.penArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BPenModel* pen = self.penArray[indexPath.row];
    return pen.isConnect ? 180 : 54 ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BPPenCell *cell = [tableView dequeueReusableCellWithIdentifier:kBPPenCellReuseIdentifier forIndexPath:indexPath];
    
    BPenModel *pen = self.penArray[indexPath.row];
    [cell configWithPen:pen];
    
    __weak typeof(self) weakSelf = self ;
    cell.connectOrDisConnectHandel = ^(BPenModel * _Nonnull pen) {
        if (pen.isInDFU) {
              [self showAlertWithTitle:@"笔处于恢复模式" message:@"笔处于恢复模式，需要升级到最新版" confirmAction:[UIAlertAction actionWithTitle:@"更新固件" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                   [self otaWithPenNow:pen fromLocal:YES];
              }] cancelAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil] otherActions:@[] preferredStyle:UIAlertControllerStyleAlert presentCompleted:^{
                   
              }];
        } else {
            if(pen.isConnect) {
                [[MyPenManager sharedInstance] disconnect];
            } else {
                self.currentConnectPen = pen;
                [[MyPenManager sharedInstance] connect:pen connectType:self.connectType];
            }
        }
    };
    
    cell.penFlashHandel = ^(BPenModel * _Nonnull pen) {
        [[MyPenManager sharedInstance] notifyFlashLight];
    };
    
    cell.penSyncDataModeChangeHandel = ^(BPenModel * _Nonnull pen) {
        [[MyPenManager sharedInstance] switchSynchronizationModel:pen.dataSyncMode == RealTime ? BatchPointData : RealTime];
    };
    
    cell.updateUnSyncDataPercentHandel = ^(BPenModel * _Nonnull pen) {
        [[MyPenManager sharedInstance] askPenToUpdateUnSynchronizationDataPercentToPenDisk];
    };
    
    cell.sleepTimeSetHandel = ^(BPenModel * _Nonnull pen) {
        [weakSelf setSleepTimeForPen:pen];
    };
    
    cell.fireworkCheckHandel = ^(BPenModel * _Nonnull pen) {
        [[MyPenManager sharedInstance] checkNewFirmwareVersionWithHandel:^(NSString * _Nullable newVersion, NSError * _Nullable error) {
            if(newVersion.length > 0) {
                [weakSelf  reloadPenList];
            } else {
                
            }
        }];
    };
    
    
    cell.fireworkOTAHandel = ^(BPenModel * _Nonnull pen) {
        //如果是false 就是用本地的固件问题，true为在线版本
        [weakSelf otaWithPenNow:pen fromLocal:false];
    };
    
    cell.startSyncHandel = ^(BPenModel * _Nonnull pen) {
        [[MyPenManager sharedInstance] startSynchronizationBatchDatas];
    };
    
    cell.clearFlashDataniuHandel = ^(BPenModel * _Nonnull pen) {
        [[MyPenManager sharedInstance] cleanBatchDataInPen];
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BPenModel *model = self.penArray[indexPath.row];
    MyPenManager *manager = [MyPenManager sharedInstance];
    if (manager.currentConnectPen != model) {
        if (manager.currentConnectPen != nil) {
            [manager disconnect];
        }
        [manager connect:model];
    }
    
    [self canBeUse];
}
@end
 
