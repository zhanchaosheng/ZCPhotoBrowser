//
//  ZCScaleAnimator.h
//  ZCPhotoBrowser
//
//  Created by zhanchaosheng on 2017/8/3.
//  Copyright © 2017年 cusen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZCScaleAnimator : NSObject<UIViewControllerAnimatedTransitioning>
/// 动画开始位置的视图
@property (nonatomic, strong) UIView *startView;
/// 动画结束位置的视图
@property (nonatomic, strong) UIView *endView;
/// 用于转场时的缩放视图
@property (nonatomic, strong) UIView *scaleView;

- (instancetype)initWithStartView:(UIView *)start endView:(UIView *)end scaleView:(UIView *)scale;

@end
