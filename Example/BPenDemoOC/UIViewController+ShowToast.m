//
//  UIViewController+ShowToast.m
//  BPenDemoOC
//
//  Created by Xingfa Zhou on 2023/5/10.
//  Copyright © 2023 bbb. All rights reserved.
//

#import "UIViewController+ShowToast.h"
#import "MBProgressHUD.h"

@implementation UIViewController (ShowToast)

- (UIAlertController *)showAlertWithTitle:(NSString *)title message:(NSString *)message confirmAction:(UIAlertAction *)confirm cancelAction:(UIAlertAction *)cancel otherActions:(NSArray<UIAlertAction *> *)otherActions preferredStyle:(UIAlertControllerStyle)preferredStyle presentCompleted:(void (^)(void))presentCompleted {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:preferredStyle];
    for (UIAlertAction *action in otherActions) {
        [alert addAction:action];
    }
    if (cancel) {
        [alert addAction:cancel];
    }
    if (confirm) {
        [alert addAction:confirm];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:presentCompleted];
    });
    return alert;
}

- (MBProgressHUD *)createHud {
    MBProgressHUD *pre = [MBProgressHUD HUDForView:self.view];
    [pre hideAnimated:YES];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    return hud;
}

- (void)hideAllHud {
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *pre = [MBProgressHUD HUDForView:self.view];
        if (pre) {
            [pre hideAnimated:YES];
        }
    });
}

- (void)asyncInMainQueueBlock:(void (^)(void))block {
    if (NSThread.isMainThread) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            block();
        });
    }
}

- (void)showProgressWith:(NSString *)title progressMsg:(NSString *)progressMsg {
    [self asyncInMainQueueBlock:^{
        MBProgressHUD *progressHud = [self createHud];
        progressHud.label.text = title;
        progressHud.detailsLabel.text = progressMsg;
        [progressHud showAnimated:YES];
    }];
}

- (void)showMessageWithTitle:(NSString *)title msg:(NSString *)msg disapperAfterDelay:(NSTimeInterval)delay {
    [self asyncInMainQueueBlock:^{
        MBProgressHUD *progressHud = [self createHud];
        progressHud.mode = MBProgressHUDModeText;
        progressHud.label.text = title;
        progressHud.detailsLabel.text = msg;
        [progressHud showAnimated:YES];
        [progressHud hideAnimated:YES afterDelay:delay];
    }];
}

@end
