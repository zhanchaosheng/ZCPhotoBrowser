//
//  ZCPhotoBrowserDefaultPageControlDelegate.h
//  ZCPhotoBrowser
//
//  Created by zhanchaosheng on 2017/8/6.
//  Copyright © 2017年 cusen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZCPhotoBrowser.h"

/// 给图片浏览器提供一个UIPageControl
@interface ZCPhotoBrowserDefaultPageControlDelegate : NSObject<ZCPhotoBrowserPageControlDelegate>
/// 总页数
@property (nonatomic, assign) NSUInteger numberOfPages;

- (instancetype)initWithNumberOfPages:(NSUInteger)numberOfPages;
@end
