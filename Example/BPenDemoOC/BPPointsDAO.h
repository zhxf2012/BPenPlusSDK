//
//  BPPointsDAO.h
//  BPenDemoOC
//
//  Created by Xingfa Zhou on 2023/6/25.
//  Copyright © 2023 bbb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BPenPlusSDK/BPenPlusSDK.h>

NS_ASSUME_NONNULL_BEGIN
@interface BPSingleStroke : NSObject
@property (nonatomic,readonly) NSArray<BPPoint *> *points;
@end

@interface BPSinglePage : NSObject
@property (nonatomic,readonly) NSArray<BPPoint *> *allPoints;
@property (nonatomic,readonly) NSArray<BPSingleStroke *> *allStrokes;
@property (nonatomic,readonly) BPaperType paperType;
@property (nonatomic,readonly) unsigned long long pageId;
@property (nonatomic,readonly) NSString *indexKey;
@end


//本类用于对数据进行管理，目前仅缓存中内存中，如需持久和增删查改，请自行实现
@interface BPPointsDAO : NSObject
@property (nonatomic,readonly) NSArray<BPSinglePage *>*allPages;


- (void)processPoints:(NSArray *)points completed:(void (^) (BOOL pageChange,BPSinglePage *currentPage,NSArray<BPPoint *>*redrawPoints))completedHandel;
@end

NS_ASSUME_NONNULL_END
