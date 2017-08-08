//
//  ZCPhotoBrowserDefaultPageControlDelegate.m
//  ZCPhotoBrowser
//
//  Created by zhanchaosheng on 2017/8/6.
//  Copyright © 2017年 cusen. All rights reserved.
//

#import "ZCPhotoBrowserDefaultPageControlDelegate.h"

@implementation ZCPhotoBrowserDefaultPageControlDelegate

- (instancetype)initWithNumberOfPages:(NSUInteger)numberOfPages {
    self = [super init];
    if (self) {
        _numberOfPages = numberOfPages;
    }
    return self;
}

/// 取PageControl，只会取一次
- (UIView *)pageControlOfPhotoBrowser:(ZCPhotoBrowser *)photoBrowser {
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    pageControl.numberOfPages = self.numberOfPages;
    pageControl.userInteractionEnabled = NO;
    return pageControl;
}

/// 添加到父视图上时调用
- (void)photoBrowserPageControl:(UIView *)pageControl didMoveTo:(UIView *)superView {
    // 这里可以不作任何操作
}

/// 让pageControl布局时调用
- (void)photoBrowserPageControl:(UIView *)pageControl needLayoutIn:(UIView *)superView {
    [pageControl sizeToFit];
    pageControl.center = CGPointMake(CGRectGetMidX(superView.bounds),
                                     CGRectGetMaxY(superView.bounds) - 20);
}

/// 页码变更时调用
- (void)photoBrowserPageControl:(UIView *)pageControl didChangedCurrentPage:(NSUInteger)currentPage {
    if ([pageControl isKindOfClass:[UIPageControl class]]) {
        UIPageControl *pageCtrl = (UIPageControl *)pageControl;
        pageCtrl.currentPage = currentPage;
    }
}

@end
