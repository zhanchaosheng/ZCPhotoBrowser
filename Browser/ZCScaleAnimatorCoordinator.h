//
//  ZCScaleAnimatorCoordinator.h
//  ZCPhotoBrowser
//
//  Created by zhanchaosheng on 2017/8/3.
//  Copyright © 2017年 cusen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZCScaleAnimatorCoordinator : UIPresentationController
/// 动画结束后需要隐藏的view
@property (nonatomic, strong) UIView *currentHiddenView;
/// 蒙板
@property (nonatomic, strong) UIView *maskView;

/// 更新动画结束后需要隐藏的view
- (void)updateCurrentHiddenView:(UIView *)view;
@end
