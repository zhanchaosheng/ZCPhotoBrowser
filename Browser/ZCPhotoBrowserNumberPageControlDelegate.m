//
//  ZCPhotoBrowserNumberPageControlDelegate.m
//  ZCPhotoBrowser
//
//  Created by zhanchaosheng on 2017/8/6.
//  Copyright © 2017年 cusen. All rights reserved.
//

#import "ZCPhotoBrowserNumberPageControlDelegate.h"

@implementation ZCPhotoBrowserNumberPageControlDelegate

- (instancetype)initWithNumberOfPages:(NSUInteger)numberOfPages {
    self = [super init];
    if (self) {
        _numberOfPages = numberOfPages;
        _font = [UIFont systemFontOfSize:17];
        _textColor = [UIColor whiteColor];
        _centerY = 30;
    }
    return self;
}

/// 取PageControl，只会取一次
- (UIView *)pageControlOfPhotoBrowser:(ZCPhotoBrowser *)photoBrowser {
    UILabel *pageControl = [[UILabel alloc] init];
    pageControl.font = self.font;
    pageControl.textColor = self.textColor;
    pageControl.text = [NSString stringWithFormat:@"1 / %lu",(unsigned long)self.numberOfPages];
    return pageControl;
}

/// 添加到父视图上时调用
- (void)photoBrowserPageControl:(UIView *)pageControl didMoveTo:(UIView *)superView {
    /// 这里可以不作任何操作
}

/// 让pageControl布局时调用
- (void)photoBrowserPageControl:(UIView *)pageControl needLayoutIn:(UIView *)superView {
    [self layoutPageControl:pageControl];
}

/// 页码变更时调用
- (void)photoBrowserPageControl:(UIView *)pageControl didChangedCurrentPage:(NSUInteger)currentPage {
    if ([pageControl isKindOfClass:[UILabel class]]) {
        UILabel *pageCtrl = (UILabel *)pageControl;
        NSString *text = [NSString stringWithFormat:@"%lu / %lu",
                          (unsigned long)(currentPage + 1),(unsigned long)self.numberOfPages];
        pageCtrl.text = text;
        [self layoutPageControl:pageControl];
    }
}

- (void)layoutPageControl:(UIView *)pageControl {
    [pageControl sizeToFit];
    if (pageControl.superview) {
        pageControl.center = CGPointMake(CGRectGetMidX(pageControl.superview.bounds),
                                         CGRectGetMinY(pageControl.superview.bounds) + self.centerY);
    }
}

@end
