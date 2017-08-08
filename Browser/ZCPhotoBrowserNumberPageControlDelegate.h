//
//  ZCPhotoBrowserNumberPageControlDelegate.h
//  ZCPhotoBrowser
//
//  Created by zhanchaosheng on 2017/8/6.
//  Copyright © 2017年 cusen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZCPhotoBrowser.h"

@interface ZCPhotoBrowserNumberPageControlDelegate : NSObject<ZCPhotoBrowserPageControlDelegate>
/// 总页数
@property (nonatomic, assign) NSUInteger numberOfPages;

/// 字体
@property (nonatomic, strong) UIFont *font;

/// 字颜色
@property (nonatomic, strong) UIColor *textColor;

/// 中心点Y坐标
@property (nonatomic, assign) CGFloat centerY;

- (instancetype)initWithNumberOfPages:(NSUInteger)numberOfPages;

@end
