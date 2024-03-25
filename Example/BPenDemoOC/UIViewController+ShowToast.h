//
//  UIViewController+ShowToast.h
//  BPenDemoOC
//
//  Created by Xingfa Zhou on 2023/5/10.
//  Copyright © 2023 bbb. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (ShowToast)
- (UIAlertController *)showAlertWithTitle:(NSString *)title message:(NSString *)message confirmAction:(UIAlertAction * _Nullable) confirm cancelAction:(UIAlertAction * _Nullable)cancel otherActions:(NSArray<UIAlertAction *> *)otherActions preferredStyle:(UIAlertControllerStyle)preferredStyle presentCompleted:(void (^)(void))presentCompleted;

- (void)hideAllHud ;
- (void)showProgressWith:(NSString *)title progressMsg:(NSString *)progressMsg ;
- (void)showMessageWithTitle:(NSString *)title msg:(NSString *)msg disapperAfterDelay:(NSTimeInterval)delay ;
@end

NS_ASSUME_NONNULL_END
