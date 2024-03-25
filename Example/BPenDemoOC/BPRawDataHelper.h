//
//  BPRawDataHelper.h
//  BPenDemoOC
//
//  Created by Xingfa Zhou on 2023/5/26.
//  Copyright © 2023 bbb. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BPRawDataHelper : NSObject
+ (void)readRawDataFromFile:(NSString *)path andExportToTxtFile:(NSString *)txtPath completedHandel:(void (^) (bool,NSError*_Nullable))handel;
@end

NS_ASSUME_NONNULL_END
