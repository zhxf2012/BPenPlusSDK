//
//  BPPointsDAO.m
//  BPenDemoOC
//
//  Created by Xingfa Zhou on 2023/6/25.
//  Copyright © 2023 bbb. All rights reserved.
//

#import "BPPointsDAO.h"

@interface BPSingleStroke ()
@property (nonatomic,strong) NSMutableArray<BPPoint *> *allPoints;
- (BOOL)appendPoint:(BPPoint *)point;
@end

@implementation BPSingleStroke
- (instancetype)init {
    self = [super init];
    if(self) {
        _allPoints = [NSMutableArray array];
    }
    return self;
}

- (NSArray<BPPoint *> *)points {
    return self.allPoints;
}

- (BOOL)appendPoint:(BPPoint *)point {
    [self.allPoints addObject:point];
    return true;
}
@end


@interface BPSinglePage ()
@property (nonatomic,strong) NSMutableArray<BPPoint *> *points;
@property (nonatomic,strong) NSMutableArray<BPSingleStroke *> *strokes;
- (BOOL)appendPoint:(BPPoint *)point;
@end

@implementation BPSinglePage
- (instancetype)init {
    self = [super init];
    if(self) {
        _points = [NSMutableArray array];
        _strokes = [NSMutableArray array];
    }
    return self;
}

- (NSArray<BPPoint *> *)allPoints {
    return self.points;
}

- (NSArray<BPSingleStroke *> *)allStrokes {
    return self.strokes;
}

+ (NSString *)keyForPaperType:(BPaperType)paperType pageId:(unsigned long long)pageid {
    return [NSString stringWithFormat:@"%lu-%llu",(unsigned long)paperType,pageid];
}

- (NSString *)indexKey {
    return [BPSinglePage keyForPaperType:_paperType pageId:_pageId];
}

- (BOOL)appendPoint:(BPPoint *)point {
    if(self.points.count == 0) {
        _pageId = point.pageId;
        _paperType = point.paperType;
    }
    
    
    if(point.paperType != _paperType) {
        return  false;
    }
    
    if(point.pageId != _pageId) {
        return false;
    }
    
    [self.points addObject:point];
    BPSingleStroke *currentStroke = [self.strokes lastObject];
    
    if(point.strokeStart || (!currentStroke)) {
        BPSingleStroke *stroke = [[BPSingleStroke alloc] init];
        [stroke appendPoint:point];
        [self.strokes addObject:stroke];
    }  else {
        [currentStroke appendPoint:point];
    }
    
    return true;
}

@end


@interface BPPointsDAO ()
@property (nonatomic,strong) NSMutableArray<BPSinglePage *>* pages;
@property (nonatomic,strong) NSMutableDictionary *indexDic;
@property (nonatomic,assign) NSUInteger currentPageIndex;
@property (nonatomic,strong) BPSinglePage *currentPage;
@end

@implementation BPPointsDAO

- (instancetype)init {
    self = [super init];
    if(self) {
        _pages = [NSMutableArray array];
        _indexDic = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSArray<BPSinglePage *> *)allPages {
    return self.pages;
}

- (BPSinglePage *)findPageWithPaperType:(BPaperType)paperType pageId:(unsigned long long)pageid {
    NSString *key = [BPSinglePage keyForPaperType:paperType pageId:pageid];
    return [self.indexDic objectForKey:key];
}

- (void)processPoints:(nonnull NSArray *)points completed:(nonnull void (^)(BOOL, BPSinglePage * _Nonnull, NSArray<BPPoint *> * _Nonnull))completedHandel {
    BPaperType currentPaperType = self.currentPage.paperType;
    unsigned long long currentPageId = self.currentPage.pageId;
    BOOL hasChanged = false;
    NSMutableArray *redrawPoints = [NSMutableArray array];
    
    for (NSUInteger i = 0 ; i < points.count; i++) {
        BPPoint *point = points[i];
        if((currentPaperType != point.paperType) || (currentPageId != point.pageId)) {
            currentPaperType = point.paperType;
            currentPageId = point.pageId;
            self.currentPage = [self findPageWithPaperType:currentPaperType pageId:currentPageId];
            [redrawPoints removeAllObjects];
            [redrawPoints addObjectsFromArray:self.currentPage.allPoints];
            hasChanged = true;
        }
        
        if(self.currentPage == nil) {
            BPSinglePage* page = [[BPSinglePage alloc] init];
            BOOL result = [page appendPoint:point];
            if(result) {
                [self.pages addObject:page];
                [self.indexDic setObject:page forKey:page.indexKey];
                self.currentPage  = page;
            }
            hasChanged = true;
            [redrawPoints removeAllObjects];
        } else {
            [self.currentPage appendPoint:point];
        }
        
        
        if(hasChanged) {
            self.currentPageIndex = [self.pages indexOfObject:self.currentPage];
        }
        
        [redrawPoints addObject:point];
    }
    
    completedHandel(hasChanged,self.currentPage,redrawPoints);
}

@end
