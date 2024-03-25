//
//  DrawViewController.m
//  BPenDemo
//
//  Created by HFY on 2020/6/22.
//  Copyright © 2020 bbb. All rights reserved.
//

#import "DrawViewController.h"
#import <BPenPlusSDK/BPenPlusSDK.h>
#import "MyCanvasView.h"
#import "BPPointsDAO.h"
#import "UIViewController+ShowToast.h"

#define SDKVIEW BPCanvasView2

@interface DrawViewController ()<UIScrollViewDelegate>
 

@property (nonatomic,strong) SDKVIEW *sdkCanvas;
@property (nonatomic,strong) MyCanvasView *customCanvas;
@property (nonatomic,assign) NSInteger selectCanvasType;

@property (weak, nonatomic) IBOutlet UISegmentedControl *strokeWidthSeg;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *randomStrokeColorButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *drawModeSeg;
//@property (weak, nonatomic) IBOutlet UISwitch *debugSwitch;

@property (weak, nonatomic) IBOutlet  UILabel* paperTypeLabel;
@property (weak, nonatomic) IBOutlet  UILabel* pageIdLabel;

@property (nonatomic,strong) UIColor *strokeColor;
@property (nonatomic,assign) int strokeWidth;

@property (nonatomic, strong) NSString *backImageName;

//@property (nonatomic,strong) NSMutableArray<BPPoint *> *allPoints;
@property (weak, nonatomic) IBOutlet UIButton *pageSwitchButton;
@property (nonatomic,strong) BPPointsDAO *dataManager;
@property (nonatomic,strong) BPSinglePage *currentPage;
@end

@implementation DrawViewController {
    
}

- (void)commonInit {
    _dataManager = [[BPPointsDAO alloc] init];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)setSelectCanvasType:(NSInteger)selectCanvasType {
    if (_selectCanvasType != selectCanvasType) {
        _selectCanvasType = selectCanvasType;
        CGRect newFrame = self.view.frame;
        if (@available(iOS 11.0, *)) {
            CGSize size = self.scrollView.safeAreaLayoutGuide.layoutFrame.size;
            newFrame = CGRectMake(0, 0, size.width, size.height);
        } else {
            // Fallback on earlier versions
        }
        if (selectCanvasType == 0) {
            [self.sdkCanvas removeFromSuperview];
            [self.scrollView addSubview:self.customCanvas];
            self.customCanvas.frame = newFrame;
        } else {
            [self.customCanvas removeFromSuperview];
            [self.scrollView addSubview:self.sdkCanvas];
            self.sdkCanvas.frame = newFrame;
        }
        self.scrollView.zoomScale = 1.0;
    }
    
}

- (void)dismissAction {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (SDKVIEW *)sdkCanvas {
    if (_sdkCanvas == nil) {
        _sdkCanvas = [[SDKVIEW alloc] initWithFrame:self.view.bounds];
        _sdkCanvas.backgroundColor = [UIColor clearColor];
    }
    return _sdkCanvas;
}

- (MyCanvasView *)customCanvas {
    if (_customCanvas == nil) {
        _customCanvas = [[MyCanvasView alloc] initWithFrame:self.view.bounds];
        _customCanvas.backgroundColor = [UIColor clearColor];
    }
    return  _customCanvas;
}

- (void)randomStrokeColorAction {
    NSInteger r = arc4random() % 255;
    NSInteger g = arc4random() % 255;
    NSInteger b = arc4random() % 255;
    UIColor *strokeColor = [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.0f];
   
    __block __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.randomStrokeColorButton setTitleColor: strokeColor forState:UIControlStateNormal];
    });
}
 
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
//    [self.scrollView addSubview:self.canvas];
    
    self.scrollView.delegate = self;
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale = 8 ;
    
    self.selectCanvasType = 1;
    self.strokeColor = [UIColor blueColor];
    self.strokeWidth = 1;
    
    [self.drawModeSeg setTitle:@"自定义绘制" forSegmentAtIndex:0];
    [self.drawModeSeg setTitle:@"SDK绘制" forSegmentAtIndex:1];
    
    [[self strokeWidths] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat value = [obj floatValue];
        [self.strokeWidthSeg setTitle:[NSString stringWithFormat:@"%0.1f", value] forSegmentAtIndex:idx];
    }];
    
    self.strokeWidthSeg.selectedSegmentIndex = 1;
    self.drawModeSeg.selectedSegmentIndex = 1;
}

- (void)setStrokeWithColor:(UIColor *)strokeColor {
    _strokeColor = strokeColor ;
//    self.sdkCanvas.strokeColor = strokeColor;
//    self.customCanvas.strokeColor = strokeColor;
}

- (void)setStrokeWithWidth:(CGFloat)width {
//    self.sdkCanvas.strokeWidthScale = width;
//    self.customCanvas.strokeWidthScale = width;
}

- (NSArray *)strokeWidths {
    return @[@(0.5),@(1),@(1.5),@(2.0),@(2.5)];
}

- (IBAction)closeButtonTouched:(id)sender {
    [self dismissAction];
}

- (IBAction)pageSwtichTouched:(id)sender {
    if(self.dataManager.allPages.count > 1) {
        NSMutableArray *items = [NSMutableArray array];
        for (NSUInteger i = 0; i < self.dataManager.allPages.count; i++) {
            BPSinglePage *page = self.dataManager.allPages[i];
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:page.indexKey style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self handelPointsDraw:true currentPage:page redrawPoints:page.allPoints];
            }];
            [items addObject:action];
            
        }
        
        [self showAlertWithTitle:@"多页数据" message:@"切换到" confirmAction:nil cancelAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil] otherActions:items preferredStyle:UIAlertControllerStyleAlert presentCompleted:^{
             
        }];
    }
}

- (IBAction)randomStrokeColorButtonTouched:(id)sender {
    [self randomStrokeColorAction];
}

- (IBAction)drawModeSegValueChanged:(id)sender {
    NSInteger mode = self.drawModeSeg.selectedSegmentIndex;
    self.selectCanvasType = mode;
}

- (IBAction)lineWidthSegValueChanged:(id)sender {
    CGFloat width = [[[self strokeWidths] objectAtIndex:self.strokeWidthSeg.selectedSegmentIndex] floatValue];
    [self setStrokeWithWidth:width];
}

- (NSString *)paperImageNameForPaperWithType:(BPaperType)type pageId: (unsigned long long) pageId {
    //请自行实现基于pageid获取底图的逻辑，此处的实现仅仅会加重demo中包含的A5P本子的底图。
    if (type != BPaperTypeA5P) {
        return  nil;
    }
    
    return  (pageId % 2 == 0) ? @"Paper_A5P_Left": @"Paper_A5P_Right";
}

- (void)batchDrawing:(NSArray<BPPoint *> *)data {
    NSLog(@"%s %@",__FUNCTION__,data);
    
    [self.dataManager processPoints:data completed:^(BOOL pageChange, BPSinglePage * _Nonnull currentPage, NSArray<BPPoint *> * _Nonnull redrawPoints) {
        [self handelPointsDraw:pageChange currentPage:currentPage redrawPoints:redrawPoints];
    }];
    /*
    [self.sdkCanvas drawingWithNonRealtimePoints:data strokeColor:self.strokeColor strokeWidthScale:self.strokeWidth];
    [self.customCanvas drawingWithNonRealtimePoints:data strokeColor:self.strokeColor strokeWidthScale:self.strokeWidth];
    
    BPPoint *first = data.firstObject ;
    if (first == nil) {
        return;
    }
    
//    BPPoint *last = self.allPoints.lastObject ;
//    if (first.pageId != last.pageId) {
//        [self.allPoints removeAllObjects];
//    }
//
//    [self.allPoints addObjectsFromArray:data];
    
    NSString *paperTypeStr = [NSString stringWithFormat:@"%lu",(unsigned long)first.paperType];
    NSString *pageIdStr = [NSString stringWithFormat:@"%llu",first.pageId];
    
    if (paperTypeStr != self.paperTypeLabel.text) {
        self.paperTypeLabel.text = paperTypeStr;
    }
    
    if (pageIdStr != self.pageIdLabel.text) {
        self.pageIdLabel.text = pageIdStr;
    }
    
//    如您手上有棒棒帮A5P的本子，可以用智能笔在本子上书写，然后看到此处实现的对齐效果
    NSString *imageName = [self paperImageNameForPaperWithType:first.paperType pageId:first.pageId];
    if (imageName == nil) {
        return;
    }
    
    if (imageName == self.backImageName) {
        return;
    }
    
    UIImage *image =  [UIImage imageNamed:imageName];
    if (image == nil) {
        return;
    }
    
    self.backImageName = imageName;
    [self.sdkCanvas updateCanvasWtihBackImage:image imageDPI:300];
    [self.customCanvas updateCanvasWtihBackImage:image imageDPI:300];
     */
}

- (void)handelPointsDraw:(BOOL)pageChanged currentPage:(BPSinglePage *)currentPage redrawPoints:(NSArray *)points{
    BPPoint *first = currentPage.allPoints.firstObject ;
    NSString *paperTypeStr = [NSString stringWithFormat:@"%lu",(unsigned long)first.paperType];
    NSString *pageIdStr = [NSString stringWithFormat:@"%llu",first.pageId];
    
    if (paperTypeStr != self.paperTypeLabel.text) {
        self.paperTypeLabel.text = paperTypeStr;
    }
    
    if (pageIdStr != self.pageIdLabel.text) {
        self.pageIdLabel.text = pageIdStr;
    }
    
    if(pageChanged) {
        NSUInteger currentIndex = [self.dataManager.allPages indexOfObject:currentPage];
        NSString *pageIndexString = [NSString stringWithFormat:@"%lu/%lu", currentIndex+1,(unsigned long)self.dataManager.allPages.count];
        [self.pageSwitchButton setTitle:pageIndexString forState:UIControlStateNormal];
        
        self.currentPage = currentPage;
        [self.sdkCanvas clearCanvas];
        [self.customCanvas clearCanvas];
        [self.sdkCanvas updateCanvasWtihBackImage:nil imageDPI:300];
        [self.customCanvas updateCanvasWtihBackImage:nil imageDPI:300];
    }
        
    [self.sdkCanvas  drawingWithRealtimePoints:points strokeColor:self.strokeColor strokeWidthScale:self.strokeWidth];
    [self.customCanvas  drawingWithRealtimePoints:points strokeColor:self.strokeColor strokeWidthScale:self.strokeWidth];
   
        
//    如您手上有棒棒帮A5P的本子，可以用智能笔在本子上书写，然后看到此处实现的对齐效果
    NSString *imageName = [self paperImageNameForPaperWithType:first.paperType pageId:first.pageId];
    if (imageName == nil) {
        return;
    }
    
    if (imageName == self.backImageName) {
        return;
    }
    
    UIImage *image =  [UIImage imageNamed:imageName];
    if (image == nil) {
        return;
    }
    
    self.backImageName = imageName;
    [self.sdkCanvas updateCanvasWtihBackImage:image imageDPI:300];
    [self.customCanvas updateCanvasWtihBackImage:image imageDPI:300];
}

- (void)realTimeDrawing:(NSArray<BPPoint *> *)data {
    //NSLog(@"%s %@",__FUNCTION__,data);         
    
    [self.dataManager processPoints:data completed:^(BOOL pageChange, BPSinglePage * _Nonnull currentPage, NSArray<BPPoint *> * _Nonnull redrawPoints) {
        [self handelPointsDraw:pageChange currentPage:currentPage redrawPoints:redrawPoints];
    }];
    
     
}

- (IBAction)drawAsImageButtonTouched:(UIButton *)sender {
    //1.初始化图片渲染器
    BPCanvasImageRender *imageRender = [[BPCanvasImageRender alloc] init];
    
    //2.笔画粗细系数，默认1.0 可自行设置其他正值
    CGFloat strokeWidthScale = 1.0 ;
    
    BPSinglePage *currentPage = self.currentPage;
    
    BPPoint *last = currentPage.allPoints.lastObject;
    if (last != nil) {
        NSString *imageName = [self paperImageNameForPaperWithType:last.paperType pageId:last.pageId];
        
        if (imageName != nil ) {
            UIImage *image =  [UIImage imageNamed:imageName];
            if (image != nil) {
                //3.设置底图 底图可选是否传入
                [imageRender updateCanvasWtihBackImage:image imageDPI:300];
            }
        }
    }
    
    //4.绘制笔迹点 ，若各笔划颜色不一样，可按笔画多次调用此方法绘制；目前不支持多页的点绘制在一页上
    [imageRender drawingWithNonRealtimePoints:currentPage.allPoints strokeColor:self.strokeColor strokeWidthScale:strokeWidthScale];
    
    //5. 生成分享图片
    UIImage *result = [imageRender getCurrentCavasImageWithBackImage: true];
    
    //分享保存图片
    if (result != nil) {
        UIActivityViewController *activeView = [[UIActivityViewController alloc] initWithActivityItems:@[result] applicationActivities: nil];
        activeView.popoverPresentationController.sourceView = self.view;
        activeView.popoverPresentationController.sourceRect = CGRectZero;
        [self presentViewController:activeView animated:true completion:^{
             
        }];
        
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (self.selectCanvasType == 0) {
        return self.customCanvas;
    } else {
        return self.sdkCanvas;
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    CGFloat newScale = self.scrollView.zoomScale * self.scrollView.window.screen.scale;
    if (self.selectCanvasType == 0) {
        self.customCanvas.contentScaleFactor = newScale;
    } else {
        self.sdkCanvas.contentScaleFactor = newScale;
    }
}
@end
