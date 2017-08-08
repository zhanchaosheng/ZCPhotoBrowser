//
//  ZCPhotoBrowserLayout.m
//  ZCPhotoBrowser
//
//  Created by zhanchaosheng on 2017/8/3.
//  Copyright © 2017年 cusen. All rights reserved.
//

#import "ZCPhotoBrowserLayout.h"

@interface ZCPhotoBrowserLayout()
/// 一页宽度，算上空隙
@property (nonatomic, assign) CGFloat pageWidth;
/// 上次页码
@property (nonatomic, assign) CGFloat lastPage;
/// 最小页码
@property (nonatomic, assign) CGFloat minPage;
/// 最大页码
@property (nonatomic, assign) CGFloat maxPage;
@end

@implementation ZCPhotoBrowserLayout

- (instancetype)init {
    self = [super init];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _lastPage = -1;
    }
    return self;
}

- (CGFloat)pageWidth {
    return self.itemSize.width + self.minimumLineSpacing;
}

- (CGFloat)lastPage {
    if (_lastPage == -1) {
        if (self.collectionView) {
            CGFloat offsetX = self.collectionView.contentOffset.x;
            return round(offsetX / self.pageWidth);
        }
        return 0;
    }
    return _lastPage;
}

- (CGFloat)minPage {
    return 0;
}

- (CGFloat)maxPage {
    if (self.collectionView) {
        CGFloat contentWidth = self.collectionView.contentSize.width;
        contentWidth += self.minimumLineSpacing;
        return contentWidth / self.pageWidth - 1;
    }
    return 0;
}

/// 调整scroll停下来的位置
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset
                                 withScrollingVelocity:(CGPoint)velocity {
    // 页码
    CGFloat page = round(proposedContentOffset.x / self.pageWidth);
    // 处理轻微滑动
    if (velocity.x > 0.2) {
        page += 1;
    }
    else if (velocity.x < -0.2) {
        page -= 1;
    }
    
    // 一次滑动不允许超过一页
    if (page > self.lastPage + 1) {
        page = self.lastPage + 1;
    }
    else if (page < self.lastPage - 1) {
        page = self.lastPage - 1;
    }
    if (page > self.maxPage) {
        page = self.maxPage;
    }
    else if (page < self.minPage) {
        page = self.minPage;
    }
    self.lastPage = page;
    return CGPointMake(page * self.pageWidth, 0);
}
@end
